#!/usr/bin/env python3
"""Require clean KiCad 10 ERC, DRC and schematic parity; retain JSON/text evidence."""
import os,pathlib,subprocess,json
for k,v in [('XDG_CONFIG_HOME','config'),('XDG_CACHE_HOME','cache'),('XDG_DATA_HOME','data')]:os.environ[k]='/tmp/ma600-kicad/'+v
r=pathlib.Path(__file__).resolve().parents[1];d=r/'kicad';out=r/'release';n='MA600A-RefWinch-Encoder'
for domain,check,suffix in [('sch','erc','.kicad_sch'),('pcb','drc','.kicad_pcb')]:
 for fmt,ext in [('json','json'),('report','txt')]:
  args=['kicad-cli',domain,check,'--format',fmt,'--severity-all','--exit-code-violations','-o',str(out/(check.upper()+'.'+ext))]
  if domain=='pcb':args+=['--schematic-parity']
  subprocess.run(args+[str(d/(n+suffix))],check=True)
 j=json.loads((out/(check.upper()+'.json')).read_text())
 issues=[x for sheet in j.get('sheets',[]) for x in sheet['violations']] if domain=='sch' else sum([j[k] for k in ['violations','unconnected_items','schematic_parity']],[])
 assert not issues,issues
print('Native ERC, DRC and schematic parity: zero findings, including exclusions.')
