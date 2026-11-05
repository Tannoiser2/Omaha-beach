from common import *
import json, math, pytesseract, re
m=json.load(open('/home/claude/omaha-beach/data/mappa.json'))
P=m['pos']
res={}
for k,p in P.items():
    h=p['hex'][0]; r,c=int(h[:2]),int(h[2:]); cx,cy=center(r,c)
    x0,y0=int(cx-80),int(cy-85)
    crop=RGB[y0:y0+170,x0:x0+160].astype(int)
    # freccia: grigio scuro
    R_,G_,B_=crop[:,:,0],crop[:,:,1],crop[:,:,2]
    tri=((abs(R_-G_)<8)&(abs(G_-B_)<8)&(R_>70)&(R_<115)).astype(np.uint8)
    tri=cv2.morphologyEx(tri,cv2.MORPH_OPEN,cv2.getStructuringElement(cv2.MORPH_ELLIPSE,(5,5)))
    n,cc,st,ce=cv2.connectedComponentsWithStats(tri,8)
    arrow=None
    best=None
    for i in range(1,n):
        if 250<st[i][4]<1400 and max(st[i][2],st[i][3])<60:
            if best is None or st[i][4]>st[best][4]: best=i
    if best:
        ys,xs=np.where(cc==best); gx,gy=xs.mean(),ys.mean()
        d=np.hypot(xs-gx,ys-gy); j=d.argmax()
        ang=math.degrees(math.atan2(ys[j]-gy,xs[j]-gx))
        arrow=round(ang)
    # VP: OCR
    big=cv2.resize(cv2.cvtColor(RGB[y0:y0+170,x0:x0+160].astype(np.uint8),cv2.COLOR_RGB2GRAY),None,fx=2,fy=2)
    t=pytesseract.image_to_string(big,config='--psm 11 -c tessedit_char_whitelist=VPABCDEFG0123456789')
    vp='VP' in t
    res[k]=dict(arrow=arrow,vp=vp,txt=t.replace('\n',' '))
json.dump(res,open('vparrow.json','w'),indent=0)
print(sum(v['vp'] for v in res.values()),'VP')
for k,v in res.items():
    if P[k]['tipo']=='R': print(k,v['arrow'],v['vp'],v['txt'][:30])
