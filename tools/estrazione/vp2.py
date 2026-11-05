from common import *
import json
lab=np.load('lab.npy')
names=['verde','arancio','rosso','viola','marrone','blu']
m=json.load(open('/home/claude/omaha-beach/data/mappa.json'))
P=m['pos']
def maskfor(k):
    h=P[k]['hex'][0]; r,c=int(h[:2]),int(h[2:]); cx,cy=center(r,c)
    ki=names.index(P[k]['col'])
    x0,y0=int(cx-75),int(cy-80)
    mm=(lab[y0:y0+160,x0:x0+150]==ki).astype(np.uint8)*255
    return mm
d7=maskfor('D7')
# template: region of VP in D7 (above center)
sub=d7[80-95:80-40,75-30:75+30] if False else d7[0:60,40:110]
ys,xs=np.where(sub>0); 
tpl=sub[ys.min():ys.max()+1, xs.min():xs.max()+1]
print('tpl',tpl.shape)
cv2.imwrite('tpl.png',tpl)
res={}
for k,p in P.items():
    if p['tipo']!='R': continue
    mm=maskfor(k)
    # escludo il bordo
    inner=np.zeros_like(mm); cv2.ellipse(inner,(75,80),(62,66),0,0,360,255,-1)
    mm=cv2.bitwise_and(mm,inner)
    r=cv2.matchTemplate(mm,tpl,cv2.TM_CCOEFF_NORMED)
    res[k]=round(float(r.max()),2)
print(sorted(res.items(),key=lambda x:-x[1]))
json.dump(res,open('vp2.json','w'))
