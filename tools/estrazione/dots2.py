from common import *
import json
PAL={'verde':(1,160,85),'arancio':(238,160,58),'rosso':(236,36,46),'viola':(150,45,148),'marrone':(140,100,42),'blu':(60,170,232)}
names=list(PAL); P=np.array([PAL[n] for n in names])
Hh,Ww=RGB.shape[:2]
# compute nearest palette per pixel in chunks
lab=np.full((Hh,Ww),-1,np.int8)
for y0 in range(0,Hh,256):
    blk=RGB[y0:y0+256].astype(np.int32)
    d=((blk[:,:,None,:]-P[None,None,:,:])**2).sum(-1)
    k=d.argmin(-1); m=d.min(-1)<50*50
    lab[y0:y0+256][m]=k[m]
np.save('lab.npy',lab)
comps=[]
for ki,n in enumerate(names):
    m=(lab==ki).astype(np.uint8)
    num,cc,stats,cent=cv2.connectedComponentsWithStats(m,8)
    for i in range(1,num):
        x,y,w,h,a=stats[i]
        if a<120 or a>2500 or w>80 or h>80 or max(w,h)<26: continue
        pts=np.column_stack(np.where(cc[y:y+h,x:x+w]==i))[:,::-1]+[x,y]
        hull=cv2.convexHull(pts.astype(np.int32)); ha=cv2.contourArea(hull)
        comps.append(dict(col=n,x=float(cent[i][0]),y=float(cent[i][1]),a=int(a),w=int(w),h=int(h),fill=round(a/max(ha,1),3)))
json.dump(comps,open('comps.json','w'))
print(len(comps))
f=[c['fill'] for c in comps]; print(np.histogram(f,bins=10,range=(0,1.05)))
ar=[c['a'] for c in comps]; print(np.histogram(ar,bins=12))
