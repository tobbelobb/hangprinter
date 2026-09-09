#!/usr/bin/python3
"""Synchronize footprint fields and intentional NC nets from native netlist."""
import os,sys,pathlib,subprocess
for k,v in [('XDG_CONFIG_HOME','config'),('XDG_CACHE_HOME','cache'),('XDG_DATA_HOME','data')]:os.environ[k]='/tmp/ma600-kicad/'+v
import pcbnew as p
r=pathlib.Path(__file__).resolve().parents[1];d=r/'kicad';n='MA600A-RefWinch-Encoder'
sys.path.insert(0,str(r.parents[1]/'.agents/skills/kicad/scripts'))
from sexp_parser import parse_file,find_first,find_all,get_value
subprocess.run(['kicad-cli','sch','export','netlist','-o',str(r/'analysis/native.net'),str(d/(n+'.kicad_sch'))],check=True)
net=parse_file(r/'analysis/native.net');b=p.LoadBoard(str(d/(n+'.kicad_pcb')));fps={f.GetReference():f for f in b.GetFootprints()}
for c in find_all(find_first(net,'components'),'comp'):
 ref=get_value(c,'ref')
 if ref not in fps:continue
 for f in find_all(find_first(c,'fields') or [],'field'):
  name=get_value(f,'name');value=f[-1] if isinstance(f[-1],str) else ''
  if name in ['MPN','Manufacturer']:
   fps[ref].SetField(name,value)
   fps[ref].GetField(name).SetVisible(False)
 fps[ref].SetField('Datasheet',get_value(c,'datasheet') or '')
 fps[ref].GetField('Datasheet').SetVisible(False)
for nt in find_all(find_first(net,'nets'),'net'):
 name=get_value(nt,'name')
 if not name.startswith('unconnected-'):continue
 nn=b.FindNet(name)
 if nn is None:
  nn=p.NETINFO_ITEM(b,name);b.Add(nn)
 for nd in find_all(nt,'node'):
  fp=fps[get_value(nd,'ref')];num=get_value(nd,'pin')
  for pad in fp.Pads():
   if pad.GetNumber()==num:
    assert not pad.GetNetname() or pad.GetNetname()==name
    pad.SetNet(nn)
p.SaveBoard(str(d/(n+'.kicad_pcb')),b)
print('Synchronized fields and isolated no-connect nets.')
