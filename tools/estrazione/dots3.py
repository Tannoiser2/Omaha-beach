from common import *
import json, math
from positions import *
names=['verde','arancio','rosso','viola','marrone','blu']
lab=np.load('lab.npy')
Hh,Ww=lab.shape
pos_col={}
for h,(i,c,t) in WN.items(): pos_col[h]=c
D=json.load(open('detect.json'))
for h in RF: pos_col[h]=D['outl'][h][0]
# mask outline bands of RF hexes
yy,xx=np.mgrid[0:Hh,0:Ww]
mask=np.zeros((Hh,Ww),bool)
for h in RF:
    r,c=int(h[:2]),int(h[2:]); cs=corners(r,c)
    cx,cy=center(r,c)
    x0,y0=int(cx-SIZE-15),int(cy-SY-15); x1,y1=int(cx+SIZE+15),int(cy+SY+15)
    sub=np.zeros((y1-y0,x1-x0),np.uint8)
    pts=np.array([(a-x0,b-y0) for a,b in cs],np.int32)
    cv2.polylines(sub,[pts],True,1,thickness=18)
    mask[y0:y1,x0:x1]|=sub.astype(bool)
lab2=lab.copy(); lab2[mask]=-1
# also mask WN cross areas
for h in WN:
    r,c=int(h[:2]),int(h[2:]); cx,cy=center(r,c)
    lab2[int(cy-60):int(cy+70),int(cx-50):int(cx+50)]=-1
frags=[]
for ki,n in enumerate(names):
    m=(lab2==ki).astype(np.uint8)
    num,cc,stats,cent=cv2.connectedComponentsWithStats(m,8)
    for i in range(1,num):
        x,y,w,h,a=stats[i]
        if a<40 or a>1400 or w>70 or h>70: continue
        frags.append([ki,float(cent[i][0]),float(cent[i][1]),int(a)])
# group fragments of same color within 28px
used=[False]*len(frags); groups=[]
for i,f in enumerate(frags):
    if used[i]: continue
    g=[i]; used[i]=True
    for j in range(i+1,len(frags)):
        if not used[j] and frags[j][0]==f[0] and math.hypot(frags[j][1]-f[1],frags[j][2]-f[2])<26: g.append(j); used[j]=True
    A=sum(frags[k][3] for k in g); X=sum(frags[k][1]*frags[k][3] for k in g)/A; Y=sum(frags[k][2]*frags[k][3] for k in g)/A
    if A<150: continue
    groups.append((f[0],X,Y,A))
RAD=22
out=[]
for ki,X,Y,A in groups:
    r,c=pix2hex(X,Y)
    cs=corners(r,c); best=None
    for i in range(6):
        a=np.array(cs[i]); b=np.array(cs[(i+1)%6]); d=b-a; t=np.clip(np.dot([X,Y]-a,d)/np.dot(d,d),0,1); p=a+t*d
        dist=np.hypot(*(np.array([X,Y])-p))
        if best is None or dist<best[0]: best=(dist,i,p,a,b)
    dist,ei,p,a,b=best
    if dist>22: continue
    cx,cy=center(r,c)
    n=np.array([cx,cy])-p; n/=np.linalg.norm(n)
    # sample semicircle excluding band near line
    tot=0;col=0
    for dy in range(-RAD,RAD+1):
        for dx in range(-RAD,RAD+1):
            if dx*dx+dy*dy>RAD*RAD: continue
            proj=dx*n[0]+dy*n[1]
            if proj<9: continue
            px,py=int(p[0]+dx),int(p[1]+dy)
            if not(0<=px<Ww and 0<=py<Hh): continue
            tot+=1; col+= lab[py,px]==ki
    fr=col/max(tot,1)
    out.append(dict(hex=f"{r:02d}{c:02d}",col=names[ki],x=round(X,1),y=round(Y,1),edge=ei,fr=round(fr,2),area=A))
json.dump(out,open('dots3.json','w'))
print(len(out)); print(np.histogram([o['fr'] for o in out],bins=20,range=(0,1)))
