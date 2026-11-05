from common import *
import json
REF={'mare':(164,218,246),'spiaggia':(246,245,227),'pianoro':(227,224,215),'altura':(213,215,176),'altura2':(204,207,176),'bocage':(190,197,156),
'accidentato':(205,177,129),'bosco':(137,159,110),'bianco':(255,255,255),'grigio':(171,170,169),'linea':(171,218,228),'mare2':(111,193,237),'mare3':(76,180,234)}
names=list(REF); P=np.array([REF[n] for n in names])
Hh,Ww=RGB.shape[:2]
out={}
for r in range(1,21):
  for c in range(0,38):
    cx,cy=center(r,c)
    if cx<-50 or cx>Ww+50: continue
    xs=[];ys=[]
    for dy in range(-80,81,3):
      for dx in range(-80,81,3):
        if (dx/(SIZE*0.8))**2+(dy/(SY*0.8))**2<=1:
          x,y=int(cx+dx),int(cy+dy)
          if 0<=x<Ww and 0<=y<Hh: xs.append(x); ys.append(y)
    if len(xs)<200: continue
    pix=RGB[ys,xs]
    d=np.sqrt(((pix[:,None,:]-P[None])**2).sum(-1)); k=d.argmin(1); ok=d.min(1)<22
    fr={n:round(float(((k==i)&ok).sum()/len(xs)),3) for i,n in enumerate(names)}
    fr['mare']=round(fr['mare']+fr['mare2']+fr['mare3'],3); fr['altura']=round(fr['altura']+fr['altura2'],3)
    for z in ('mare2','mare3','altura2'): del fr[z]
    fr['n']=len(xs)
    out[f"{r:02d}{c:02d}"]=fr
json.dump(out,open('terrain_raw.json','w'))
print(len(out))
