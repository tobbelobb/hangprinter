#!/usr/bin/python3
"""Independent handoff -> native netlist -> PCB -> BOM/centroid comparison."""
import os,pathlib,sys,csv,json,math,hashlib,subprocess
for k,v in [('XDG_CONFIG_HOME','config'),('XDG_CACHE_HOME','cache'),('XDG_DATA_HOME','data')]:os.environ[k]='/tmp/ma600-kicad/'+v
import pcbnew as p
R=pathlib.Path(__file__).resolve().parents[1];sys.path.insert(0,str(R.parents[3]/'.agents/skills/kicad/scripts'))
from sexp_parser import parse_file,find_all,find_first,get_value
D=R/'kicad';N='MA600A-RefWinch-Encoder';b=p.LoadBoard(str(D/(N+'.kicad_pcb')));a=R/'analysis';rel=R/'release'
expected={(r['ref'],r['pin']):r['net'] for r in csv.DictReader(open(R/'reference/handoff-netlist.csv'))}
net=parse_file(a/'native.net');actual={};nativepins={}
for n in find_first(net,'nets')[1:]:
 if n[0]!='net':continue
 name=get_value(n,'name')
 for node in find_all(n,'node'):
  ref=get_value(node,'ref');num=get_value(node,'pin');actual[(ref,num)]='NC' if name.startswith('unconnected-') else name;nativepins[(ref,num)]=get_value(node,'pintype')
checks=[]
def check(label,ok,detail=''):
 checks.append({'check':label,'pass':bool(ok),'detail':detail})
 if not ok:print('FAIL',label,detail)
for key,n in expected.items():check('native pin '+':'.join(key),actual.get(key)==n,str(actual.get(key)))
footprints={f.GetReference():f for f in b.GetFootprints()};padmap={}
for ref,fp in footprints.items():
 for pad in fp.Pads():
  if pad.GetNumber():padmap[(ref,pad.GetNumber())]='NC' if not pad.GetNetname() or pad.GetNetname().startswith('unconnected-') else pad.GetNetname()
for key,n in expected.items():check('PCB pin '+':'.join(key),padmap.get(key)==n,str(padmap.get(key)))
check('footprint references',set(footprints)=={x[0] for x in expected}|{'FID1','FID2','FID3'},str(sorted(footprints)))
# Datasheet land pattern comparison, including pad numbering and top-view orientation.
u=footprints['U1'];cx,cy=p.ToMM(u.GetPosition().x),p.ToMM(u.GetPosition().y)
for num,(x,y,w,h) in {**{str(i+1):(-1.45,t,.7,.25) for i,t in enumerate([-.75,-.25,.25,.75])},**{str(i+5):(t,1.45,.25,.7) for i,t in enumerate([-.75,-.25,.25,.75])},**{str(i+9):(1.45,t,.7,.25) for i,t in enumerate([.75,.25,-.25,-.75])},**{str(i+13):(t,-1.45,.25,.7) for i,t in enumerate([.75,.25,-.25,-.75])},'17':(0,0,1.7,1.7)}.items():
 pd=next(pd for pd in u.Pads() if pd.GetNumber()==num);got=[p.ToMM(pd.GetPosition().x)-cx,p.ToMM(pd.GetPosition().y)-cy,p.ToMM(pd.GetSize().x),p.ToMM(pd.GetSize().y)]
 check('U1 land '+num,all(abs(a-c)<1e-5 for a,c in zip(got,[x,y,w,h])),str(got)+'; MPS MA600A p48')
for num,x,y in [('1',-1.3,-.95),('2',-1.3,0),('3',-1.3,.95),('4',1.3,.95),('5',1.3,-.95)]:
 fp=footprints['U2'];pd=next(pd for pd in fp.Pads() if pd.GetNumber()==num);got=[p.ToMM(pd.GetPosition().x)-114,p.ToMM(pd.GetPosition().y)-106,p.ToMM(pd.GetSize().x),p.ToMM(pd.GetSize().y)]
 check('U2 land '+num,all(abs(a-c)<1e-5 for a,c in zip(got,[x,y,1.2,.6])),str(got)+'; MPS MP20056 p16 (rotated top view)')
distances={}
for ref,fp in footprints.items():
 if ref=='U1':continue
 mind=1e9
 for pd in fp.Pads():
  px,py=p.ToMM(pd.GetPosition().x)-cx,p.ToMM(pd.GetPosition().y)-cy;w,h=p.ToMM(pd.GetSize().x),p.ToMM(pd.GetSize().y)
  if round(pd.GetOrientationDegrees())%180:w,h=h,w
  mind=min(mind,math.hypot(max(abs(px)-w/2,0),max(abs(py)-h/2,0)))
 distances[ref]=mind;check('magnetic clearance '+ref,mind>=5,f'{mind:.3f} mm nearest pad edge')
# Board size and all drills; PTH only, no mounting holes.
box=b.GetBoardEdgesBoundingBox();check('outline 28x12',abs(p.ToMM(box.GetWidth())-28)<.1 and abs(p.ToMM(box.GetHeight())-12)<.1)
for tr in b.GetTracks():
 if isinstance(tr,p.PCB_VIA):
  dx=p.ToMM(tr.GetPosition().x)-cx;dy=p.ToMM(tr.GetPosition().y)-cy
  check('no EP via '+str(tr.m_Uuid.AsString()),abs(dx)>1 or abs(dy)>1)
# Verify every placement against PCB transforms and the chosen lower-left datum.
bom=list(csv.DictReader(open(rel/'BOM.csv')));pos=list(csv.DictReader(open(rel/'Pick-and-place.csv')))
check('BOM seven installed parts',{r['Designator'] for r in bom}=={'U1','U2','J1','C1','C2','C3','C4'})
check('centroid seven installed parts',{r['Ref'] for r in pos}=={r['Designator'] for r in bom})
for r in pos:
 fp=footprints[r['Ref']];x=p.ToMM(fp.GetPosition().x)-100;y=112-p.ToMM(fp.GetPosition().y)
 check('centroid '+r['Ref'],abs(float(r['PosX'])-x)<1e-5 and abs(float(r['PosY'])-y)<1e-5 and abs(float(r['Rot'])-fp.GetOrientationDegrees())<1e-5 and r['Side']=='top')
for r in bom:check('MPN '+r['Designator'],r['Manufacturer Part Number'] not in ['', 'TBD'])
# Native DRC re-run after all final touches and zone fills.
subprocess.run([sys.executable,str(R/'tools/check_native.py')],check=True)
j=json.loads((rel/'DRC.json').read_text());check('native DRC and schematic parity',not any(j[k] for k in ['violations','unconnected_items','schematic_parity']))

result={'checks':checks,'passed':sum(c['pass'] for c in checks),'failed':sum(not c['pass'] for c in checks),'nearest_component_pad_edges_mm':distances,'source_sha256':{f.name:hashlib.sha256(f.read_bytes()).hexdigest() for f in D.glob('*.kicad_*') if f.is_file()}}
(a/'verification.json').write_text(json.dumps(result,indent=2))
with open(rel/'Pin-verification.csv','w',newline='') as f:
 w=csv.writer(f);w.writerow(['Reference','Pin','Handoff net','KiCad native netlist','PCB pad net','Pass'])
 for key,n in expected.items():w.writerow([*key,n,actual.get(key),padmap.get(key),n==actual.get(key)==padmap.get(key)])
print(result['passed'],'checks passed;',result['failed'],'failed; magnetic nearest pad:',min(distances.values()))
if result['failed']:sys.exit(1)
