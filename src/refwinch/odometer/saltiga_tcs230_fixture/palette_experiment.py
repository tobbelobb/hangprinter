#!/usr/bin/env python3
"""Record labelled TCS230 samples, plot clusters, and fit a centroid palette.

No live plotter: the Arduino IDE must release the serial port during capture.
Raw Hz are retained; features do not depend on e/w gain calibration.
"""
import argparse
import csv
import json
import math
import os
import sys
import time
from pathlib import Path

PALETTE = ['Orange', 'Black', 'Yellow', 'Blue', 'Green', 'Red', 'Purple']
FEATURES = ['R_over_C', 'G_over_C', 'B_over_C', 'log_clear100']
RGB_FEATURES = ['R_fraction', 'G_fraction', 'B_fraction', 'log_clear100']
FIELDS = ['label', 'batch', 'host_time_ns', 't_ms', 'R_Hz', 'G_Hz', 'B_Hz',
          'C_Hz', 'scale_pct', 'gate_us', 'reciprocal', 'scan_us', 'row_us',
          'settled', 'clear100_Hz', *FEATURES, 'valid']


def features(row, normalization='clear'):
    raw = [float(row[k]) for k in ['R_Hz', 'G_Hz', 'B_Hz', 'C_Hz']]
    scale = int(row['scale_pct'])
    if scale not in (2, 20, 100) or any(not math.isfinite(x) or x < 0 for x in raw):
        raise ValueError('Invalid raw reading or scaling')
    clear = raw[3] * 100.0 / scale
    if raw[3] <= 0 or int(row['settled']) != 1:
        raise ValueError('Unsettled or zero-clear reading')
    denominator = raw[3] if normalization=='clear' else sum(raw[:3])
    if denominator <= 0 or not math.isfinite(denominator):
        raise ValueError('Zero or nonfinite colour denominator')
    x = [raw[i] / denominator for i in range(3)] + [math.log1p(clear)]
    if not math.isfinite(clear) or any(not math.isfinite(v) for v in x):
        raise ValueError('Nonfinite feature vector')
    return clear, x


def capture(args):
    import serial
    args.output.parent.mkdir(parents=True, exist_ok=True)
    append = args.output.exists() and args.output.stat().st_size > 0
    if append:
        with args.output.open(newline='') as f:
            if next(csv.reader(f)) != FIELDS:
                raise ValueError('Existing capture has a different schema; choose a new file')
        with args.output.open(newline='') as f:
            if any(r['label'] == args.label and r['batch'] == args.batch for r in csv.DictReader(f)):
                raise ValueError('Batch already exists for this label; use a new batch ID')
    accepted = rejected = 0
    header = None
    with serial.Serial(args.port, 115200, timeout=1, exclusive=True) as port, \
            args.output.open('a', newline='') as out:
        writer = csv.DictWriter(out, fieldnames=FIELDS)
        if not append:
            writer.writeheader()
        # Opening the port may reset Uno; its EEPROM calibration is retained.
        time.sleep(2)
        port.reset_input_buffer()
        port.write(b'v\n')
        time.sleep(.6)
        port.write(b'f\n')
        port.flush()
        deadline = time.monotonic() + args.timeout
        while accepted < args.samples:
            if time.monotonic() > deadline:
                raise TimeoutError(f'Only {accepted}/{args.samples} valid samples; {rejected} invalid')
            line = port.readline().decode('ascii', errors='replace').strip()
            if line.startswith('t_ms,'):
                header = line.split(',')
                continue
            if not header or not line or line.startswith('#'):
                continue
            values = line.split(',')
            if len(values) != len(header):
                continue
            row = dict(zip(header, values))
            if not row['t_ms'].isdigit():
                continue
            if row.get('reciprocal') != '1' or row.get('gate_us') != '2000':
                continue  # Do not mix startup/slow-mode precision into training.
            record = {k: row.get(k, '') for k in FIELDS}
            record.update(label=args.label, batch=args.batch, host_time_ns=time.time_ns())
            try:
                clear, x = features(row)
                record.update(clear100_Hz=clear, valid=1)
                record.update(zip(FEATURES, x))
                accepted += 1
            except (ValueError, KeyError):
                record['valid'] = 0
                rejected += 1
            writer.writerow(record)
            if accepted and accepted % 250 == 0:
                out.flush()
                print(f'{args.label} batch {args.batch}: {accepted}/{args.samples}, invalid={rejected}', flush=True)
        out.flush()
        port.write(b'p\n')
        port.flush()
    print(f'Saved {accepted} valid {args.label} samples to {args.output}', flush=True)


