#!/usr/bin/python3
"""Export validated native KiCad sources; no rerouting or electrical edits."""
import os,pathlib,subprocess,json,csv,sys,zipfile,hashlib
for k,v in [('XDG_CONFIG_HOME','config'),('XDG_CACHE_HOME','cache'),('XDG_DATA_HOME','data')]:os.environ[k]='/tmp/ma600-kicad/'+v
R=pathlib.Path(__file__).resolve().parents[1];D=R/'kicad';O=R/'release';G=O/'gerbers';G.mkdir(parents=True,exist_ok=True);N='MA600A-RefWinch-Encoder';pcb=D/(N+'.kicad_pcb');sch=D/(N+'.kicad_sch')
def cli(*args):subprocess.run(['kicad-cli',*map(str,args)],check=True)
cli('sch','export','netlist','-o',R/'analysis/native.net',sch)
cli('sch','export','pdf','-o',O/'Schematic.pdf',sch)
cli('pcb','export','gerbers','-l','F.Cu,B.Cu,F.Mask,B.Mask,F.Silkscreen,B.Silkscreen,F.Paste,B.Paste,Edge.Cuts','--use-drill-file-origin','-o',str(G)+'/',pcb)
cli('pcb','export','drill','--drill-origin','plot','--excellon-separate-th','-o',str(G)+'/',pcb)
cli('pcb','export','pos','--format','csv','--units','mm','--side','front','--use-drill-file-origin','--smd-only','-o',O/'Pick-and-place.csv',pcb)
cli('pcb','export','svg','-l','F.Cu,F.Silkscreen,Edge.Cuts','--page-size-mode','2','-o',O/'Board-top.svg',pcb)
cli('pcb','export','svg','-l','B.Cu,Edge.Cuts','--page-size-mode','2','-o',O/'Board-bottom-through.svg',pcb)
cli('pcb','export','svg','-l','F.Fab,F.Silkscreen,Edge.Cuts','--page-size-mode','2','-o',O/'Assembly-top.svg',pcb)
# Export BOM from the current schematic analysis; join by reference to actual placement.
sys.path.insert(0,str(R.parents[2]/'.agents/skills/kicad/scripts'))
# Locate skill within this repository independent of invocation directory.
skill=R.parents[1]/'.agents/skills/kicad/scripts';sys.path.insert(0,str(skill))
from sexp_parser import parse_file,find_all,find_first,get_value
net=parse_file(str(R/'analysis/native.net')); comps=find_first(net,'components')
with open(O/'BOM.csv','w',newline='') as f:
 w=csv.writer(f);w.writerow(['Designator','Quantity','Manufacturer','Manufacturer Part Number','Value','Footprint','Assembly'])
 for c in comps[1:]:
  if c[0]!='comp':continue
  ref=get_value(c,'ref')
  if not ref.startswith(('U','C','J')):continue
  fields=find_first(c,'fields') or [];props={get_value(t,'name'):t[-1] for t in fields[1:] if isinstance(t,list) and t[0]=='field'}
  w.writerow([ref,1,props.get('Manufacturer',''),props.get('MPN',''),get_value(c,'value'),get_value(c,'footprint'),'Top'])
with zipfile.ZipFile(O/'MA600A-v0.3-Gerbers.zip','w',zipfile.ZIP_DEFLATED) as z:
 for f in sorted(G.iterdir()):z.write(f,f.name)
print('Exported:',O)
