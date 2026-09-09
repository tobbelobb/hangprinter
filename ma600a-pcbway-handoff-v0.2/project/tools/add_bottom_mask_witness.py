#!/usr/bin/env python3
"""Add a deliberate bottom-mask opening around an existing GND stitching via.

PCBWay's audit treats an otherwise-empty bottom solder-mask Gerber as missing.
This opening is on an existing GND via, far from the sensor and components, so
the board keeps a fully masked bottom except for this useful probe point.
"""
import os
from pathlib import Path

for key, value in [('XDG_CONFIG_HOME', 'config'), ('XDG_CACHE_HOME', 'cache'), ('XDG_DATA_HOME', 'data')]:
    os.environ[key] = '/tmp/ma600-kicad/' + value

import pcbnew as p

root = Path(__file__).resolve().parents[1]
board_path = root / 'kicad' / 'MA600A-RefWinch-Encoder.kicad_pcb'
board = p.LoadBoard(str(board_path))

# Existing GND stitching via, board coordinates in the native lower-left datum.
x_mm, y_mm = 119.7, 103.5
for item in board.GetTracks():
    if isinstance(item, p.PCB_VIA) and item.GetNetname() == 'GND':
        x = p.ToMM(item.GetPosition().x)
        y = p.ToMM(item.GetPosition().y)
        if abs(x - x_mm) < 0.01 and abs(y - y_mm) < 0.01:
            break
else:
    raise RuntimeError('Expected GND stitching via was not found')

# Idempotence: do not add another witness if this board already has it.
for drawing in board.GetDrawings():
    if drawing.GetLayer() == p.B_Mask and abs(p.ToMM(drawing.GetPosition().x) - x_mm) < 0.01 and abs(p.ToMM(drawing.GetPosition().y) - y_mm) < 0.01:
        print('Bottom-mask witness already present')
        raise SystemExit(0)

witness = p.PCB_SHAPE(board)
witness.SetShape(p.SHAPE_T_CIRCLE)
witness.SetLayer(p.B_Mask)
witness.SetFilled(True)
witness.SetWidth(0)
witness.SetCenter(p.VECTOR2I(p.FromMM(x_mm), p.FromMM(y_mm)))
witness.SetRadius(p.FromMM(0.35))
board.Add(witness)
p.SaveBoard(str(board_path), board)
print('Added 0.70 mm bottom-mask opening around GND via at (119.7, 103.5) mm')