def fit_centroids(x, labels, names, dark_hz=0, clear_weight=1, normalization='clear'):
    import numpy as np
    mean = x.mean(axis=0)
    std = np.maximum(x.std(axis=0), 1e-6)
    weights = np.array([1., 1., 1., clear_weight])
    inv_std = weights / std
    z = (x - mean) * inv_std
    classes = []
    for name in names:
        points = z[labels == name]
        if not len(points):
            raise ValueError(f'No training observations for {name}')
        centre = points.mean(axis=0)
        d2 = ((points - centre) ** 2).sum(axis=1)
        classes.append(dict(name=name, centroid=centre.tolist(),
                            radius2=max(float(np.quantile(d2, .995)), .0001),
                            samples=len(points)))
    return dict(format='saltiga-centroid-v2', normalization=normalization,
                features=FEATURES if normalization=='clear' else RGB_FEATURES,
                mean=mean.tolist(), inv_std=inv_std.tolist(), feature_weights=weights.tolist(),
                dark_clear_hz=dark_hz, classes=classes)


def predict(model, x):
    import numpy as np
    z = (x - model['mean']) * model['inv_std']
    centres = np.array([c['centroid'] for c in model['classes']])
    d2 = ((z[:, None, :] - centres[None, :, :]) ** 2).sum(axis=2)
    nearest = d2.argmin(axis=1)
    accepted = d2[np.arange(len(x)), nearest] <= np.array(
        [c['radius2'] for c in model['classes']])[nearest]
    # Low absolute clear is an optional darkness flag, not proof of a clog.
    accepted &= np.expm1(x[:, 3]) >= model.get('dark_clear_hz', 0)
    return nearest, accepted


