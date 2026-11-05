from common import *
import json, math
m=json.load(open('/home/claude/omaha-beach/data/mappa.json'))
H=m['hexes']
R_,G_,B_=[RGB[:,:,i].astype(int) for i in range(3)]
neu=(abs(R_-G_)<12)&(abs(G_-B_)<12)
rub1=((R_>=190)&(R_<=228)&(G_>=100)&(G_<=145)&(B_>=50)&(B_<=95)).astype(np.uint8)
rub2=((R_>=168)&(R_<=202)&(G_>=122)&(G_<=152)&(B_>=72)&(B_<=108)).astype(np.uint8)
near1=cv2.dilate(rub1,cv2.getStructuringElement(cv2.MORPH_ELLIPSE,(51,51)))
near2=cv2.dilate(rub2,cv2.getStructuringElement(cv2.MORPH_ELLIPSE,(41,41)))
at=(neu&(R_<75)&(near1>0)).astype(np.uint8)
sw=(neu&(R_>=80)&(R_<=165)&(near2>0)&(near1==0)).astype(np.uint8)
at=cv2.morphologyEx(at,cv2.MORPH_OPEN,cv2.getStructuringElement(cv2.MORPH_ELLIPSE,(3,3)))
sw=cv2.morphologyEx(sw,cv2.MORPH_OPEN,cv2.getStructuringElement(cv2.MORPH_ELLIPSE,(3,3)))
def nb(h):
    r,c=int(h[:2]),int(h[2:]); a=c if r%2==0 else c-1
    return [f"{r:02d}{c-1:02d}",f"{r:02d}{c+1:02d}"]+[f"{r+dr:02d}{x:02d}" for dr in (-1,1) for x in (a,a+1)]
def hit(mask,a,b):
    x1,y1=center(int(a[:2]),int(a[2:])); x2,y2=center(int(b[:2]),int(b[2:]))
    n=0
    for t in np.linspace(0.08,0.92,120):
        x=int(x1+(x2-x1)*t); y=int(y1+(y2-y1)*t)
        if mask[y-2:y+3,x-2:x+3].any(): n+=1
    return n
out={}
for h in H:
    for v in nb(h):
        if v in H and h<v:
            a=hit(at,h,v); s=hit(sw,h,v)
            if a>=2: out[h+'|'+v]='W'
            elif s>=2: out[h+'|'+v]='A'
print(len(out),out)
json.dump(out,open('obst.json','w'))
img=IMG.copy(); img[at>0]=(255,0,255); img[sw>0]=(0,255,255)
for k,c in out.items():
    a,b=k.split('|'); x1,y1=center(int(a[:2]),int(a[2:])); x2,y2=center(int(b[:2]),int(b[2:]))
    cv2.line(img,(int(x1),int(y1)),(int(x2),int(y2)),(0,0,255) if c=='W' else (255,0,0),6)
cv2.imwrite('ob.jpg',cv2.resize(img[2500:3700,1200:6300],None,fx=0.37,fy=0.37))
