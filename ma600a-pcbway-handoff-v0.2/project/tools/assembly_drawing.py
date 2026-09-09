#!/usr/bin/python3
import os,pathlib,json,csv,math
for k,v in [('XDG_CONFIG_HOME','config'),('XDG_CACHE_HOME','cache'),('XDG_DATA_HOME','data')]:os.environ[k]='/tmp/ma600-kicad/'+v
import pcbnew as p
from reportlab.pdfgen import canvas
from reportlab.lib.colors import HexColor,Color
R=pathlib.Path(__file__).resolve().parents[1];O=R/'release';b=p.LoadBoard(str(R/'kicad/MA600A-RefWinch-Encoder.kicad_pcb'));c=canvas.Canvas(str(O/'Assembly-drawing.pdf'),pagesize=(842,595));c.setTitle('MA600A v0.3 - Assembly drawing')
def text(x,y,s,size=10,color='#172b40'):
 c.setFillColor(HexColor(color));c.setFont('Helvetica',size);c.drawString(x,y,s)
text(45,552,'MA600A RefWinch Encoder | v0.3',21);text(45,532,'Top-side assembly - component view, cable exits right. All dimensions in mm.',11)
X0,Y0,S=140,267,20
c.setFillColor(HexColor('#f4f8f7'));c.setStrokeColor(HexColor('#123b37'));c.setLineWidth(1);c.rect(X0,Y0,28*S,12*S,fill=1)
c.saveState();cp=c.beginPath();cp.rect(X0,Y0,28*S,12*S);c.clipPath(cp,stroke=0);c.setStrokeColor(HexColor('#b88932'));c.setDash(4,3);c.circle(X0+4*S,Y0+6*S,5*S,stroke=1,fill=0);c.restoreState()
# Draw actual board pad geometry. Paste-only windows are omitted.
fps={f.GetReference():f for f in b.GetFootprints()};pin1=[]
for ref,fp in fps.items():
 for pd in fp.Pads():
  if not pd.IsOnLayer(p.F_Cu):continue
  x=p.ToMM(pd.GetPosition().x)-100;y=112-p.ToMM(pd.GetPosition().y);w=p.ToMM(pd.GetSize().x);h=p.ToMM(pd.GetSize().y)
  if round(pd.GetOrientationDegrees())%180:w,h=h,w
  c.setFillColor(HexColor('#849f9b'));c.setStrokeColor(HexColor('#42635c'));c.setLineWidth(.3)
  if pd.GetShape()==p.PAD_SHAPE_CIRCLE:c.circle(X0+x*S,Y0+y*S,w*S/2,fill=1,stroke=1)
  else:c.rect(X0+(x-w/2)*S,Y0+(y-h/2)*S,w*S,h*S,fill=1,stroke=1)
  if pd.GetNumber()=='1' and ref in ['U1','U2','J1']:pin1.append((ref,x,y))
# Package body dimensions are from the manufacturer drawings; pads remain visible.
for ref,x,y,w,h in [('U1',4,6,3,3),('U2',14,6,1.6,2.9),('J1',24.925,6,4.05,10.75),('C1',14,9.3,1.6,.8),('C2',14,2.8,1.6,.8),('C3',10.5,9,.5,1),('C4',10.5,6.5,.5,1)]:
 c.setFillColor(Color(.91,.94,.94,alpha=.8));c.setStrokeColor(HexColor('#2e5551'));c.rect(X0+(x-w/2)*S,Y0+(y-h/2)*S,w*S,h*S,fill=1,stroke=1)
 if ref.startswith('C'):text(X0+x*S-7,Y0+(y+h/2)*S+5,ref,8)
 else:text(X0+x*S-8,Y0+y*S-3,ref,10)
for ref,x,y in pin1:
 c.setFillColor(HexColor('#bd4633'));c.circle(X0+x*S,Y0+y*S,2,fill=1,stroke=0)
 if ref!='J1':text(X0+x*S-17,Y0+y*S+4,'1',8,'#bd4633')
for i in range(1,8):
 fp=fps['TP'+str(i)];x=p.ToMM(fp.GetPosition().x)-100;y=112-p.ToMM(fp.GetPosition().y)
 label=['5V','GND','CS','SCLK','COPI','CIPO','3V3'][i-1]
 text(X0+x*S-10,Y0+y*S-19,label,7) if i==5 else text(X0+x*S+13,Y0+y*S-3,label,7)
for i in range(1,4):
 fp=fps['FID'+str(i)];x=p.ToMM(fp.GetPosition().x)-100;y=112-p.ToMM(fp.GetPosition().y);text(X0+x*S-9,Y0+y*S+10,'F'+str(i),7)
text(X0+5,Y0+9,'5 mm magnetic keepout',8,'#94671f');text(X0+28*S+8,Y0+6*S,'CABLE',9)
text(X0+1,Y0-17,'(0,0)',8);text(X0+13*S,Y0-17,'28.00 mm',9);text(45,390,'12.00 mm',9)
text(45,231,'Assembly notes',12)
notes=['7 fitted parts: U1, U2, J1 and C1-C4. Test pads and fiducials are bare PCB features.',
'U1 pad 17 is an isolated 1.7 x 1.7 mm solder land. Do not ground it or add thermal vias.',
'Four exposed-pad paste windows give 68% coverage. Start with a 0.10 mm stencil.',
'U1 and U2 orientation: pin 1 is the upper-left copper pad in this view (red dot).',
'J1 pin 1 is at the bottom of the six signal contacts. Pin 6 is reserved and unconnected.',
'Pick-and-place uses lower-left board origin, X right, Y up; native KiCad rotation angles.',
'Reconcile reel rotation with these pin-1 positions before running the assembly machine.',
'F1-F3: 0.6 mm copper / 1.1 mm mask opening. Add panel-rail fiducials if needed.']
for i,s in enumerate(notes):text(45,212-i*16,s,10)
text(45, 61,'Pin-1 centers (same datum as pick-and-place)',10)
text(45,45,' | '.join(f'{r}: ({x:.3f}, {y:.3f})' for r,x,y in pin1),10)
c.save()
print(O/'Assembly-drawing.pdf')
