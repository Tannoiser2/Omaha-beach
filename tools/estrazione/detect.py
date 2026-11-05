from common import *
import json, math
PAL={'verde':(1,160,85),'arancio':(238,160,58),'rosso':(236,36,46),'viola':(150,45,148),'marrone':(140,100,42),'blu':(60,170,232)}
names=list(PAL); P=np.array([PAL[n] for n in names])
Hh,Ww=RGB.shape[:2]
def classify(pix):
    d=np.sqrt(((pix[:,None,:]-P[None,:,:])**2).sum(-1))
    k=d.argmin(1); ok=d.min(1)<55
    return k,ok
NEI_ODD=None
def neighbors(r,c):
    # determine by geometry: centers within 1.2*W
    out=[]
    x,y=center(r,c)
    for rr in (r-1,r,r+1):
        for cc in (c-1,c,c+1):
            if (rr,cc)==(r,c): continue
            x2,y2=center(rr,cc)
            if math.hypot(x2-x,y2-y)<W*1.1: out.append((rr,cc))
    return out
hexes=[(r,c) for r in range(1,21) for c in range(0,38)]
def inmap(r,c):
    x,y=center(r,c); return 60<x<Ww-60 and 60<y<Hh-60
dots={}; outl={}; cross={}
R=24
for (r,c) in hexes:
    if not inmap(r,c): continue
    cx,cy=center(r,c)
    # edges: for each neighbor, edge midpoint = halfway between centers
    for (rr,cc) in neighbors(r,c):
        nx,ny=center(rr,cc); mx,my=(cx+nx)/2,(cy+ny)/2
        ux,uy=(cx-mx),(cy-my); L=math.hypot(ux,uy); ux/=L; uy/=L
        xs=[];ys=[]
        for dy in range(-R,R+1):
            for dx in range(-R,R+1):
                if dx*dx+dy*dy<=R*R and dx*ux+dy*uy>2:
                    xs.append(int(mx+dx)); ys.append(int(my+dy))
        pix=RGB[ys,xs]
        k,ok=classify(pix)
        if ok.sum()<0.18*len(xs): continue
        kk=np.bincount(k[ok],minlength=6).argmax()
        frac=(k[ok]==kk).sum()/len(xs)
        white=((pix>235).all(1)).sum()/len(xs)
        dots[f"{r:02d}{c:02d}>{rr:02d}{cc:02d}"]=(names[kk],round(float(frac),2),round(float(white),2))
    # outline band
    cs=corners(r,c); xs=[];ys=[]
    for i in range(6):
        a=cs[i]; b=cs[(i+1)%6]
        for t in np.linspace(0.15,0.85,20):
            px=a[0]+(b[0]-a[0])*t; py=a[1]+(b[1]-a[1])*t
            for f in (0.93,0.96):
                xs.append(int(cx+(px-cx)*f)); ys.append(int(cy+(py-cy)*f))
    pix=RGB[ys,xs]; k,ok=classify(pix)
    if ok.sum()>0:
        kk=np.bincount(k[ok],minlength=6).argmax(); frac=(k[ok]==kk).sum()/len(xs)
        if frac>0.35: outl[f"{r:02d}{c:02d}"]=(names[kk],round(float(frac),2))
    # cross in center
    pix=RGB[int(cy)-25:int(cy)+25,int(cx)-25:int(cx)+25].reshape(-1,3)
    k,ok=classify(pix)
    if ok.sum()>0:
        kk=np.bincount(k[ok],minlength=6).argmax(); frac=(k[ok]==kk).sum()/len(pix)
        if frac>0.3: cross[f"{r:02d}{c:02d}"]=(names[kk],round(float(frac),2))
json.dump(dict(dots=dots,outl=outl,cross=cross),open('detect.json','w'),indent=0)
print(len(dots),len(outl),len(cross))
print(outl); print(cross)
import collections
fr=[v[1] for v in dots.values()]; print(np.histogram(fr,bins=10,range=(0,1)))
wh=[v[2] for v in dots.values()]; print(np.histogram(wh,bins=10,range=(0,1)))
