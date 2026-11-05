from common import *
import json, math
from positions import WN, RF
T=json.load(open('terrain_cls.json')); CLS=T['cls']; EDI=set(T['edifici'])
RAW=json.load(open('terrain_raw.json'))
S=json.load(open('sides_cls.json'))
DOTS=json.load(open('dots3.json'))
DET=json.load(open('detect.json'))
Hh,Ww=RGB.shape[:2]
def hk(r,c): return f"{r:02d}{c:02d}"
def nb(r,c):
    x,y=center(r,c); out=[]
    for rr in (r-1,r,r+1):
        for cc in (c-1,c,c+1):
            if (rr,cc)==(r,c): continue
            x2,y2=center(rr,cc)
            if math.hypot(x2-x,y2-y)<W*1.1: out.append(hk(rr,cc))
    return out
def sector(r,c):
    return 'E' if c <= 18+(r%2) else 'W'
hexes={}
for h,t in CLS.items():
    r,c=int(h[:2]),int(h[2:])
    x,y=center(r,c)
    if x<SIZE*0.5 or x>Ww-SIZE*0.5 or y<1000 or y>Hh-60: continue
    if t in ('mare','?') : 
        if r>=5 and RAW[h]['spiaggia']>0.15: t='spiaggia'
        else: continue
    hexes[h]=dict(t=t)
# esagoni di spiaggia parzialmente in acqua (riga 5 ecc.): marca come spiaggia se c'e' spiaggia
for h,f in RAW.items():
    r,c=int(h[:2]),int(h[2:]); x,y=center(r,c)
    if h not in hexes and f['spiaggia']+f['linea']>0.12 and f['mare']>0.2 and x>SIZE*0.5 and x<Ww-SIZE*0.5:
        hexes[h]=dict(t='spiaggia')
for h in hexes:
    r,c=int(h[:2]),int(h[2:])
    d=hexes[h]; d['s']=sector(r,c)
    if h in EDI and d['t']!='spiaggia': d['ed']=1
    # ostacoli: grigio su spiaggia
    if d['t']=='spiaggia' and RAW[h]['grigio']>0.012: d['ost']=1
# ciottoli/protezione: pixel sabbia scura
for h,d in hexes.items():
    if d['t'] not in ('spiaggia','pianoro'): continue
    r,c=int(h[:2]),int(h[2:]); cx,cy=center(r,c)
    reg=RGB[int(cy-SY*0.8):int(cy+SY*0.8):3,int(cx-SIZE*0.8):int(cx+SIZE*0.8):3].reshape(-1,3)
    m=((reg[:,0]-reg[:,2]>45)&(reg[:,0]>200)&(reg[:,1]>195)).mean()
    if m>0.05: d['cio']=1
sides={}
for k,v in S.items():
    a,b=k.split('|')
    if a in hexes and b in hexes:
        ra,ca=int(a[:2]),int(a[2:]); rb,cb=int(b[:2]),int(b[2:])
        if v=='C' and sector(ra,ca)!=sector(rb,cb) and 15<=ca<=22: continue  # confine di settore
        if v=='B?': v='L'
        sides[k]=v
# posizioni
pos={}
for h,(pid,col,typ) in WN.items():
    pos[pid]=dict(id=pid,tipo='WN',col=col,hex=[h],art=typ)
groups={}
for pid in list(pos):
    if pid[-1] in 'NS':
        base=pid[:-1]; groups.setdefault(base,[]).append(pid)
for base,ps in groups.items():
    hx=[pos[p]['hex'][0] for p in sorted(ps)]
    for p in ps: pos[p]['gruppo']=base
for h,pid in RF.items():
    col=DET['outl'][h][0]
    key=pid if pid else 'R'+h
    pos[key]=dict(id=key,tipo='R',col=col,hex=[h],zona=pid[0] if pid else '',prio=int(pid[1:]) if pid else 0,ed=1 if h in EDI else 0)
hex2pos={p['hex'][0]:k for k,p in pos.items()}
for base,ps in groups.items():
    pass

