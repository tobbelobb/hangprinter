#!/usr/bin/env python3
"""Preview actual exported Gerbers (requires gerbonara and cairosvg)."""
from pathlib import Path
from gerbonara import LayerStack
import cairosvg
r=Path(__file__).resolve().parents[1]/'release'; s=LayerStack.open(r/'gerbers')
for name,colors in [
 ('Gerber-preview-top',{'top copper':'#b66f18','top silk':'#164fc7','drill pth':'white'}),
 ('Gerber-preview-bottom',{'bottom copper':'#b66f18','drill pth':'white'}),
 ('Paste-preview',{'top paste':'#303030'}),
 ('Mask-openings-preview',{'top mask':'#303030'})]:
 colors['mechanical outline']='#777777'
 svg=str(s.to_svg(colors=colors,margin=1))
 (r/(name+'.svg')).write_text(svg)
 cairosvg.svg2png(bytestring=svg.encode(),write_to=str(r/(name+'.png')),output_width=1680,background_color='white')
