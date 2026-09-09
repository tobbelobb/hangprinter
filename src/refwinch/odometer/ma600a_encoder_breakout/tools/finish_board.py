#!/usr/bin/python3
import os,pathlib
for k,v in [('XDG_CONFIG_HOME','config'),('XDG_CACHE_HOME','cache'),('XDG_DATA_HOME','data')]:os.environ[k]='/tmp/ma600-kicad/'+v
import pcbnew as p
R=pathlib.Path(__file__).resolve().parents[1];fn=R/'kicad/MA600A-RefWinch-Encoder.kicad_pcb';fn.write_text(''.join(line for line in fn.read_text().splitlines(True) if '(via (at 104.5 108.6)' not in line)); b=p.LoadBoard(str(fn)); ds=b.GetDesignSettings()
def v(x,y):return p.VECTOR2I(p.FromMM(100+x),p.FromMM(100+y))
_ = p.BOARD_DESIGN_SETTINGS
ds.m_SolderMaskExpansion=p.FromMM(.05);ds.m_SolderMaskMinWidth=p.FromMM(.1)
for l in [p.F_Cu,p.B_Cu]:
 z=p.ZONE(b);z.SetLayer(l);z.SetNetCode(b.GetNetcodeFromNetname('GND'));z.SetLocalClearance(p.FromMM(.2));z.SetThermalReliefGap(p.FromMM(.2));z.SetThermalReliefSpokeWidth(p.FromMM(.25));z.SetPadConnection(p.ZONE_CONNECTION_THERMAL);z.SetMinThickness(p.FromMM(.2));z.SetZoneName('GND behind magnetic keepout')
 o=z.Outline();o.NewOutline()
 for x,y in [(9.1,.3),(27.7,.3),(27.7,11.7),(9.1,11.7)]:o.Append(v(x,y).x,v(x,y).y)
 b.Add(z)
# Mark revision and both pin-1 locations on visible silkscreen.
for text,x,y,size in [('MA600A v0.3',5.5,1.35,.8),('1',2.1,4,.8),('1',22.2,10.2,.8)]:
 t=p.PCB_TEXT(b);t.SetText(text);t.SetPosition(v(x,y));t.SetLayer(p.F_SilkS);t.SetTextSize(p.VECTOR2I(p.FromMM(size),p.FromMM(size)));t.SetTextThickness(p.FromMM(.12));b.Add(t)
ds.SetAuxOrigin(v(0,12));p.ZONE_FILLER(b).Fill(b.Zones());p.SaveBoard(str(fn),b)
p.WriteDRCReport(b,str(R/'analysis/DRC.txt'),p.EDA_UNITS_MILLIMETRES,True)
print((R/'analysis/DRC.txt').read_text())
