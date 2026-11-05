import json
p='/home/claude/omaha-beach/data/mappa.json'
m=json.load(open(p)); H=m['hexes']; S=m['sides']
ob=json.load(open('obst.json'))
n=0
for k,v in ob.items():
    a,b=k.split('|'); ta,tb=H[a]['t'],H[b]['t']
    if k in S: continue
    if v=='W' or ({ta,tb}=={'spiaggia','pianoro'}):
        S[k]=v; n+=1
# completo il fosso di E-1
for k in ['0718|0818']:
    S[k]='W'
def nb(h):
    r,c=int(h[:2]),int(h[2:]); a=c if r%2==0 else c-1
    return [f"{r:02d}{c-1:02d}",f"{r:02d}{c+1:02d}"]+[f"{r+dr:02d}{x:02d}" for dr in (-1,1) for x in (a,a+1)]
g=0
for h,d in H.items():
    if d['t']!='spiaggia': continue
    for v in nb(h):
        if v in H and H[v]['t']=='pianoro':
            k=h+'|'+v if h<v else v+'|'+h
            if k not in S: S[k]='G'; g+=1
print('ostacoli',n,'ciottoli',g)
for d in H.values(): d.pop('cio',None)
roads=json.load(open('roads.json'))
m['strade']={k:v for k,v in roads.items() if k.split('|')[0] in H and k.split('|')[1] in H}
VP=set("A4 A5 A6 A7 A8 A9 B1 B2 B5 B6 C4 C5 C6 C7 C8 C9 D3 D4 D5 D6 D7 D8 D9 D10 E1 E2 E3 E4 E5 E7 E8 E9 E11 F1 G1 G2 G3 G4 G5 R0732 R0828 R1024".split())
ADV={'A6':['A2'],'A7':['A1'],'A9':['A5'],'B1':['A7','A6'],'B2':['A9'],'B3':['B1'],'B7':['B3'],'B8':['B7'],'C2':['R1014'],'C3':['C1'],'C4':['A4'],'C5':['C3'],'C7':['D5'],'C8':['C7'],'C9':['C8'],
'D3':['R1119'],'D6':['D4'],'D7':['D3'],'D8':['D5'],'E1':['R1024'],'E2':['R0828'],'E7':['E5'],'E9':['E8'],'E10':['E8'],'E11':['E9'],'F1':['E2'],'F2':['F1'],'F3':['E7'],'F4':['G6'],'F5':['E9'],
'F6':['F4'],'F7':['F2'],'F9':['F6'],'G1':['R0434'],'G2':['R0732'],'G4':['G2'],'G5':['G3'],'G6':['G5'],'G7':['G2'],'G8':['G4']}
for k,pp in m['pos'].items():
    if pp['tipo']=='R':
        pp['vp']=1 if k in VP else 0
        if k in ADV: pp['avanza']=ADV[k]
print('vp',sum(pp.get('vp',0) for pp in m['pos'].values()))
json.dump(m,open(p,'w'),separators=(',',':'),ensure_ascii=False)
from collections import Counter
print(Counter(S.values()), len(m['strade']))
