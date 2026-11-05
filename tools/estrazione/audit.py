import json, math, sys
sys.path.insert(0,'.')
m=json.load(open('/home/claude/omaha-beach/data/mappa.json'))
H=m['hexes']; P=m['pos']; F=m['fire']; S=m['sides']
def rc(h): return int(h[:2]),int(h[2:])
def ax(h):
    r,c=rc(h); return c-(r+(r&1))//2, r
def hd(a,b):
    q1,r1=ax(a); q2,r2=ax(b); return (abs(q1-q2)+abs(r1-r2)+abs(q1+r1-q2-r2))//2
def nb(h):
    r,c=rc(h); a=c if r%2==0 else c-1
    return [f"{r:02d}{c-1:02d}",f"{r:02d}{c+1:02d}"]+[f"{r+dr:02d}{x:02d}" for dr in (-1,1) for x in (a,a+1)]
print("== buchi: esagoni con tutti i 6 vicini presenti ma assenti")
for r in range(2,21):
    for c in range(1,37):
        h=f"{r:02d}{c:02d}"
        if h not in H and sum(v in H for v in nb(h))>=5: print(" manca",h)
print("== posizioni di rinforzo: vicini senza fuoco")
for k,p in P.items():
    g=p.get('gruppo',k); f=F.get(g,{})
    hx=p['hex'][0]
    miss=[v for v in nb(hx) if v in H and v not in f]
    far=[h for h in f if min(hd(h,x) for x in p['hex'])>(5 if p['tipo']=='WN' else 2)]
    if p['tipo']=='R' and (miss or far): print(" ",k,hx,p['col'],"campo",len(f),"vicini senza fuoco",miss,"lontani",far)
    if p['tipo']=='WN' and far: print(" ",k,"lontani",far)
print("== WN: dimensione campi")
for g in sorted(set(p.get('gruppo',k) for k,p in P.items() if p['tipo']=='WN')):
    f=F.get(g,{}); print(" ",g,len(f),"intensi",sum(1 for v in f.values() if v==3), "spiaggia",sum(1 for h in f if H.get(h,{}).get('t')=='spiaggia'))
print("== posizioni dentro un campo dello stesso colore di altra posizione")
from collections import defaultdict
col_hex=defaultdict(list)
for g,f in F.items():
    col=[p['col'] for k,p in P.items() if p.get('gruppo',k)==g][0]
    for h in f: col_hex[(col,h)].append(g)
dup=[(k,v) for k,v in col_hex.items() if len(v)>1]
print(" sovrapposizioni stesso colore:",len(dup), dup[:15])
print("== lati")
from collections import Counter
print(Counter(S.values()))
for k,v in S.items():
    a,b=k.split('|'); ta,tb=H[a]['t'],H[b]['t']
    if v in 'BCX' and not ({ta,tb}&{'spiaggia','pianoro','accidentato'}): print(" lato",v,"fra",a,ta,b,tb)
print("== terreno per riga (spiaggia oltre riga 8)")
for h,d in sorted(H.items()):
    r,c=rc(h)
    if d['t']=='spiaggia' and r>=8: print(" spiaggia alta",h)
    if d['t'] in ('altura','bocage','bosco') and r<=5: print(" altura bassa",h,d['t'])
print("== sbarco")
for b,v in m['boxes'].items():
    for k in ('bassa','media','alta'):
        if k in v and H.get(v[k],{}).get('t')!='spiaggia': print(" ",b,k,v[k],H.get(v[k],{}).get('t'))
