#!/usr/bin/python3
"""Deterministic grid router; output must pass KiCad native DRC before release."""
import os,pathlib,math,heapq,time,json
for k,v in [('XDG_CONFIG_HOME','config'),('XDG_CACHE_HOME','cache'),('XDG_DATA_HOME','data')]: os.environ[k]='/tmp/ma600-kicad/'+v
import pcbnew as p
import numpy as np
from scipy.ndimage import distance_transform_edt
ROOT=pathlib.Path(__file__).resolve().parents[1]; fn=ROOT/'kicad/MA600A-RefWinch-Encoder.kicad_pcb'; b=p.LoadBoard(str(fn))
for tr in list(b.GetTracks()):b.Remove(tr)
S=.05; NX=561; NY=241
Y,X=np.mgrid[0:NY,0:NX]; X=X*S; Y=Y*S
obs=[[],[]]; pins={}; copper=[]; allvias=[]
def pos(v): return (p.ToMM(v.x)-100,p.ToMM(v.y)-100)
def rectdist(x,y,w,h): return np.hypot(np.maximum(np.abs(X-x)-w/2,0),np.maximum(np.abs(Y-y)-h/2,0))
for fp in b.GetFootprints():
 for pad in fp.Pads():
  if not pad.IsOnLayer(p.F_Cu): continue
  x,y=pos(pad.GetPosition()); sz=pad.GetSize(); w,h=p.ToMM(sz.x),p.ToMM(sz.y)
  if round(pad.GetOrientationDegrees())%180: w,h=h,w
  net=pad.GetNetname(); obs[0].append((net,rectdist(x,y,w,h)))
  if net: pins.setdefault(net,[]).append((fp.GetReference(),pad.GetNumber(),x,y,0))
# Forbid vias in all component pads, including same-net pads, and under the sensor body.
via_pad=np.zeros((NY,NX),bool)
for _,d in obs[0]: via_pad|= d<.4
via_pad|=rectdist(4,6,3.6,3.6)<.35
edge=np.minimum.reduce([X,Y,28-X,12-Y])
def segdist(a,c):
 ax,ay=a; cx,cy=c; dx=cx-ax; dy=cy-ay
 t=np.clip(((X-ax)*dx+(Y-ay)*dy)/max(dx*dx+dy*dy,1e-9),0,1)
 return np.hypot(X-ax-t*dx,Y-ay-t*dy)
def grid(x,y,l=0):return (l,int(round(y/S)),int(round(x/S)))
def vec(x,y):return p.VECTOR2I(p.FromMM(100+x),p.FromMM(100+y))
def addseg(net,l,a,c,w):
 if a==c:return
 tr=p.PCB_TRACK(b);tr.SetStart(vec(*a));tr.SetEnd(vec(*c));tr.SetWidth(p.FromMM(w));tr.SetLayer(p.F_Cu if l==0 else p.B_Cu);tr.SetNetCode(b.GetNetcodeFromNetname(net));b.Add(tr)
 copper.append((net,l,segdist(a,c),w/2))
def via(net,x,y):
 if any(n==net and math.hypot(x-a,y-c)<.001 for n,a,c in allvias):return
 allvias.append((net,x,y))
 v=p.PCB_VIA(b);v.SetPosition(vec(x,y));v.SetWidth(p.FromMM(.6));v.SetDrill(p.FromMM(.3));v.SetViaType(p.VIATYPE_THROUGH);v.SetLayerPair(p.F_Cu,p.B_Cu);v.SetNetCode(b.GetNetcodeFromNetname(net));b.Add(v)
 for l in [0,1]:copper.append((net,l,np.hypot(X-x,Y-y),.3))
