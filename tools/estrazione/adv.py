from common import *
import json, math
m=json.load(open('/home/claude/omaha-beach/data/mappa.json'))
P=m['pos']
VP=set("A4 A5 A6 A7 A8 A9 B1 B2 B5 B6 C4 C5 C6 C7 C8 C9 D3 D4 D5 D6 D7 D8 D9 D10 E1 E2 E3 E4 E5 E7 E8 E9 E11 F1 G1 G2 G3 G4 G5 R0732 R0828 R1024".split())
AR={'A6':58,'A7':57,'A9':94,'B2':52,'B3':89,'B7':124,'B8':124,'C2':126,'C3':92,'C4':121,'C5':126,'C7':58,'C8':58,'C9':149,'D3':92,'D6':90,'D7':92,'D8':127,
'E1':128,'E2':93,'E7':58,'E9':86,'E10':33,'E11':57,'F1':126,'F2':125,'F3':147,'F4':123,'F5':-177,'F6':92,'F7':92,'F9':124,'G1':120,'G2':127,'G4':170,'G5':92,'G6':149,'G7':123,'G8':125}
def ax(h):
    r,c=int(h[:2]),int(h[2:]); return c-(r+(r&1))//2, r
def hd(a,b):
    q1,r1=ax(a); q2,r2=ax(b); return (abs(q1-q2)+abs(r1-r2)+abs(q1+r1-q2-r2))//2
dest={}
for k,a in AR.items():
    h=P[k]['hex'][0]; x,y=center(int(h[:2]),int(h[2:]))
    best=None
    for k2,p2 in P.items():
        if k2==k or p2['tipo']!='R': continue
        h2=p2['hex'][0]; x2,y2=center(int(h2[:2]),int(h2[2:]))
        ang=math.degrees(math.atan2(y2-y,x2-x)); da=abs((ang-a+180)%360-180)
        d=hd(h,h2)
        if da<=32 and d<=4:
            sc=d+da/20
            if best is None or sc<best[0]: best=(sc,k2,d,round(da))
    dest[k]=best
for k,v in dest.items(): print(k,v)
