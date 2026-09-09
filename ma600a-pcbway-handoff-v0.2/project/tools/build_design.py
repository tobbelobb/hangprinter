#!/usr/bin/python3
"""Rebuild editable first-article KiCad sources from the handoff netlist.
Run using system Python with KiCad pcbnew installed. Routing is a separate step.
"""
import os, pathlib, csv, uuid, json, math, shutil
for k,v in [('XDG_CONFIG_HOME','config'),('XDG_CACHE_HOME','cache'),('XDG_DATA_HOME','data')]: os.environ[k]='/tmp/ma600-kicad/'+v
import pcbnew as p
ROOT=pathlib.Path(__file__).resolve().parents[1]; OUT=ROOT/'kicad'; OUT.mkdir(exist_ok=True)
NAME='MA600A-RefWinch-Encoder'; LIB='RefWinch'; pretty=OUT/(LIB+'.pretty'); pretty.mkdir(exist_ok=True)
def uid(s): return str(uuid.uuid5(uuid.NAMESPACE_URL,'hangprinter/ma600a/v0.3/'+s))
def q(s): return json.dumps(str(s))
rows=list(csv.DictReader(open(ROOT/'hardware/netlist.csv')))
netmap={(r['ref'],r['pin']):r['net'] for r in rows}
# Catalog parts; suffix D denotes tape packaging.
parts={
'U1':('MA600A','MA600AGQE-0000-Z','Monolithic Power Systems','MA600A_QFN16_3x3_EP1.7',4,6,0,'https://www.monolithicpower.com/en/ma600a.html'),
'U2':('MP20056GJ-33','MP20056GJ-33-Z','Monolithic Power Systems','MP20056_TSOT23_5',14,6,0,'https://www.monolithicpower.com/en/mp20056.html'),
'J1':('JST-GH-6','SM06B-GHS-TB(LF)(SN)','JST','JST_GH_SM06B-GHS-TB_1x06-1MP_P1.25mm_Horizontal',24.5,6,90,'https://www.jst-mfg.com/product/pdf/eng/eGH.pdf'),
'C1':('2.2uF','GRM188R71A225KE15D','Murata','C_0603_1608Metric',14,2.7,0,'https://www.murata.com/'),
'C2':('4.7uF','GRM188Z71A475KE15D','Murata','C_0603_1608Metric',14,9.2,0,'https://www.murata.com/'),
'C3':('1uF','GRM155Z71A105KE01D','Murata','C_0402_1005Metric',10.5,3,90,'https://www.murata.com/'),
'C4':('0.1uF','GRM155R71C104KA88D','Murata','C_0402_1005Metric',10.5,5.5,90,'https://www.murata.com/')}
for i,xy in enumerate([(18,2),(18,4),(18,6),(18,8),(18,10),(20,10),(20,1.5)],1):
 parts['TP'+str(i)]=(next(r['pin_name'] for r in rows if r['ref']=='TP'+str(i)),'','PCB feature','Pogo_1mm',*xy,0,'')
# Custom footprints reproduce MPS recommended patterns. Coordinates use KiCad top view.
def fptext(n,x,y,layer='F.SilkS'): return f'(fp_text reference "REF**" (at {x} {y}) (layer "{layer}") (effects (font (size 0.7 0.7) (thickness 0.12))))'
def line(a,b,layer): return f'(fp_line (start {a[0]} {a[1]}) (end {b[0]} {b[1]}) (stroke (width 0.1) (type solid)) (layer "{layer}"))'
def rect(x,y,layer): return ''.join(line(a,b,layer) for a,b in zip([(-x,-y),(x,-y),(x,y),(-x,y)],[ (x,-y),(x,y),(-x,y),(-x,-y)]))
def pad(n,x,y,w,h,layers='F.Cu F.Paste F.Mask'):
 return f'(pad "{n}" smd rect (at {x} {y}) (size {w} {h}) (layers {layers}))'
def custom(n,pads,body,cy):
 s=f'(footprint "{n}" (version 20221018) (generator pcbnew) (layer "F.Cu") (attr smd) '+fptext(n,0,-cy[1]-.6)+f'(fp_text value "{n}" (at 0 {cy[1]+.6}) (layer "F.Fab") (effects (font (size .7 .7) (thickness .1))))'+rect(*body,'F.Fab')+rect(*cy,'F.CrtYd')+''.join(pads)+')'
 (pretty/(n+'.kicad_mod')).write_text(s)