def analyze(args):
    import numpy as np
    os.environ.setdefault('MPLCONFIGDIR', '/tmp/saltiga-matplotlib')
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    from itertools import combinations
    args.output.mkdir(parents=True, exist_ok=True)
    records = []
    invalid = 0
    with args.input.open(newline='') as f:
        for row in csv.DictReader(f):
            try:
                clear, x = features(row, args.normalization)
                if row['label'] not in args.palette:
                    continue
                if row.get('valid') != '1':
                    raise ValueError('Invalid sample')
                records.append((row['label'], row['batch'], clear, x, features(row)[1]))
            except (ValueError, KeyError):
                invalid += 1
    if not records:
        raise ValueError('No valid labelled observations')
    labels = np.array([r[0] for r in records])
    batches = np.array([r[1] for r in records])
    x = np.array([r[3] for r in records])
    raw_x = np.array([r[4] for r in records])
    rgb_x = raw_x.copy()
    rgb_x[:, :3] /= rgb_x[:, :3].sum(axis=1, keepdims=True)
    axes_names = FEATURES if args.normalization=='clear' else RGB_FEATURES
    names = [name for name in args.palette if name in labels]
    counts = {n: {str(b): int(np.sum((labels == n) & (batches == b)))
                  for b in sorted(set(batches[labels == n]))} for n in names}
    ready = all(n in counts and sum(counts[n].values()) >= 3000 and
                len(counts[n]) >= 3 for n in args.palette)
    model = fit_centroids(x, labels, names, args.dark_hz, args.clear_weight, args.normalization)
    # Every fold holds out whole placements for all colours. Standardization
    # and centroids are fitted only on the remaining data, avoiding leakage.
    confusion = np.zeros((len(names), len(names)), dtype=int)
    rejection = np.zeros(len(names), dtype=int)
    accepted_confusion = np.zeros_like(confusion)
    folds = 0
    fold_results = []
    comparison = {(basis,w): dict(correct=0, total=0) for basis in ['clear','rgb'] for w in [0,1]}
    for batch in sorted(set(batches)):
        train, test = batches != batch, batches == batch
        if not all(n in labels[train] for n in names) or len(names) < 2:
            continue
        fold_model = fit_centroids(x[train], labels[train], names, args.dark_hz, args.clear_weight, args.normalization)
        nearest, accepted = predict(fold_model, x[test])
        for truth, guess, ok in zip(labels[test], nearest, accepted):
            i = names.index(truth)
            confusion[i, guess] += 1
            rejection[i] += not ok
            if ok:
                accepted_confusion[i, guess] += 1
        truth_ids = np.array([names.index(n) for n in labels[test]])
        for (basis, weight), score in comparison.items():
            xx = raw_x if basis=='clear' else rgb_x
            alternative = fit_centroids(xx[train], labels[train], names, args.dark_hz, weight, basis)
            alt_nearest, _ = predict(alternative, xx[test])
            score['correct'] += int(np.sum(alt_nearest == truth_ids))
            score['total'] += len(truth_ids)
        fold_results.append(dict(batch=str(batch),
                                 test_samples_per_colour={n: int(np.sum(labels[test] == n)) for n in names},
                                 nearest_accuracy=float(np.mean(nearest == truth_ids)),
                                 acceptance_coverage=float(np.mean(accepted)),
                                 accepted_accuracy=float(np.mean(nearest[accepted] == truth_ids[accepted])) if accepted.any() else None))
        folds += 1
    evaluated = int(confusion.sum())
    accuracy = float(np.trace(confusion) / evaluated) if evaluated else None
    ablation = {f'{basis}_normalization_clear_weight_{w}': dict(**score, accuracy=score['correct']/score['total'] if score['total'] else None) for (basis,w), score in comparison.items()}
    summary = dict(normalization=args.normalization, clear_weight=args.clear_weight, feature_comparison=ablation, palette_requested=args.palette, samples_per_batch=counts,
                   invalid_rows=invalid, palette_ready=ready,
                   held_out_batch_folds=folds, evaluated_samples=evaluated,
                   fold_results=fold_results,
                   nearest_centroid_accuracy=accuracy,
                   accepted_samples=int(accepted_confusion.sum()),
                   acceptance_coverage=float(accepted_confusion.sum()/evaluated) if evaluated else None,
                   accepted_accuracy=float(np.trace(accepted_confusion)/accepted_confusion.sum()) if accepted_confusion.sum() else None,
                   accepted_confusion=accepted_confusion.tolist(),
                   confusion_labels=names, confusion=confusion.tolist(),
                   rejected_per_true_class=rejection.tolist(),
                   note='Stationary grouped validation, not boundary timing or clog validation.')
    model['palette_ready'] = ready
    if len(names)>=2:
        (args.output / 'palette_commands.txt').write_text('\n'.join(model_lines(model))+'\n')
    (args.output / 'palette_model.json').write_text(json.dumps(model, indent=2) + '\n')
    (args.output / 'summary.json').write_text(json.dumps(summary, indent=2) + '\n')
    colours = {'Orange': '#e87500', 'Black': '#222222', 'Yellow': '#c7a600',
               'Blue': '#1765cf', 'Green': '#168a42', 'Red': '#d62b2b', 'Purple': '#8b3dc6'}
    pairs = list(combinations(range(4), 2))
    fig, axes = plt.subplots(2, 3, figsize=(14, 8))
    for ax, (i, j) in zip(axes.flat, pairs):
        for name in names:
            pts = x[labels == name]
            yy = np.expm1(pts[:, j]) if j == 3 else pts[:, j]
            ax.scatter(pts[:, i], yy, s=4, alpha=.16,
                       color=colours.get(name), label=f'{name} (n={len(pts)})', rasterized=True)
        ax.set_xlabel(axes_names[i])
        ax.set_ylabel('Absolute clear at 100% (Hz)' if j == 3 else axes_names[j])
        if j == 3:
            ax.set_yscale('log')
        ax.grid(alpha=.2)
    handles, text = axes.flat[0].get_legend_handles_labels()
    fig.legend(handles, text, loc='upper center', bbox_to_anchor=(.5, .96), ncol=min(len(names), 4),
               markerscale=3)
    for ax in axes.flat:
        ax.ticklabel_format(axis='x', useOffset=False)
        ax.xaxis.set_major_locator(plt.MaxNLocator(5))
    fig.suptitle('Measured line-colour clusters — normalized RGB and absolute clear', y=.995)
    fig.tight_layout(rect=(0, 0, 1, .86))
    fig.savefig(args.output / 'clusters.png', dpi=180, bbox_inches='tight')
    fig.savefig(args.output / 'clusters.pdf', bbox_inches='tight')
    plt.close(fig)
    if evaluated:
        fig, ax = plt.subplots(figsize=(8, 7), constrained_layout=True)
        rates = confusion / confusion.sum(axis=1, keepdims=True).clip(min=1)
        ax.imshow(rates, vmin=0, vmax=1, cmap='Blues')
        ax.set_xticks(range(len(names)), names, rotation=35, ha='right')
        ax.set_yticks(range(len(names)), names)
        for i in range(len(names)):
            for j in range(len(names)):
                ax.text(j, i, str(confusion[i, j]), ha='center', va='center',
                        color='white' if rates[i, j] > .55 else 'black')
        ax.set_xlabel('Nearest centroid prediction')
        ax.set_ylabel('Known held-out colour')
        ax.set_title(f'Held-out placements: {accuracy:.1%} forced classification accuracy')
        fig.savefig(args.output / 'confusion.png', dpi=180)
        plt.close(fig)
    print(json.dumps(summary, indent=2))


