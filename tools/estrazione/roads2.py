from common import *
import json, math
from skimage.morphology import skeletonize
m=json.load(open('/home/claude/omaha-beach/data/mappa.json'))
H=m['hexes']; Hh,Ww=RGB.shape[:2]
R_,G_,B_=RGB[:,:,0].astype(int),RGB[:,:,1].astype(int),RGB[:,:,2].astype(int)
neutral=(abs(R_-G_)<10)&(abs(G_-B_)<10)
cls=np.zeros((Hh,Ww),np.uint8)
cls[neutral&(R_>=138)&(R_<=174)]=1   # principale
cls[neutral&(R_>=176)&(R_<=205)]=2   # secondaria/sentiero
cls[(R_>200)&(G_>70)&(G_<150)&(B_<90)&(R_-G_>70)]=3  # minata (arancio)
k5=cv2.getStructuringElement(cv2.MORPH_ELLIPSE,(5,5))
k3=cv2.getStructuringElement(cv2.MORPH_ELLIPSE,(3,3))
op=cv2.morphologyEx(((cls==1)|(cls==3)).astype(np.uint8),cv2.MORPH_OPEN,k5)|cv2.morphologyEx((cls==2).astype(np.uint8),cv2.MORPH_OPEN,k3)
open_raw=op.copy()
# chiude i tratteggi dei sentieri
o1=cv2.morphologyEx(((cls==1)|(cls==3)).astype(np.uint8),cv2.MORPH_OPEN,k5)
o2=cv2.morphologyEx((cls==2).astype(np.uint8),cv2.MORPH_OPEN,k3)
cl=cv2.morphologyEx(o1,cv2.MORPH_CLOSE,cv2.getStructuringElement(cv2.MORPH_ELLIPSE,(21,21)))|cv2.morphologyEx(o2,cv2.MORPH_CLOSE,cv2.getStructuringElement(cv2.MORPH_ELLIPSE,(45,45)))
n,cc,st,_=cv2.connectedComponentsWithStats(cl,8)
keep=np.zeros_like(cl)
for i in range(1,n):
    x,y,w,h,a=st[i]
    if max(w,h)>=150: keep[cc==i]=1
np.save('roadmask.npy',keep)
sk=skeletonize(keep>0)
ys,xs=np.where(sk)
print('skel px',len(xs))
# hex id per skeleton pixel
hid={}
def hexat(x,y):
    r,c=pix2hex(x,y); return f"{r:02d}{c:02d}"
lab={}
for x,y in zip(xs,ys): lab[(x,y)]=hexat(x,y)
cnt={}
typ={}
cov={}
for (x,y),h in lab.items():
    for dx in (-1,0,1):
        for dy in (-1,0,1):
            q=(x+dx,y+dy)
            if q in lab and lab[q]!=h:
                k2='|'.join(sorted([h,lab[q]]))
                cnt[k2]=cnt.get(k2,0)+1
                w=cls[max(0,y-8):y+9,max(0,x-8):x+9].ravel()
                w=w[w>0]
                if len(w): typ.setdefault(k2,[]).extend(w.tolist())
                cov.setdefault(k2,[]).append(int(open_raw[y,x]>0))
out={}
for k2,c in cnt.items():
    a,b=k2.split('|')
    if a not in H or b not in H: continue
    t=np.bincount(typ.get(k2,[0]),minlength=4)
    tt={1:'P',2:'S',3:'M'}[int(np.argmax(t[1:]))+1] if t[1:].sum() else 'S'
    out[k2]=tt
json.dump(out,open('roads.json','w'))
from collections import Counter
print(len(out),Counter(out.values()))