pads=[]
for i,t in enumerate([-.75,-.25,.25,.75]): pads.append(pad(i+1,-1.45,t,.7,.25))
for i,t in enumerate([-.75,-.25,.25,.75]): pads.append(pad(i+5,t,1.45,.25,.7))
for i,t in enumerate([.75,.25,-.25,-.75]): pads.append(pad(i+9,1.45,t,.7,.25))
for i,t in enumerate([.75,.25,-.25,-.75]): pads.append(pad(i+13,t,-1.45,.25,.7))
pads.append(pad(17,0,0,1.7,1.7,'F.Cu F.Mask'))
# Four paste windows, 68% total exposed-pad coverage; no electrical connection/vias.
for x in [-.4,.4]:
 for y in [-.4,.4]: pads.append(pad('',x,y,.7,.7,'F.Paste'))
custom(parts['U1'][3],pads,(1.5,1.5),(2.05,2.05))
custom(parts['U2'][3],[pad(n,x,y,1.2,.6) for n,x,y in [(1,-1.3,-.95),(2,-1.3,0),(3,-1.3,.95),(4,1.3,.95),(5,1.3,-.95)]],(.8,1.45),(2.15,1.7))
(pretty/'Pogo_1mm.kicad_mod').write_text('(footprint "Pogo_1mm" (version 20221018) (generator pcbnew) (layer "F.Cu") (attr smd exclude_from_pos_files exclude_from_bom) '+fptext('',0,-.95)+'(fp_text value "Pogo" (at 0 1) (layer "F.Fab") (effects (font (size .5 .5) (thickness .1)))) (pad "1" smd circle (at 0 0) (size 1 1) (layers "F.Cu" "F.Mask"))'+rect(.7,.7,'F.CrtYd')+')')
for group,fn in [('Connector_JST',parts['J1'][3]),('Capacitor_SMD','C_0603_1608Metric'),('Capacitor_SMD','C_0402_1005Metric')]:
 shutil.copyfile('/usr/share/kicad/footprints/'+group+'.pretty/'+fn+'.kicad_mod',pretty/(fn+'.kicad_mod'))
