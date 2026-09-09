import os,pathlib
for k,v in [('XDG_CONFIG_HOME','config'),('XDG_CACHE_HOME','cache'),('XDG_DATA_HOME','data')]:os.environ[k]='/tmp/ma600-kicad/'+v
import pcbnew as p
R=pathlib.Path(__file__).resolve().parents[1];fn=R/'kicad/MA600A-RefWinch-Encoder.kicad_pcb';b=p.LoadBoard(str(fn))
def v(x,y):return p.VECTOR2I(p.FromMM(100+x),p.FromMM(100+y))
for t in b.GetDrawings():
 if not isinstance(t,p.PCB_TEXT):continue
 if t.GetText()=='3V3':t.SetPosition(v(20.5,2.7))
 if t.GetText()=='CIPO':t.SetPosition(v(20,11.15))
 if t.GetText()=='COPI':t.SetPosition(v(16.8,10));t.SetTextAngle(p.EDA_ANGLE(90,p.DEGREES_T))
 if t.GetText()=='1' and p.ToMM(t.GetPosition().x)>120:t.SetPosition(v(23.6,10.2))
p.SaveBoard(str(fn),b);p.WriteDRCReport(b,str(R/'analysis/DRC.txt'),p.EDA_UNITS_MILLIMETRES,True);print((R/'analysis/DRC.txt').read_text())
