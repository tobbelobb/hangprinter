#!/usr/bin/env python3
"""Live swatch and change confirmation for the existing Uno `a` CSV stream.

Display filtering only: the sketch's instantaneous classifications are unchanged.
Separation and recent agreement are evidence scores, not probabilities.
"""
import argparse
import collections
import csv
from dataclasses import dataclass
import json
import math
from pathlib import Path
import queue
import threading
import time
import tkinter as tk
from tkinter import ttk

from palette_experiment import features, model_lines

ROOT = Path(__file__).resolve().parent
DEFAULT_MODEL = ROOT / 'data/palette_2026-10-06_analysis/palette_model.json'
COLOURS = {'Orange': '#ef8b2c', 'Black': '#20252a', 'Yellow': '#f3d347',
           'Blue': '#2865d7', 'Green': '#258552', 'Red': '#d63d43', 'Purple': '#8553ba'}


@dataclass
class Observation:
    when: float  # Uno scan-start time; confirmation is independent of GUI redraws.
    colour: str | None
    nearest: str | None
    margin: float
    radius_fraction: float | None
    clear_hz: float | None
    valid: bool
    scan_ms: float


def observation(row, model):
    """Decode firmware decisions; reject a model/firmware mismatch explicitly."""
    classes = model['classes']
    valid = int(row['valid']) == 1
    expected_basis = 1 if model['normalization'] == 'rgb' else 0
    if int(row['normalization']) != expected_basis:
        raise ValueError('Uno normalization differs from this palette. Deploy the matching model.')
    nearest, accepted = int(row['nearest_id']), int(row['class_id'])
    if nearest < -1 or nearest >= len(classes) or accepted not in (-1, nearest):
        raise ValueError('Uno class IDs differ from this palette.')
    if valid and nearest == -1:
        raise ValueError('No trained palette on the Uno. Deploy the model first.')
    if not valid and (accepted != -1 or nearest != -1):
        raise ValueError('Invalid reading has a colour assignment.')
    clear = float(row['clear100_Hz'])
    if not math.isfinite(clear) or clear < 0:
        clear = None
    margin = float(row['margin'])
    if not math.isfinite(margin) or not 0 <= margin <= 1:
        raise ValueError('Invalid separation score.')
    ratio = None
    if valid:
        clear, x = features(row, model['normalization'])
        z = [(v - m) * inv for v, m, inv in zip(x, model['mean'], model['inv_std'])]
        distances = [sum((v - c) ** 2 for v, c in zip(z, cl['centroid'])) for cl in classes]
        distance = float(row['distance2'])
        # Printed raw frequencies and AVR floats introduce small differences.
        if not math.isfinite(distance) or abs(distances[nearest] - distance) > max(.015, .01 * distance):
            raise ValueError('Uno centroids differ from this palette. Deploy the matching model.')
        ratio = distance / classes[nearest]['radius2']
    stamp, scan_ms = float(row['t_ms']) / 1000, float(row['scan_us']) / 1000
    if not math.isfinite(stamp) or not math.isfinite(scan_ms) or stamp < 0 or scan_ms < 0:
        raise ValueError('Invalid acquisition time.')
    return Observation(stamp, classes[accepted]['name'] if accepted >= 0 else None,
                       classes[nearest]['name'] if nearest >= 0 else None,
                       margin, ratio, clear, valid, scan_ms)


class ChangeFilter:
    """Confirm consecutive, accepted, separated readings over a minimum duration."""
    def __init__(self, hold_ms=100, samples=4, min_margin=.15):
        self.hold = hold_ms / 1000
        self.samples = samples
        self.min_margin = min_margin
        self.reset()

    def reset(self):
        self.stable = self.candidate = None
        self.count = self.changes = 0
        self.since = self.last = self.last_stable = None
        self.recent = collections.deque(maxlen=8)

    def update(self, item):
        if self.last is not None and item.when <= self.last:
            # Uno reset, duplicate or backwards time: never bridge a streak.
            self.reset()
        elif self.last is not None and item.when - self.last > .25:
            self.candidate = None
            self.count = 0
            self.since = None
            self.recent.clear()
        self.last = item.when
        qualifying = item.colour if item.valid and item.margin >= self.min_margin else None
        self.recent.append(item.colour if item.valid else None)
        if qualifying is None:
            self.candidate = self.since = None
            self.count = 0
            return None
        if qualifying != self.candidate:
            self.candidate, self.since, self.count = qualifying, item.when, 1
        else:
            self.count += 1
        if qualifying == self.stable:
            self.last_stable = item.when
            return None
        if self.count >= self.samples and item.when - self.since + 1e-9 >= self.hold:
            previous = self.stable
            self.stable, self.last_stable = qualifying, item.when
            if previous is not None:
                self.changes += 1
            return previous, qualifying
        return None

    def current(self, when):
        return self.stable is not None and self.last_stable is not None and when - self.last_stable <= .3

    def agreement(self, colour):
        return sum(c == colour for c in self.recent) / len(self.recent) if colour and self.recent else 0

    def progress(self):
        if self.since is None or self.last is None:
            return 0
        return min(1, self.count / self.samples, (self.last - self.since) / self.hold)