# fuoco: assegna puntini
INT={'I':3,'S':2,'P':1}
def kk(d):
    co,f=d['core'],d['fr']
    if co<0.2: return 'P'
    if co<0.6: return 'S'
    return 'I' if f>=0.6 else 'S'
fire={}
for d in DOTS:
    h=d['hex']
    if h not in hexes: continue
    if h in hex2pos and pos[hex2pos[h]]['col']==d['col']: continue
    cands=[k for k,p in pos.items() if p['col']==d['col']]
    if not cands: continue
    best=None
    for k in cands:
        for ph in pos[k]['hex']:
            pr,pc=int(ph[:2]),int(ph[2:]); px,py=center(pr,pc)
            dist=math.hypot(px-d['x'],py-d['y'])
            if best is None or dist<best[0]: best=(dist,k)
    owner=best[1]
    def ax(hh):
        r,c=int(hh[:2]),int(hh[2:]); return c-(r+(r&1))//2, r
    def hd(a,b):
        q1,r1=ax(a); q2,r2=ax(b); return (abs(q1-q2)+abs(r1-r2)+abs(q1+r1-q2-r2))//2
    maxd=6 if pos[owner]['tipo']=='WN' else 3
    if min(hd(h,ph) for ph in pos[owner]['hex'])>maxd: continue
    # gruppo WN a due esagoni: campo unico
    if 'gruppo' in pos[owner]: owner=pos[owner]['gruppo']
    lv=INT[kk(d)]
    cur=fire.setdefault(owner,{})
    cur[h]=max(cur.get(h,0),lv)
# sbarco: percorso in alto a destra
BOX={'FG1':'0407','FG2':'0408','FG3':'0409','FG4':'0410','FG5':'0411','ER1':'0412','ER2':'0413','ER3':'0414','ER4':'0415','ER5':'0416','ER6':'0417',
'EG1':'0319','EG2':'0320','EG3':'0321','DR1':'0322','DR2':'0323','DR3':'0324','DW1':'0325','DW2':'0225','DW3':'0226',
'DG1':'0127','DG2':'0128','DG3':'0129','DG4':'0130','CH1':'0131','CH2':'0132','CH3':'0133'}
def upright(h):
    r,c=int(h[:2]),int(h[2:])
    return hk(r+1,c+1) if r%2==0 else hk(r+1,c)
boxes={}
for b,h in BOX.items():
    path=[]; cur=h
    for i in range(6):
        cur=upright(cur); path.append(cur)
    low=None
    for i,p in enumerate(path):
        f=RAW.get(p)
        if f and f['spiaggia']+f['linea']>0.08: low=i; break
    seq=path[low:low+3] if low is not None else []
    res=dict(box=h,div=1 if b[:2] in ('FG','ER') else 29,dir=path)
    for nm,p in zip(('bassa','media','alta'),seq):
        if p in hexes and hexes[p]['t'] in ('spiaggia',):
            res[nm]=p
    boxes[b]=res
EXITS={'A':'1001','B':'1902','C':'2016','D':'2022','E':'2025','F':'1436','G':'0636'}
for e,h in EXITS.items():
    if h in hexes: hexes[h]['uscita']=e
out=dict(hexes=hexes,sides=sides,pos=pos,fire={k:v for k,v in fire.items()},boxes=boxes,exits=EXITS,
  grid=dict(W=W,RS=169.55,x0=-10.093,odd=-95.949,dx=66.0,y0=4486.4,size=SIZE,sy=SY))
json.dump(out,open('omaha_map.json','w'),indent=0)
print(len(hexes),len(sides),len(pos),len(fire),sum(len(v) for v in fire.values()))
for b,v in boxes.items(): print(b,v.get('bassa'),v.get('media'),v.get('alta'))
from collections import Counter
print(Counter(h['t'] for h in hexes.values()), sum(1 for h in hexes.values() if h.get('ost')), sum(1 for h in hexes.values() if h.get('cio')))
for k in ('WN60','WN61','WN62','WN73','C3'): print(k,fire.get(k))
