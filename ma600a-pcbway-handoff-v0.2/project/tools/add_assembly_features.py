import os,pathlib,uuid,re,math
for k,v in [('XDG_CONFIG_HOME','config'),('XDG_CACHE_HOME','cache'),('XDG_DATA_HOME','data')]:os.environ[k]='/tmp/ma600-kicad/'+v
import pcbnew as p
R=pathlib.Path(__file__).resolve().parents[1];D=R/'kicad';N='MA600A-RefWinch-Encoder';b=p.LoadBoard(str(D/(N+'.kicad_pcb')))
def v(x,y):return p.VECTOR2I(p.FromMM(100+x),p.FromMM(100+y))
def uid(s):return str(uuid.uuid5(uuid.NAMESPACE_URL,'hangprinter/ma600a/v0.3/'+s))
fname='Fiducial_0.6mm_Mask1.1mm';foot=f'''(footprint "{fname}" (version 20221018)(generator pcbnew)(layer "F.Cu")(attr smd exclude_from_pos_files exclude_from_bom) (fp_text reference "REF**"(at 0 1.5)(layer "F.Fab")(effects(font(size .8 .8)(thickness .12)))) (fp_text value "Fiducial"(at 0 -1.5)(layer "F.Fab")hide(effects(font(size .8 .8)(thickness .12)))) (pad "" smd circle(at 0 0)(size 1 1)(layers "F.Cu" "F.Mask")(solder_mask_margin .5)))'''
(D/'RefWinch.pretty'/f'{fname}.kicad_mod').write_text(foot)
sch=(D/(N+'.kicad_sch')).read_text();rootid=uid('schematic')
sym='''(symbol "Fiducial"(in_bom no)(on_board yes)(property "Reference" "FID"(at 0 2 0)(effects(font(size 1 1))))(property "Value" "Fiducial"(at 0 -2 0)(effects(font(size 1 1))))(symbol "Fiducial_0_1"(circle(center 0 0)(radius 1)(stroke(width .25)(type default))(fill(type none)))))'''
flag='''(symbol "PWR_FLAG"(power)(pin_names(offset 0)hide)(in_bom no)(on_board no)(property "Reference" "#FLG"(at 0 0 0)(effects(font(size 1 1))hide))(property "Value" "PWR_FLAG"(at 0 2.5 0)(effects(font(size 1 1))))(symbol "PWR_FLAG_0_1"(polyline(pts(xy 0 0)(xy 0 1.27)(xy -1.27 1.905)(xy 0 2.54)(xy 1.27 1.905)(xy 0 1.27))(stroke(width .2)(type default))(fill(type none))))(symbol "PWR_FLAG_1_1"(pin power_out line(at 0 0 90)(length 0)(name "pwr"(effects(font(size 1 1))))(number "1"(effects(font(size 1 1)))))))'''
lib=D/'RefWinch.kicad_sym';s=lib.read_text();lib.write_text(s.rstrip()[:-1]+sym+flag+')')
sch=sch.replace('(lib_symbols ','(lib_symbols '+sym.replace('"Fiducial"','"RefWinch:Fiducial"',1)+flag.replace('"PWR_FLAG"','"RefWinch:PWR_FLAG"',1),1)
instances=''
for i,(x,y) in enumerate([(11,1),(15.8,11),(20,5)],1):
 ref='FID'+str(i);fp=p.FootprintLoad(str(D/'RefWinch.pretty'),fname);b.Add(fp);fp.SetReference(ref);fp.SetPosition(v(x,y));fp.SetPath(p.KIID_PATH('/'+rootid+'/'+uid(ref)));fp.SetFPID(p.LIB_ID('RefWinch',fname));fp.Reference().SetVisible(False)
 sx=25.4+i*12.7;sy=114.3
 instances+=f'''(symbol(lib_id "RefWinch:Fiducial")(at {sx} {sy} 0)(unit 1)(in_bom no)(on_board yes)(dnp no)(uuid {uid(ref)})(property "Reference" "{ref}"(at {sx} {sy-3} 0)(effects(font(size 1 1))))(property "Value" "Fiducial"(at {sx} {sy+3} 0)(effects(font(size 1 1))))(property "Footprint" "RefWinch:{fname}"(at {sx} {sy} 0)(effects(font(size 1 1))hide))(instances(project "{N}"(path "/{rootid}"(reference "{ref}")(unit 1)))))'''