def model_lines(model):
    """Validate and encode the same four-dimensional model used by the Uno."""
    import re
    normalization = model.get('normalization')
    expected = FEATURES if normalization=='clear' else RGB_FEATURES
    if model.get('format') != 'saltiga-centroid-v2' or normalization not in ('clear','rgb') or model.get('features') != expected:
        raise ValueError('Unsupported model features/version')
    classes = model['classes']
    if not 2 <= len(classes) <= 8:
        raise ValueError('Uno needs 2..8 palette classes')
    def floats(values, n, positive=False):
        if len(values) != n or any(not math.isfinite(v) or (positive and v <= 0) for v in values):
            raise ValueError('Invalid model coefficients')
        return ' '.join(format(v, '.9g') for v in values)
    mean = floats(model['mean'], 4)
    inv = floats(model['inv_std'], 4)
    if any(v < 0 for v in model['inv_std']) or not any(v > 0 for v in model['inv_std']):
        raise ValueError('Feature scales must be nonnegative and not all zero')
    dark = model.get('dark_clear_hz', 0)
    if not math.isfinite(dark) or dark < 0:
        raise ValueError('Invalid darkness floor')
    lines = [f'@N {len(classes)} {0 if normalization=="clear" else 1} {mean} {inv} {dark:.9g}']
    names = set()
    for i, c in enumerate(classes):
        name = c['name']
        if not re.fullmatch(r'[A-Za-z0-9_-]{1,11}', name) or name in names:
            raise ValueError('Class names must be unique and at most 11 simple ASCII characters')
        names.add(name)
        centre = floats(c['centroid'], 4)
        radius, samples = c['radius2'], c['samples']
        if not math.isfinite(radius) or radius <= 0 or not isinstance(samples, int) or not 0 < samples <= 0xFFFFFFFF:
            raise ValueError('Invalid class radius or sample count')
        lines.append(f'@C {i} {name} {centre} {radius:.9g} {samples}')
    lines.append('@W')
    if any(len(line.encode('ascii')) > 191 for line in lines):
        raise ValueError('Encoded model row exceeds Uno input buffer')
    return lines