class FeedbackWindow:
    def __init__(self, root, args, model):
        self.root, self.args, self.model = root, args, model
        self.filter = ChangeFilter(args.hold_ms, args.samples, args.min_margin)
        self.events = queue.Queue(maxsize=512)
        self.stop = threading.Event()
        self.worker = None
        self.latest = None
        self.received = self.flash_until = 0
        self.origin = None
        root.title('Saltiga — live colour feedback')
        root.geometry('820x815')
        root.minsize(690,800)
        root.configure(bg='#f3f5f7')
        style = ttk.Style(root)
        style.theme_use('clam')
        style.configure('TFrame', background='#f3f5f7')
        style.configure('TLabel', background='#f3f5f7', foreground='#253342', font=('sans',11))
        style.configure('TButton', font=('sans',11), padding=6)
        style.configure('TProgressbar', troughcolor='#e1e6ec', background='#45799d', borderwidth=0)
        outer = ttk.Frame(root, padding=24)
        outer.pack(fill='both', expand=True)
        ttk.Label(outer, text='Saltiga · live colour', font=('sans',20,'bold')).pack(anchor='w')
        self.connection = tk.StringVar(value='Not connected')
        ttk.Label(outer, textvariable=self.connection, wraplength=760).pack(anchor='w',pady=(5,12))
        toolbar = ttk.Frame(outer)
        toolbar.pack(fill='x',pady=(0,16))
        self.port = tk.StringVar(value=args.port)
        ttk.Entry(toolbar, textvariable=self.port, width=24).pack(side='left')
        self.button = ttk.Button(toolbar,text='Connect',command=self.toggle)
        self.button.pack(side='left',padx=10)
        ttk.Label(toolbar,text=f'Confirm: {args.hold_ms:g} ms + {args.samples} readings').pack(side='right')
        self.swatch = tk.Canvas(outer,height=205,bg='#dce2e9',highlightthickness=0)
        self.swatch.pack(fill='x')
        self.swatch.bind('<Configure>',lambda _:self.draw_swatch())
        self.notice = tk.StringVar(value='Waiting for a steady colour')
        ttk.Label(outer,textvariable=self.notice,font=('sans',12,'bold')).pack(anchor='w',pady=(12,12))
        evidence = ttk.Frame(outer)
        evidence.pack(fill='x')
        self.instant = tk.Label(evidence,text='Instant reading: —',bg='#dce2e9',fg='#253342',font=('sans',12),padx=12,pady=8)
        self.instant.pack(side='left')
        self.health = tk.StringVar(value='Clear: —')
        ttk.Label(evidence,textvariable=self.health).pack(side='right')
        self.separation = tk.StringVar(value='Separation from next colour: —')
        ttk.Label(outer,textvariable=self.separation).pack(anchor='w',pady=(15,4))
        self.margin_bar = ttk.Progressbar(outer,maximum=1)
        self.margin_bar.pack(fill='x')
        self.agreement = tk.StringVar(value='Recent agreement: —')
        ttk.Label(outer,textvariable=self.agreement).pack(anchor='w',pady=(10,4))
        self.agreement_bar = ttk.Progressbar(outer,maximum=1)
        self.agreement_bar.pack(fill='x')
        self.fit = tk.StringVar(value='Training distance: —')
        ttk.Label(outer,textvariable=self.fit).pack(anchor='w',pady=(10,3))
        ttk.Label(outer,text='Evidence scores, not probabilities or confidence intervals.').pack(anchor='w')
        ttk.Label(outer,text='Confirmed changes',font=('sans',12,'bold')).pack(anchor='w',pady=(15,5))
        self.history = tk.Listbox(outer,height=4,font=('sans',11),bg='#ffffff',fg='#253342',borderwidth=0,highlightthickness=0,activestyle='none')
        self.history.pack(fill='both',expand=True)
        root.protocol('WM_DELETE_WINDOW',self.close)
        root.after(30,self.poll)
        if args.replay or not args.no_connect:
            root.after(100,self.toggle)

    @staticmethod
    def ink(colour):
        return '#17202b' if colour in ('Yellow','Orange') else '#ffffff'

    def draw_swatch(self):
        current = self.latest and time.monotonic()-self.received < 1 and self.filter.current(self.latest.when)
        name = self.filter.stable if current else None
        colour = COLOURS.get(name,'#dce2e9')
        self.swatch.configure(bg=colour)
        self.swatch.delete('all')
        width,height = self.swatch.winfo_width(),self.swatch.winfo_height()
        self.swatch.create_text(width/2,height/2-12,text=name or 'Uncertain',fill=self.ink(name) if name else '#253342',font=('sans',38,'bold'))
        detail = 'Confirmed colour' if name else (f'Last confirmed: {self.filter.stable}' if self.filter.stable else 'Waiting for a steady colour')
        self.swatch.create_text(width/2,height/2+40,text=detail,fill=self.ink(name) if name else '#253342',font=('sans',12))
        if time.monotonic()<self.flash_until:
            self.swatch.create_rectangle(4,4,width-4,height-4,outline=self.ink(name) if name else '#45799d',width=6)

    def toggle(self):
        if self.worker and self.worker.is_alive():
            self.stop.set()
            self.connection.set('Disconnecting…')
            self.button.configure(state='disabled')
            return
        self.filter.reset()
        self.latest = None
        self.origin = None
        self.history.delete(0,'end')
        self.stop.clear()
        self.button.configure(text='Disconnect')
        self.connection.set('Opening recorded samples…' if self.args.replay else f'Connecting to {self.port.get()}…')
        self.worker = threading.Thread(target=self.read_replay if self.args.replay else self.read_serial,args=(self.port.get(),),daemon=True)
        self.worker.start()

    def emit(self, kind, value):
        try:
            self.events.put_nowait((kind,value,time.monotonic()))
        except queue.Full:
            # Fail closed rather than silently confirming from dropped rows.
            self.stop.set()
            while True:
                try:
                    self.events.get_nowait()
                except queue.Empty:
                    break
            self.events.put_nowait(('error','Display cannot keep up. Reconnect for a fresh stream.',time.monotonic()))

    def read_serial(self, path):
        import serial
        port = None
        try:
            # IDE clients need not honour pyserial's exclusive lock.
            # Check current owners before opening; never close their sessions.
            import subprocess
            owner = subprocess.run(['fuser',path],capture_output=True,check=False)
            if owner.returncode == 0:
                raise RuntimeError('Port is in use. Close the IDE Monitor/Plotter, then Connect.')
            port = serial.Serial(path,115200,timeout=.2,exclusive=True)
            if self.stop.wait(2):
                return
            port.reset_input_buffer()
            port.write(b'a\n')
            port.flush()
            header = None
            deadline = time.monotonic()+6
            while not self.stop.is_set():
                line = port.readline().decode('ascii',errors='strict').strip()
                if time.monotonic()>deadline:
                    raise RuntimeError('No valid CSV stream. Check connection and upload the palette sketch.')
                if line.startswith('t_ms,'):
                    header = line.split(',')
                    continue
                if not header or not line or not line[0].isdigit():
                    continue
                values = line.split(',')
                if len(values)!=len(header):
                    continue
                item = observation(dict(zip(header,values)),self.model)
                deadline = time.monotonic()+3
                self.emit('sample',item)
        except Exception as error:
            self.emit('error',str(error))
        finally:
            if port is not None:
                try:
                    port.write(b'd\n')  # Return the Uno to the user's category plot.
                    port.flush()
                except Exception:
                    pass
                port.close()
            self.emit('closed',None)

    def read_replay(self, _):
        # Replay real raw observations; labels are never used as predictions.
        # Stop at EOF: no looping that could be mistaken for live sensing.
        try:
            stamp = 0.
            with self.args.replay.open(newline='') as source:
                for row in csv.DictReader(source):
                    if self.stop.wait(.03):
                        break
                    clear,x = features(row,self.model['normalization'])
                    z = [(v-m)*inv for v,m,inv in zip(x,self.model['mean'],self.model['inv_std'])]
                    distances = [sum((v-c)**2 for v,c in zip(z,cl['centroid'])) for cl in self.model['classes']]
                    ordered = sorted(range(len(distances)),key=distances.__getitem__)
                    nearest,second = ordered[:2]
                    d = distances[nearest]
                    margin = (distances[second]-d)/distances[second] if distances[second]>0 else 0
                    ratio = d/self.model['classes'][nearest]['radius2']
                    accepted = ratio<=1 and clear>=self.model.get('dark_clear_hz',0)
                    stamp += .03
                    name = self.model['classes'][nearest]['name']
                    self.emit('sample',Observation(stamp,name if accepted else None,name,margin,ratio,clear,True,float(row['scan_us'])/1000))
        except Exception as error:
            self.emit('error',str(error))
        finally:
            self.emit('closed',None)

    def display(self, item, received):
        self.latest,self.received = item,received
        if self.origin is None:
            self.origin = item.when
        change = self.filter.update(item)
        if change:
            previous,current = change
            self.flash_until = time.monotonic()+.8
            if previous:
                text = f'Change #{self.filter.changes} · {previous} → {current}'
            else:
                text = f'Initial lock · {current}'
            self.history.insert(0,f'{max(0,item.when-self.origin):7.2f} s   {text}')
            if self.history.size()>30:
                self.history.delete(30,'end')
        name = item.colour
        self.instant.configure(text=f'Instant reading: {name or "Unknown"}',bg=COLOURS.get(name,'#dce2e9'),fg=self.ink(name) if name else '#253342')
        self.separation.set(f'Separation from next colour: {item.margin:.0%}' if item.valid else 'Separation: unavailable — invalid reading')
        self.margin_bar['value'] = item.margin if item.valid else 0
        agreement = self.filter.agreement(name)
        self.agreement.set(f'Recent agreement with {name}: {agreement:.0%} of {len(self.filter.recent)} readings' if name else 'Recent accepted agreement: unavailable')
        self.agreement_bar['value'] = agreement
        self.fit.set(f'Training distance: {item.radius_fraction:.2f}× acceptance radius²' if item.radius_fraction is not None else 'Training distance: unavailable')
        clear = f'{item.clear_hz:,.0f} Hz' if item.clear_hz is not None else 'unavailable'
        self.health.set(f'Absolute clear: {clear}\nAcquisition: {item.scan_ms:.1f} ms')
        if not item.valid:
            self.notice.set('Invalid reading · confirmation interrupted')
        elif not name:
            self.notice.set(f'Unknown · nearest {item.nearest or "unavailable"}, outside acceptance')
        elif item.margin<self.args.min_margin:
            self.notice.set(f'Ambiguous {name} · waiting for clearer separation')
        elif self.filter.candidate != self.filter.stable:
            elapsed = 1000*(item.when-self.filter.since)
            self.notice.set(f'Possible {name} · {self.filter.count}/{self.args.samples} readings · {elapsed:.0f}/{self.args.hold_ms:g} ms')
        else:
            self.notice.set(f'Holding {name} · {self.filter.changes} confirmed changes')
        prefix = 'RECORDED SAMPLES · not live' if self.args.replay else f'Live · {self.port.get()} · 115200 baud'
        self.connection.set(prefix)

    def poll(self):
        for _ in range(512):
            try:
                kind,value,received = self.events.get_nowait()
            except queue.Empty:
                break
            if kind=='sample':
                self.display(value,received)
            elif kind=='error':
                self.connection.set(value)
                self.notice.set('Connection stopped · no current colour')
                self.received = 0
            elif kind=='closed':
                self.button.configure(text='Replay' if self.args.replay else 'Connect',state='normal')
                self.received = 0
                self.notice.set('Recording ended' if self.args.replay else 'Disconnected · no current colour')
        if self.latest and time.monotonic()-self.received>1:
            self.margin_bar['value'] = self.agreement_bar['value'] = 0
            self.instant.configure(text='Instant reading: unavailable',bg='#dce2e9',fg='#253342')
            self.separation.set('Separation: unavailable')
            self.agreement.set('Recent agreement: unavailable')
            self.fit.set('Training distance: unavailable')
            self.health.set('Absolute clear: unavailable')
            if self.worker and self.worker.is_alive():
                self.notice.set('No fresh data · no current colour')
        self.draw_swatch()
        self.root.after(30,self.poll)

    def close(self):
        self.stop.set()
        if self.worker:
            self.worker.join(timeout=.6)
        self.root.destroy()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--port',default='/dev/ttyACM0')
    parser.add_argument('--model',type=Path,default=DEFAULT_MODEL)
    parser.add_argument('--hold-ms',type=float,default=100)
    parser.add_argument('--samples',type=int,default=4)
    parser.add_argument('--min-margin',type=float,default=.15)
    parser.add_argument('--no-connect',action='store_true',help='Open without acquiring the serial port')
    parser.add_argument('--replay',type=Path,help='Preview saved raw captures, visibly labelled as recorded')
    args = parser.parse_args()
    if not math.isfinite(args.hold_ms) or args.hold_ms<=0 or args.samples<2 or not 0<=args.min_margin<=1:
        parser.error('Use positive hold-ms, at least two samples and min-margin between zero and one')
    model = json.loads(args.model.read_text())
    model_lines(model)  # Reuse the deployment validator.
    if not model.get('palette_ready'):
        parser.error('Use a complete trained palette')
    root = tk.Tk()
    FeedbackWindow(root,args,model)
    root.mainloop()


if __name__ == '__main__':
    main()
