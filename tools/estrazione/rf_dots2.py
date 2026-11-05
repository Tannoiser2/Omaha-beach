from common import *
import json
lab=np.load('lab.npy')
names=['verde','arancio','rosso','viola','marrone','blu']
m=json.load(open('/home/claude/omaha-beach/data/mappa.json'))
Hh,Ww=lab.shape
def nb(h):
    r,c=int(h[:2]),int(h[2:]); a=c if r%2==0 else c-1
    return [f"{r:02d}{c-1:02d}",f"{r:02d}{c+1:02d}"]+[f"{r+dr:02d}{x:02d}" for dr in (-1,1) for x in (a,a+1)]
res={}
for k,p in m['pos'].items():
    if p['tipo']!='R': continue
    h=p['hex'][0]; ki=names.index(p['col'])
    r,c=int(h[:2]),int(h[2:]); cx,cy=center(r,c)
    for v in nb(h):
        rv,cv=int(v[:2]),int(v[2:]); vx,vy=center(rv,cv)
        mx,my=(cx+vx)/2,(cy+vy)/2
        n=np.array([vx-cx,vy-cy]); n/=np.linalg.norm(n)
        q=np.array([mx,my])+n*6
        tot=col=wh=0
        for dy in range(-16,17):
            for dx in range(-16,17):
                if dx*dx+dy*dy>256: continue
                x,y=int(q[0]+dx),int(q[1]+dy)
                if not(0<=x<Ww and 0<=y<Hh): continue
                tot+=1; col+=lab[y,x]==ki
                px=RGB[y,x]; wh+= (px>232).all()
        res[k+'>'+v]=(round(col/tot,2),round(wh/tot,2))
json.dump(res,open('rf_dots2.json','w'))
import collections
c=np.array(list(res.values()))
H,_,_=np.histogram2d(c[:,0],c[:,1],bins=[10,6],range=[[0,1],[0,0.6]]); print(H.astype(int))
for k in ['D7','C9','D3']:
    print(k,{a.split('>')[1]:b for a,b in res.items() if a.startswith(k+'>')})