(OUT/'fp-lib-table').write_text(f'(fp_lib_table (lib (name "{LIB}")(type "KiCad")(uri "${{KIPRJMOD}}/{LIB}.pretty")(options "")(descr "Project-local footprints")))\n')
# Self-contained modern schematic, functional pin types and explicit wires/NCs.
syms={}; pincoords={}
for ref,part in parts.items():
 rr=[r for r in rows if r['ref']==ref]; n=len(rr); sym=ref if ref.startswith(('U','J')) else ('C' if ref.startswith('C') else 'TP')
 if sym in syms: continue
 coords={}; geometry=''; pins=''
 if sym=='C':
  coords={'1':(0,3.81,270),'2':(0,-3.81,90)}
  geometry='(polyline (pts (xy -2.032 .762)(xy 2.032 .762)) (stroke (width .254)(type default))(fill(type none))) (polyline (pts (xy -2.032 -.762)(xy 2.032 -.762)) (stroke (width .254)(type default))(fill(type none)))'
 elif sym=='TP':
  coords={'1':(0,-2.54,90)}; geometry='(circle (center 0 0)(radius .8)(stroke(width .254)(type default))(fill(type none)))'
 else:
  left=rr[:(n+1)//2]; right=rr[(n+1)//2:]; h=max(len(left),len(right))*2.54/2+1.27
  geometry=f'(rectangle (start -10.16 {h})(end 10.16 {-h})(stroke(width .254)(type default))(fill(type background)))'
  for side,seq in [(-1,left),(1,right)]:
   for i,r in enumerate(seq): coords[r['pin']]=(side*15.24,(len(seq)-1)*1.27-i*2.54,0 if side==-1 else 180)
 for r in rr:
  x,y,ang=coords[r['pin']]; typ='passive'
  if ref=='U1': typ='power_in' if r['pin'] in ['8','13','14'] else ('no_connect' if r['pin'] in ['16','17'] else ('input' if r['pin'] in ['4','5','10','12'] else ('output' if r['pin'] in ['7','11'] else 'bidirectional')))
  if ref=='U2': typ={'1':'power_in','2':'power_in','3':'input','4':'input','5':'power_out'}[r['pin']]
  length=3.048 if sym=='C' else (2.54 if sym=='TP' else 5.08)
  name='~' if sym=='TP' else (r['pin_name'] or '~')
  pins+=f'(pin {typ} line (at {x} {y} {ang})(length {length})(name {q(name)} (effects(font(size 1 1))))(number {q(r["pin"])} (effects(font(size 1 1)))))'
 syms[sym]=f'(symbol "{sym}" (pin_names(offset .6)) (in_bom yes)(on_board yes) (property "Reference" "{ref.rstrip("1234567890")}" (at 0 0 0)(effects(font(size 1.27 1.27)))) (property "Value" "{sym}" (at 0 -2.54 0)(effects(font(size 1.27 1.27)))) (symbol "{sym}_0_1" {geometry}) (symbol "{sym}_1_1" {pins}))'
 pincoords[sym]=coords
(OUT/(LIB+'.kicad_sym')).write_text('(kicad_symbol_lib (version 20220914)(generator kicad_symbol_editor)'+''.join(syms.values())+')')
(OUT/'sym-lib-table').write_text(f'(sym_lib_table (lib (name "{LIB}")(type "KiCad")(uri "${{KIPRJMOD}}/{LIB}.kicad_sym")(options "")(descr "Datasheet-derived symbols")))')
rootid=uid('schematic'); sch=f'(kicad_sch (version 20230121)(generator eeschema)(uuid {rootid})(paper "A4")(title_block(title "MA600A RefWinch Encoder")(date "2026-09-09")(rev "0.3")(comment 1 "5 V input; 3.3 V ABZ; 5-board first article")) (lib_symbols '+''.join(s.replace(f'(symbol "{k}"',f'(symbol "{LIB}:{k}"',1) for k,s in syms.items())+')'
placements={'U2':(60.96,48.26),'U1':(139.7,93.98),'J1':(238.76,93.98),'C1':(20.32,53.34),'C2':(96.52,53.34),'C3':(109.22,127),'C4':(139.7,127)}
for i in range(1,8): placements['TP'+str(i)]=(30.48+(i-1)*27.94,157.48)
for ref,part in parts.items():
 sym=ref if ref.startswith(('U','J')) else ('C' if ref.startswith('C') else 'TP'); x,y=placements[ref]; rr=[r for r in rows if r['ref']==ref]
 sch+=f'(symbol (lib_id "{LIB}:{sym}")(at {x} {y} 0)(unit 1)(in_bom {"no" if ref.startswith("TP") else "yes"})(on_board yes)(dnp no)(uuid {uid(ref)})'
 props=[('Reference',ref),('Value',part[0]),('Footprint',LIB+':'+part[3]),('Datasheet',part[7]),('MPN',part[1]),('Manufacturer',part[2])]
 h=(len(rr)+1)//2*1.27+3 if sym not in ['C','TP'] else 5
 for idx,(k,v) in enumerate(props):
  py=y-h-idx*2 if idx<2 else y
  sch+=f'(property {q(k)} {q(v)} (at {x} {py} 0)(effects(font(size 1.1 1.1)){" hide" if idx>1 else ""}))'
 for r in rr: sch+=f'(pin {q(r["pin"])}(uuid {uid(ref+"pin"+r["pin"])}))'
 sch+=f'(instances(project "{NAME}"(path "/{rootid}"(reference "{ref}")(unit 1)))))'
 for r in rr:
  dx,dy,ang=pincoords[sym][r['pin']]; px,py=x+dx,y-dy
  if r['net']=='NC': sch+=f'(no_connect(at {px} {py})(uuid {uid(ref+r["pin"]+"nc")}))'; continue
  ex=px+(-5.08 if ang==0 else 5.08 if ang==180 else 0); ey=py+(-5.08 if ang==270 else 5.08 if ang==90 else 0)
  sch+=f'(wire(pts(xy {px} {py})(xy {ex} {ey}))(stroke(width 0)(type default))(uuid {uid(ref+r["pin"]+"wire")}))'
  sch+=f'(global_label {q(r["net"])}(shape bidirectional)(at {ex} {ey} {180 if ang==0 else 0})(effects(font(size 1 1))(justify {"right" if ang==0 else "left"}))(uuid {uid(ref+r["pin"]+"label")}))'
for text,x,y in [('POWER: nominal 5 V; do not feed 3V3 pad externally',25.4,25.4),('SENSOR: float exposed pad 17; TEST grounded',101.6,68.58),('J1: GND / 5V / A / B / Z / NC',208.28,73.66),('C3/C4: >=5 mm from sensing center; low-impedance supply paths',91.44,114.3),('SPI fixture: 3.3 V logic; power from 5V only; 3V3 is a measurement pad',25.4,144.78)]:
 sch+=f'(text {q(text)}(at {x} {y} 0)(effects(font(size 1.1 1.1))(justify left bottom))(uuid {uid(text)}))'
sch+=')'; (OUT/(NAME+'.kicad_sch')).write_text(sch)
# PCB native API creates and saves source, preserving schematic UUID links.
b=p.BOARD(); b.SetCopperLayerCount(2); ds=b.GetDesignSettings(); ds.SetBoardThickness(p.FromMM(1.0)); ds.m_MinClearance=p.FromMM(.15); ds.m_TrackMinWidth=p.FromMM(.15); ds.m_ViasMinSize=p.FromMM(.6); ds.m_MinThroughDrill=p.FromMM(.3); ds.m_CopperEdgeClearance=p.FromMM(.25)
netnames=sorted({r['net'] for r in rows if r['net']!='NC'}); nets={}
for n in netnames: nets[n]=p.NETINFO_ITEM(b,n); b.Add(nets[n])
def v(x,y): return p.VECTOR2I(p.FromMM(x),p.FromMM(y))
for ref,part in parts.items():
 fp=p.FootprintLoad(str(pretty),part[3]); fp.SetReference(ref); fp.SetValue(part[0]); fp.SetFPID(p.LIB_ID(LIB,part[3])); fp.SetPath(p.KIID_PATH('/'+rootid+'/'+uid(ref)))
 b.Add(fp); fp.SetPosition(v(100+part[4],100+part[5])); fp.SetOrientationDegrees(part[6]); fp.Value().SetVisible(False)
 fp.Reference().SetTextSize(v(.8,.8)); fp.Reference().SetTextThickness(p.FromMM(.12))
 if ref.startswith('TP'):
  fp.Reference().SetVisible(False)
  lab=p.PCB_TEXT(b);lab.SetText(part[0]);lab.SetLayer(p.F_SilkS);lab.SetTextSize(v(.8,.8));lab.SetTextThickness(p.FromMM(.12));lab.SetPosition(v(100+part[4],100+part[5]+(1 if ref=='TP6' else -.95)));b.Add(lab)
 if ref=='U2': fp.Reference().SetPosition(v(114,106));fp.Reference().SetLayer(p.F_Fab)
 if ref=='J1': fp.Reference().SetPosition(v(124.5,106))
 for pd in fp.Pads():
  n=netmap.get((ref,pd.GetNumber()))
  if n and n!='NC': pd.SetNet(nets[n])
for a,c in [((0,0),(28,0)),((28,0),(28,12)),((28,12),(0,12)),((0,12),(0,0))]:
 sh=p.PCB_SHAPE(); sh.SetShape(p.SHAPE_T_SEGMENT); sh.SetStart(v(100+a[0],100+a[1])); sh.SetEnd(v(100+c[0],100+c[1])); sh.SetLayer(p.Edge_Cuts); sh.SetWidth(p.FromMM(.05)); b.Add(sh)
# 64-sided circumscribed 5mm copper-pour keepout on both copper layers.
z=p.ZONE(b); z.SetIsRuleArea(True); z.SetLayerSet(p.LSET.AllCuMask(2)); z.SetDoNotAllowCopperPour(True); z.SetDoNotAllowTracks(False); z.SetDoNotAllowVias(False); z.SetDoNotAllowPads(False); z.SetDoNotAllowFootprints(False); z.SetZoneName('Sensor magnetic keepout: no pours; essential traces only')
o=z.Outline(); o.NewOutline()
for i in range(64): a=2*math.pi*i/64; o.Append(p.FromMM(104+5.01*math.cos(a)),p.FromMM(106+5.01*math.sin(a)))
b.Add(z)
# Component keepout is enforced by custom rule excluding U1, rather than rejecting U1 itself.
(OUT/(NAME+'.kicad_dru')).write_text('(version 1)\n(rule "Magnetic component clearance" (condition "A.Type == \'Footprint\' && A.Reference != \'U1\' && A.intersectsArea(\'Sensor magnetic keepout: no pours; essential traces only\')") (constraint disallow footprint))\n')
# No separate fills until routing is complete.
b.SetFileName(str(OUT/(NAME+'.kicad_pcb'))); p.SaveBoard(b.GetFileName(),b)
pro={'meta':{'filename':NAME+'.kicad_pro','version':1},'board':{'design_settings':{'rules':{'min_clearance':.15,'min_track_width':.15,'min_via_diameter':.6,'min_through_hole_diameter':.3,'min_copper_edge_clearance':.25},'defaults':{'board_outline_line_width':.05}},},'net_settings':{'classes':[{'name':'Default','clearance':.15,'track_width':.2,'via_diameter':.6,'via_drill':.3,'microvia_diameter':.3,'microvia_drill':.1,'diff_pair_width':.2,'diff_pair_gap':.2,'diff_pair_via_gap':.25,'bus_width':12,'wire_width':6,'schematic_color':'rgba(0, 0, 0, 0.000)','pcb_color':'rgba(0, 0, 0, 0.000)','line_style':0}],'meta':{'version':3}},'schematic':{'meta':{'version':1}}}
(OUT/(NAME+'.kicad_pro')).write_text(json.dumps(pro,indent=2))
(ROOT/'analysis/parts.json').write_text(json.dumps(parts,indent=2)); print('Created schematic, local libraries and placed PCB:',OUT)
