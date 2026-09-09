import os,pathlib
for k,v in [('XDG_CONFIG_HOME','config'),('XDG_CACHE_HOME','cache'),('XDG_DATA_HOME','data')]:os.environ[k]='/tmp/ma600-kicad/'+v
import pcbnew as p
R=pathlib.Path(__file__).resolve().parents[1];fn=R/'kicad/MA600A-RefWinch-Encoder.kicad_pcb';s=fn.read_text();fn.write_text(''.join(l for l in s.splitlines(True) if '(via (at 117.7 111.3)' not in l));b=p.LoadBoard(str(fn))
for fp in b.GetFootprints():
 if fp.GetReference()=='FID2':fp.SetPosition(p.VECTOR2I(p.FromMM(115),p.FromMM(111)))
 if fp.GetReference().startswith('FID'):
  for pd in fp.Pads():pd.SetSize(p.VECTOR2I(p.FromMM(.6),p.FromMM(.6)));pd.SetLocalSolderMaskMargin(p.FromMM(.25));pd.SetLocalClearance(p.FromMM(.35))
# Keep local library dimensions synchronized.
lib=R/'kicad/RefWinch.pretty/Fiducial_0.6mm_Mask1.1mm.kicad_mod';s=lib.read_text().replace('(size 1 1)','(size .6 .6)').replace('(solder_mask_margin .5)','(solder_mask_margin .25)(clearance .35)');lib.write_text(s)
p.ZONE_FILLER(b).Fill(b.Zones());p.SaveBoard(str(fn),b);p.WriteDRCReport(b,str(R/'analysis/DRC.txt'),p.EDA_UNITS_MILLIMETRES,True);print((R/'analysis/DRC.txt').read_text())