for i,net in enumerate(['+5V_IN','GND'],1):
 ref='#FLG0'+str(i);sx=30.48+i*20.32;sy=76.2
 instances+=f'''(symbol(lib_id "RefWinch:PWR_FLAG")(at {sx} {sy} 0)(unit 1)(in_bom no)(on_board no)(dnp no)(uuid {uid(ref)})(property "Reference" "{ref}"(at {sx} {sy} 0)(effects(font(size 1 1))hide))(property "Value" "PWR_FLAG"(at {sx} {sy-4} 0)(effects(font(size 1 1))))(pin "1"(uuid {uid(ref+'pin')}))(instances(project "{N}"(path "/{rootid}"(reference "{ref}")(unit 1))))) (global_label "{net}"(shape bidirectional)(at {sx} {sy} 0)(effects(font(size 1 1))(justify left bottom))(uuid {uid(ref+'label')}))'''
(D/(N+'.kicad_sch')).write_text(sch.rstrip()[:-1]+instances+')')
# Stitch copper outside the magnetic region at candidates that satisfy clearance.
# Use real native DRC after this step; candidate screening uses conservative bounding boxes.
from math import hypot
pads=[pad for fp in b.GetFootprints() for pad in fp.Pads() if pad.IsOnLayer(p.F_Cu)]
tracks=list(b.GetTracks());gnd=b.GetNetcodeFromNetname('GND');placed=[]
def mm(pt):return p.ToMM(pt.x)-100,p.ToMM(pt.y)-100
def pointseg(x,y,a,c):
 ax,ay=mm(a);cx,cy=mm(c);dx=cx-ax;dy=cy-ay;t=max(0,min(1,((x-ax)*dx+(y-ay)*dy)/max(dx*dx+dy*dy,1e-12)));return hypot(x-ax-t*dx,y-ay-t*dy)
for x,y in [(x,y) for x in [9.7,11.7,13.7,15.7,17.7,19.7,21.7,23.7,26.7] for y in [.7,3.5,6,8.5,11.3]]:
 if hypot(x-4,y-6)<5.7:continue
 if x>22 and y>1 and y<11:continue # connector body
 good=True
 for pd in pads:
  px,py=mm(pd.GetPosition());sz=pd.GetSize();w,h=p.ToMM(sz.x),p.ToMM(sz.y)
  if round(pd.GetOrientationDegrees())%180:w,h=h,w
  d=hypot(max(abs(x-px)-w/2,0),max(abs(y-py)-h/2,0))
  if d<.65:good=False;break
 if not good:continue
 for tr in tracks:
  if isinstance(tr,p.PCB_VIA):
   tx,ty=mm(tr.GetPosition())
   if hypot(x-tx,y-ty)<.7:good=False;break
  elif tr.GetNetCode()!=gnd and pointseg(x,y,tr.GetStart(),tr.GetEnd())<.5+p.ToMM(tr.GetWidth())/2:good=False;break
 if not good:continue
 via=p.PCB_VIA(b);via.SetPosition(v(x,y));via.SetWidth(p.FromMM(.6));via.SetDrill(p.FromMM(.3));via.SetViaType(p.VIATYPE_THROUGH);via.SetLayerPair(p.F_Cu,p.B_Cu);via.SetNetCode(gnd);b.Add(via);placed.append((x,y))
p.ZONE_FILLER(b).Fill(b.Zones());p.SaveBoard(str(D/(N+'.kicad_pcb')),b);p.WriteDRCReport(b,str(R/'analysis/DRC.txt'),p.EDA_UNITS_MILLIMETRES,True)
print('Added stitching:',placed);print((R/'analysis/DRC.txt').read_text())