def deploy(args):
    import serial
    model = json.loads(args.model.read_text())
    if not model.get('palette_ready'):
        raise ValueError('Model needs at least 3,000 samples in three placements for every requested colour')
    lines = model_lines(model)
    def wait_for(port, expected):
        deadline = time.monotonic() + 10
        while time.monotonic() < deadline:
            line = port.readline().decode('ascii', errors='replace').strip()
            if line == expected:
                return
            if line.startswith('# model command rejected') or line.startswith('# model input timed out'):
                raise ValueError(line)
        raise TimeoutError(f'Uno did not acknowledge {expected!r}; upload the updated sketch first')
    with serial.Serial(args.port, 115200, timeout=.5, exclusive=True) as port:
        time.sleep(2)
        port.reset_input_buffer()
        for line in lines:
            # Pause acquisition before transmitting a row longer than RX SRAM.
            port.write(b'@')
            port.flush()
            wait_for(port, '# model line ready')
            port.write(line[1:].encode('ascii') + b'\n')
            port.flush()
            expected = ('# model normalization accepted' if line.startswith('@N') else
                        '# model class accepted' if line.startswith('@C') else
                        '# palette saved in EEPROM')
            wait_for(port, expected)
        port.write(b'd\n')
        port.flush()
    print('Palette saved in Uno EEPROM. Send d in the IDE plotter to see category indicators.')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    subs = parser.add_subparsers(dest='command', required=True)
    p = subs.add_parser('capture', help='Hold one known colour stationary for one batch')
    p.add_argument('--port', default='/dev/ttyACM0')
    p.add_argument('--label', required=True, choices=PALETTE)
    p.add_argument('--batch', required=True, help='Independent placement/segment ID, e.g. 1, 2, 3')
    p.add_argument('--samples', type=int, default=1000)
    p.add_argument('--timeout', type=float, default=300)
    p.add_argument('--output', type=Path, required=True)
    p.set_defaults(func=capture)
    p = subs.add_parser('analyze', help='Plot the measured clusters and fit/test nearest centroids')
    p.add_argument('--input', type=Path, required=True)
    p.add_argument('--output', type=Path, required=True)
    p.add_argument('--palette', nargs='+', default=PALETTE)
    p.add_argument('--dark-hz', type=float, default=0,
                   help='Optional absolute-clear floor at 100%% scaling; 0 disables darkness rejection')
    p.add_argument('--normalization', choices=['clear','rgb'], default='clear',
                   help='Normalize RGB by clear, or by R+G+B; absolute clear is retained separately')
    p.add_argument('--clear-weight', type=float, default=1,
                   help='Weight of log-clear in classification; 0 uses colour ratios only, while still retaining absolute clear')
    p.set_defaults(func=analyze)
    p = subs.add_parser('deploy', help='Import a complete trained palette into Uno EEPROM')
    p.add_argument('--port', default='/dev/ttyACM0')
    p.add_argument('--model', type=Path, required=True)
    p.set_defaults(func=deploy)
    args = parser.parse_args()
    if getattr(args, 'samples', 1) <= 0:
        parser.error('--samples must be positive')
    if getattr(args, 'dark_hz', 0) < 0 or not math.isfinite(getattr(args, 'dark_hz', 0)):
        parser.error('--dark-hz must be finite and nonnegative')
    if getattr(args, 'clear_weight', 1) < 0 or not math.isfinite(getattr(args, 'clear_weight', 1)):
        parser.error('--clear-weight must be finite and nonnegative')
    try:
        args.func(args)
    except (ValueError, TimeoutError, OSError) as exc:
        parser.exit(1, f'{exc}\n')


if __name__ == '__main__':
    main()
