# Measured Saltiga colour palette

The Uno already measures **R, G, B and clear**, sequentially. Clear is the
unfiltered channel. The new palette path keeps these absolute frequencies and
supports two normalizations: **R/C, G/C, B/C** or **R/(R+G+B), G/(R+G+B), B/(R+G+B)**, plus **log(1 + clear100_Hz)**, where
`clear100_Hz = C_Hz * 100 / scale_pct`. This is sensor frequency referred to
100% output scaling, not lux. Ratios reduce common intensity changes; absolute
clear preserves intensity differences such as black versus blue. These features
use neither empty subtraction nor white gains, so `e`/`w` do not change them.

The palette is Orange, Black, Yellow, Blue, Green, Red, Purple. Training fits
one centroid per colour after standardizing the four features using the training
set's mean and standard deviation. The Uno uses the identical transformation
and squared Euclidean distance. Standard deviations have only a 1e-6 numerical floor; small but meaningful colour-ratio differences retain their weight. The nearest colour is accepted only inside its
training-set 99.5th-percentile squared-distance radius. Otherwise it reports
Unknown. The nearest ID and distance remain available for diagnosis. `margin`
is relative separation from the second-nearest centroid, not a probability.

## Sketch commands

Upload `uno_saltiga_test/uno_saltiga_test.ino` for an Uno R3, at 115200 baud.
Calibration and palette occupy separate EEPROM records and survive a reset. Once a palette has been imported, the sketch starts with category indicators; `p` switches back to the RGB plot.

| Command | Output |
|---|---|
| `p` | Existing RGB fractions and white-relative Brightness plot |
| `v` | Existing diagnostic CSV including raw R, G, B, C frequencies |
| `a` | Raw RGBC, clear100, four features, validity and classification CSV |
| `h` | Absolute clear100 frequency alone in the IDE Serial Plotter |
| `d` | Palette colour indicators, Unknown, LowClear and Invalid, on a 0–1 plot |
| `f` / `s` | Fast reciprocal acquisition at 2 ms/channel / slow 100 ms counting |

The `a` output supplies `nearest_id`, accepted `class_id` (-1 means Unknown),
`distance2`, and `margin`. `normalization=0` means RGB/clear; `normalization=1` means RGB fractions. `R_feature`, `G_feature`, `B_feature` follow that choice. IDs follow the model JSON's class order, starting at
zero. The category plot displays Red, Green, Blue, Orange, Purple, Yellow, Black
to align with the current IDE plot colours; this does not reorder model IDs. Before importing a model, all classification IDs are -1. All four channels
must settle and clear must be positive for a feature vector to be valid.

`low_clear` / `LowClear` use an optional absolute-clear threshold. `Invalid` flags an unusable feature vector, including settling failures; a zero reported clear frequency can therefore show both flags when the threshold is enabled. It defaults to **disabled**.
Black line, loss of illumination and a clogged sensor can all reduce clear;
a low-clear observation alone cannot identify which occurred. Capture actual
fault conditions before choosing a threshold that must also tolerate black.
`h` makes the raw health measurement visible without stretching the RGB plot.

## Collection

Close the IDE Serial Monitor and Plotter to release the port. Run commands from
this fixture directory; Python requires pyserial, NumPy and Matplotlib.

```sh
python3 palette_experiment.py capture --label Blue --batch 1 --samples 1000 \
  --output data/palette_2026-10-06.csv
```

Hold only the named colour stationary until collection completes. Capture all
seven colours, then repeat with batch IDs 2 and 3 after repositioning the line;
prefer different physical stretches of each colour. The target is at least
3,000 valid observations **and three independent placements per colour**.
Three back-to-back batches without repositioning do not test placement error.
Each batch opens the port, allows reset, enables diagnostic output and fast
2 ms/channel acquisition, retains raw readings and records invalid observations
separately. Acquisition scale is recorded. Collection does not change `e`/`w`.
Do not change illumination, enclosure or frequency scaling between colours.
Duplicate colour/batch IDs are rejected to prevent accidentally relabelling an
existing batch. Use a new batch ID if a run was interrupted.

```sh
python3 palette_experiment.py analyze --input data/palette_2026-10-06.csv \
  --output data/palette_2026-10-06_analysis --normalization rgb --clear-weight 0
```

This produces six feature-pair scatterplots (`clusters.png` and PDF), the fitted
`palette_model.json`, and `summary.json`. If repeated placements exist, it also
produces `confusion.png`. Validation leaves out one entire batch ID across
colours at a time and refits normalization and centroids on the other batches.
It reports forced nearest-centroid accuracy, accepted accuracy and acceptance
coverage. `feature_comparison` compares both normalizations, each with and without clear
intensity in the distance, on the same held-out placements. Use
`--normalization rgb` for RGB fractions or `--normalization clear` for RGB/clear.
The capture CSV retains its original RGB/clear columns; analysis recomputes
the selected features from the saved raw frequencies, so no data are lost. To fit a colour-only model, add
`--clear-weight 0`; clear is still measured, saved and plotted, but contributes
zero to centroid distance. The default `--clear-weight 1` uses all four features. Rejection does not count as a correct colour prediction. Adjacent
samples are correlated; thousands of samples from one placement do not replace
repeat-placement validation. Partial datasets are plotted honestly and marked
`palette_ready: false`; they cannot be deployed by the helper.

