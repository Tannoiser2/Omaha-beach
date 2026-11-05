from common import *
import json,math
m=json.load(open('/home/claude/omaha-beach/data/mappa.json'))
H=m['hexes']; Hh,Ww=RGB.shape[:2]
def nb(h):
    r,c=int(h[:2]),int(h[2:]); a=c if r%2==0 else c-1
    return [f"{r:02d}{c-1:02d}",f"{r:02d}{c+1:02d}"]+[f"{r+dr:02d}{x:02d}" for dr in (-1,1) for x in (a,a+1)]
def dark_side(a,b):
    x1,y1=center(int(a[:2]),int(a[2:])); x2,y2=center(int(b[:2]),int(b[2:]))
    mx,my=(x1+x2)/2,(y1+y2)/2; ux,uy=x2-x1,y2-y1; L=math.hypot(ux,uy); ux/=L; uy/=L; vx,vy=-uy,ux
    best=0
    for o in range(-5,6):
        ts=np.linspace(-0.4,0.4,60)
        xs=np.clip((mx+vx*SIZE*ts+ux*o).astype(int),0,Ww-1); ys=np.clip((my+vy*SY*ts+uy*o).astype(int),0,Hh-1)
        p=RGB[ys,xs]; R,G,B=p[:,0],p[:,1],p[:,2]
        d=((abs(R-G)<14)&(abs(G-B)<14)&(R<110)).mean(); best=max(best,d)
    return best
bnd=set()
for h in H:
    c=int(h[2:])
    if not 14<=c<=24: continue
    for v in nb(h):
        if v in H and h<v and dark_side(h,v)>0.6: bnd.add((h,v))
print(len(bnd))
# flood from west
E=set(); q=[h for h in H if int(h[2:])<=5]
E.update(q)
B=set(bnd)|{(b,a) for a,b in bnd}
while q:
    h=q.pop()
    for v in nb(h):
        if v in H and v not in E and (h,v) not in B:
            E.add(v); q.append(v)
print('E',len(E),'W',len(H)-len(E))
chg=[h for h in H if ('E' if h in E else 'W')!=H[h]['s']]
print('cambi',sorted(chg))
json.dump(sorted(bnd),open('bnd.json','w'))
