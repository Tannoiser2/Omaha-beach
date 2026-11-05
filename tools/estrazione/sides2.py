from common import *
import json,math
Hh,Ww=RGB.shape[:2]
T=json.load(open('terrain_cls.json'))['cls']
def nb(r,c):
    x,y=center(r,c); out=[]
    for rr in (r-1,r,r+1):
        for cc in (c-1,c,c+1):
            if (rr,cc)==(r,c): continue
            x2,y2=center(rr,cc)
            if math.hypot(x2-x,y2-y)<W*1.1: out.append((rr,cc))
    return out
def runs(b):
    b=np.asarray(b,int); return int(((b[1:]-b[:-1])==1).sum()+b[0])
out={}
for h in T:
    r,c=int(h[:2]),int(h[2:])
    for (rr,cc) in nb(r,c):
        h2=f"{rr:02d}{cc:02d}"
        if h2 not in T or h2<h: continue
        x1,y1=center(r,c); x2,y2=center(rr,cc)
        mx,my=(x1+x2)/2,(y1+y2)/2
        ux,uy=(x2-x1),(y2-y1); L=math.hypot(ux,uy); ux/=L; uy/=L; vx,vy=-uy,ux
        best={}
        for o in range(-4,5):
            ts=np.linspace(-0.42,0.42,90)
            xs=np.clip((mx+vx*SIZE*ts+ux*o).astype(int),0,Ww-1); ys=np.clip((my+vy*SY*ts+uy*o).astype(int),0,Hh-1)
            p=RGB[ys,xs]; R,G,B=p[:,0],p[:,1],p[:,2]
            red=(R>190)&(G<100)&(B<110)
            brr=(R>235)&(G<40)&(B<40)
            grey=(abs(R-G)<12)&(abs(G-B)<12)&(R>100)&(R<175)
            dark=(abs(R-G)<14)&(abs(G-B)<14)&(R<100)
            white=(R>238)&(G>238)&(B>238)
            for k,m in (('red',red),('brr',brr),('grey',grey),('dark',dark)):
                v=(m.mean(),runs(m),white.mean())
                if k not in best or v[0]>best[k][0]: best[k]=v
                if k=='grey' and 0.2<v[0]<0.8 and v[1]>=5: best['slope']=True
        # brown near (seawall/AT)
        xs=[];ys=[]
        for t in np.linspace(-0.4,0.4,30):
            for o in range(-14,15,2): xs.append(int(mx+vx*SIZE*t+ux*o)); ys.append(int(my+vy*SY*t+uy*o))
        p=RGB[np.clip(ys,0,Hh-1),np.clip(xs,0,Ww-1)]; R,G,B=p[:,0],p[:,1],p[:,2]
        brown=((R>150)&(G>70)&(G<150)&(B<110)&(R-G>45)).mean()
        k=None
        LOW={'spiaggia','pianoro'}; HIGH={'altura','bocage','bosco'}
        t1,t2=T[h],T[h2]
        bnd=(t1 in LOW and t2 in HIGH) or (t2 in LOW and t1 in HIGH)
        rough=('accidentato' in (t1,t2))
        if best['brr'][0]>0.5: k='X'
        elif best['red'][0]>0.2 and best['red'][1]>=3: k='B'
        elif best['dark'][0]>0.55: k='W' if brown>0.06 else 'C'
        elif best.get('slope'): k='L'
        if bnd and k not in ('X','C','W','B','L'): k='B?'
        if not bnd and k in ('B','L'): k=None
        if k: out[h+'|'+h2]=k
json.dump(out,open('sides_cls.json','w')); print(len(out))
img=IMG.copy()
for kk,c in out.items():
    a,b=kk.split('|'); x1,y1=center(int(a[:2]),int(a[2:])); x2,y2=center(int(b[:2]),int(b[2:]))
    cv2.putText(img,c,(int((x1+x2)/2)-12,int((y1+y2)/2)+12),cv2.FONT_HERSHEY_SIMPLEX,1.2,(0,0,0),5)
    cv2.putText(img,c,(int((x1+x2)/2)-12,int((y1+y2)/2)+12),cv2.FONT_HERSHEY_SIMPLEX,1.2,(255,255,0),2)
cv2.imwrite('s1.jpg',cv2.resize(img[2400:3800,900:4100],None,fx=0.42,fy=0.42))
cv2.imwrite('s2.jpg',cv2.resize(img[2400:3900,3900:7000],None,fx=0.42,fy=0.42))