def route(net,source,target,w):
 blocked=np.zeros((2,NY,NX),bool); vblocked=via_pad.copy()|(edge<.6)
 for l in [0,1]:
  blocked[l]|=edge<(.25+w/2+.025)
  for n,d in obs[l]:
   if n!=net: blocked[l]|=d<(.17+w/2);vblocked|=d<.47
 for n,l,d,r in copper:
  if n!=net:blocked[l]|=d<r+.17+w/2;vblocked|=d<r+.47
 for n,x,y in allvias:vblocked|=np.hypot(X-x,Y-y)<.62
 for n,x,y in allvias:
  if n==net:vblocked[int(round(y/S)),int(round(x/S))]=False
 start=grid(source[0],source[1],source[2]); end=grid(target[0],target[1],target[2])
 # Grid endpoints are inside their own pads.
 if blocked[start] or blocked[end]: raise RuntimeError(('blocked endpoint',net,start,end))
 # A* target is a single pad center; remaining same-net geometry can be crossed.
 def heuristic(s):
  _,yy,xx=s; dy=abs(yy-end[1]);dx=abs(xx-end[2]);return max(dx,dy)+.41421356*min(dx,dy)+(12 if s[0]!=end[0] else 0)
 queue=[(heuristic(start),0,start)]; cost={start:0}; prev={}; moves=[(1,0,1),(-1,0,1),(0,1,1),(0,-1,1),(1,1,1.4142),(1,-1,1.4142),(-1,1,1.4142),(-1,-1,1.4142)]
 while queue:
  _,g,s=heapq.heappop(queue)
  if g>cost.get(s,1e99)+1e-8:continue
  if s==end:break
  l,yy,xx=s
  for dx,dy,dg in moves:
   nx=xx+dx;ny=yy+dy
   if nx<0 or nx>=NX or ny<0 or ny>=NY or blocked[l,ny,nx]:continue
   if dx and dy and (blocked[l,yy,nx] or blocked[l,ny,xx]):continue
   ns=(l,ny,nx);ng=g+dg
   if ng<cost.get(ns,1e99):cost[ns]=ng;prev[ns]=s;heapq.heappush(queue,(ng+heuristic(ns),ng,ns))
  if not vblocked[yy,xx] and not blocked[1-l,yy,xx]:
   ns=(1-l,yy,xx);ng=g+25
   if ng<cost.get(ns,1e99):cost[ns]=ng;prev[ns]=s;heapq.heappush(queue,(ng+heuristic(ns),ng,ns))
 else:
  np.savez(ROOT/'analysis/route-failure.npz',blocked=blocked,vblocked=vblocked,start=start,end=end);p.SaveBoard(str(ROOT/'analysis/partial.kicad_pcb'),b);raise RuntimeError(('unroutable',net,source,target))
 path=[end]
 while path[-1]!=start:path.append(prev[path[-1]])
 path.reverse(); last=path[0]; anchor=last; direction=None
 for s in path[1:]:
  d=(s[0]-last[0],s[1]-last[1],s[2]-last[2])
  if s[0]!=last[0]:
   addseg(net,last[0],(anchor[2]*S,anchor[1]*S),(last[2]*S,last[1]*S),w);via(net,s[2]*S,s[1]*S);anchor=s;direction=None
  elif direction is not None and d!=direction:
   addseg(net,last[0],(anchor[2]*S,anchor[1]*S),(last[2]*S,last[1]*S),w);anchor=last;direction=d
  else:direction=d
  last=s
 addseg(net,last[0],(anchor[2]*S,anchor[1]*S),(last[2]*S,last[1]*S),w)
 # Exact pad center to snapped grid center, if needed.
 for xy,pt in [(source[:2],start),(target[:2],end)]:addseg(net,pt[0],xy,(pt[2]*S,pt[1]*S),w)
 print(net,source,target,'points',len(path),flush=True)
# Reserve essential U1 escape paths before long routes can fence in the fine-pitch pads.
escapes={'2':(1.3,5.35),'3':(.7,6.25),'4':(1.3,7.15),'5':(2.8,8.6),'6':(3.6,9.4),'7':(4.5,8.6),'8':(5.65,9.4),'10':(7,6.25),'12':(7,5.25)}
for net,pp in pins.items():
 for i,(ref,num,x,y,l) in enumerate(pp):
  if ref=='U1' and num in escapes:
   ex,ey=escapes[num];width=.3 if net=='GND' else .2
   addseg(net,0,(x,y),(ex,ey),width);via(net,ex,ey);pp[i]=(ref,num,ex,ey,1)
for net,pp in pins.items():
 for i,(ref,num,x,y,l) in enumerate(pp):
  if ref=='J1':
   ex,ey=21.4,round(y/S)*S; width=.3 if net in ['GND','+5V_IN'] else .2
   addseg(net,0,(x,y),(ex,ey),width);via(net,ex,ey);pp[i]=(ref,num,ex,ey,1)
# Supply branches before digital signals; individual decoupling branches to U1.
for net in ['+3V3','GND','+5V_IN','B_OUT','SPI_CIPO','SPI_CS','SPI_COPI','Z_OUT','A_OUT','SPI_SCLK']:
 pp=pins[net]; w=.3 if net in ['+3V3','GND','+5V_IN'] else .2
 tree=[pp.pop(0)]
 while pp:
  _,i,j=min((math.hypot(a[2]-c[2],a[3]-c[3]),i,j) for i,a in enumerate(tree) for j,c in enumerate(pp))
  c=pp.pop(j);route(net,tree[i][2:],c[2:],w);tree.append(c)
p.SaveBoard(str(fn),b)
print('Native DRC:',p.WriteDRCReport(b,str(ROOT/'analysis/drc-routing.txt'),p.EDA_UNITS_MILLIMETRES,True))
