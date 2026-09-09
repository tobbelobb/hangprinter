#!/usr/bin/env python3
"""Package the reviewed release without modifying native design sources."""
from pathlib import Path
import zipfile,hashlib,json
r=Path(__file__).resolve().parents[1];o=r/'release'
source=o/'MA600A-v0.3-KiCad-sources.zip'
with zipfile.ZipFile(source,'w',zipfile.ZIP_DEFLATED) as z:
 for p in sorted((r/'kicad').rglob('*')):
  if p.is_file() and p.suffix not in ['.kicad_prl','.zip'] and not p.name.endswith('.lck'):z.write(p,Path('kicad')/p.relative_to(r/'kicad'))
 z.write(r/'hardware/netlist.csv','reference/handoff-netlist.csv')
 z.writestr('README.txt','MA600A v0.3, 2026-09-09. Open kicad/MA600A-RefWinch-Encoder.kicad_pro.\nKiCad 10.0.6 checked sources and self-contained libraries. See the accompanying order instructions and design review for prototype limits and manufacturing settings.\n')
# A tight list prevents historical reports or construction intermediates entering the order.
names=['MA600A-v0.3-Gerbers.zip',source.name,'BOM.csv','Pick-and-place.csv','Pin-verification.csv','Assembly-drawing.pdf','Schematic.pdf','ORDER-INSTRUCTIONS.md','Design-review.md','ERC-review.md','First-article-checklist.md','DRC.txt','DRC.json','ERC.txt','ERC.json','Verification.json','Gerber-preview-top.png','Gerber-preview-bottom.png','Paste-preview.png','Mask-openings-preview.png']
for n in names:assert (o/n).is_file(),n
checks=''.join(hashlib.sha256((o/n).read_bytes()).hexdigest()+'  '+n+'\n' for n in names)
(o/'SHA256SUMS.txt').write_text(checks)
package=o/'MA600A-v0.3-Order-package.zip'
with zipfile.ZipFile(package,'w',zipfile.ZIP_DEFLATED) as z:
 for n in names+['SHA256SUMS.txt']:z.write(o/n,n)
for p in [source,o/'MA600A-v0.3-Gerbers.zip',package]:
 with zipfile.ZipFile(p) as z:
  assert z.testzip() is None
  assert all(not n.startswith('/') and '..' not in Path(n).parts for n in z.namelist())
  print(p.name,len(z.namelist()),'files; CRC OK;',p.stat().st_size,'bytes')
(o/'Order-package.sha256').write_text(hashlib.sha256(package.read_bytes()).hexdigest()+'  '+package.name+'\n')