## Import the trained palette

```sh
python3 palette_experiment.py deploy \
  --model data/palette_2026-10-06_analysis/palette_model.json
```

The helper checks model dimensions and coefficients, transfers it to the Uno,
and commits it to EEPROM only after all classes have been accepted. Reopen the
IDE Plotter at 115200 and send `d` to inspect colour assignments. Send `a` in
the Monitor for numeric diagnostics or `h` in the Plotter for absolute clear.

The wire protocol is `@N count normalization mean[4] inv_std[4] dark_hz`, then
`@C id name centroid[4] radius2 sample_count` for each class, then `@W`.
For each row send only `@`, wait for `# model line ready`, then send the rest
and newline. This pauses acquisition and prevents the Uno's small UART buffer
from losing long model rows. `palette_commands.txt` records the exact rows;
it is not intended to be pasted as a block into the Monitor. Invalid model
commands do not overwrite the previously saved EEPROM record.

## Results from 6 October 2026

Collected **21,000 valid observations**, exactly 3,000 per colour in three
separately repositioned 1,000-sample batches. No invalid rows occurred. The
saved CSV contains the measured raw frequencies; the figures contain no
synthetic samples.

RGB fractions with zero clear weight gave the best grouped validation result.
The complete-data fitted model uses these fractions for colour distance and
retains absolute clear as an independent diagnostic. The optional low-clear
threshold remains disabled until actual fault conditions have been measured.

| Features used for centroid distance | Held-out nearest accuracy |
|---|---:|
| RGB/clear | 92.38% |
| RGB/clear plus log clear | 91.66% |
| RGB fractions | **94.85%** |
| RGB fractions plus log clear | 94.18% |

For the selected model, the radius gate accepted 20,463 of 21,000 held-out
readings (**97.44% coverage**). Among those accepted, **95.33%** had the correct
colour. Rejection therefore does not yet remove most ambiguous readings.

| Known colour | Held-out nearest accuracy |
|---|---:|
| Orange | 99.53% |
| Black | 94.63% |
| Yellow | 96.93% |
| Blue | 86.80% |
| Green | 88.90% |
| Red | 99.93% |
| Purple | 97.20% |

The clusters show useful separation, with residual overlap: blue is sometimes
assigned purple or green, and green is sometimes assigned black. The three
held-out folds had 91.93%, 98.11% and 94.50% nearest accuracy. Each fold refits
normalization and centroids without its test batch. These same folds selected
the feature configuration, so the results are exploratory model-selection
scores, not an untouched final test. Correlated readings from just three
placements per colour also cannot establish reliability across arbitrary
motion, line sections or lighting changes.

Files: `data/palette_2026-10-06.csv`, and the analysis directory's
`clusters.png`, `clusters.pdf`, `confusion.png`, `summary.json`,
`palette_model.json`, `palette_commands.txt`, `deployment_check.json`.

The latest sketch and full palette were uploaded to the Uno. Two serial-open
resets restored the palette and started the category plot with Blue active.
All 50 subsequent live rows agreed with the Python nearest/accepted decisions
and were accepted as Blue. Features agreed within 1.85e-6 and reported clear
agreed with the raw-frequency scaling. The independent clear plot worked
before restoring category output. This is a deployment check on the held blue
placement, not additional independent training or validation data.

## What this experiment establishes

Across all 21,000 recorded diagnostic rows, median acquisition time was
18.760 ms (5th–95th percentile 18.164–19.288 ms), and median row interval was
24.324 ms (23.756–24.848 ms), roughly 41 rows/s. On the deployed model, the
more detailed `a` CSV had median row intervals of 28.7–28.8 ms, roughly
35 rows/s; median sensor acquisition remained 18.5 ms. These are measured
times, not the nominal 2 ms/channel target.

This tests stationary colour separation with the present fixture, lighting and
2 ms acquisition windows. Mixed-colour boundaries, twist, lateral play, tension,
lighting drift and shorter windows need separate validation. In particular,
2 m/s with at most 1 mm error after delay compensation requires transition
position uncertainty no greater than 0.5 ms. Whole sequential RGBC rows and
host receipt times cannot demonstrate that accuracy. `scan_us` and `row_us`
remain recorded for later timing work.

Checks: `python3 -m unittest discover -s tests`, `python3 tests/check_firmware.py`,
and Arduino CLI compilation for `arduino:avr:uno` (16,570 bytes flash, 883 bytes static RAM). Live Uno checks verified RGBC feature agreement with Python, classification agreement, the clear plot, the long-row handshake, and palette persistence through resets. The host firmware checks run
the actual sketch's feature/classifier/parser/EEPROM logic with hardware stubs;
they do not verify sensor timing. Synthetic test points never enter the measured
CSV or cluster figures.
