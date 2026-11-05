import cv2, pytesseract, json, re
img=cv2.imread('/home/claude/src/mod/Mods/Images/httpssteamusercontentaakamaihdnetugc102620265285965100533DDA44DA90E280CACC5597E492098D72B57967B.jpg')
H,W=img.shape[:2]
rot=cv2.rotate(img,cv2.ROTATE_90_CLOCKWISE)  # text reading upward becomes horizontal
gray=cv2.cvtColor(rot,cv2.COLOR_BGR2GRAY)
up=cv2.resize(gray,None,fx=2,fy=2,interpolation=cv2.INTER_CUBIC)
res=[]
RH,RW=up.shape
step=1600
for y0 in range(0,RH,step-200):
  for x0 in range(0,RW,step-200):
    tile=up[y0:y0+step,x0:x0+step]
    d=pytesseract.image_to_data(tile,config='--psm 11 -c tessedit_char_whitelist=0123456789',output_type=pytesseract.Output.DICT)
    for i,t in enumerate(d['text']):
      t=t.strip()
      if re.fullmatch(r'\d{4}',t) and int(d['conf'][i])>50:
        cx=(x0+d['left'][i]+d['width'][i]/2)/2; cy=(y0+d['top'][i]+d['height'][i]/2)/2
        # rotated coords (cx,cy) -> original: rotate CW: orig x = cy, orig y = H-1-cx
        res.append((t, cy, H-1-cx, int(d['conf'][i])))
json.dump(res,open('labels.json','w'))
print(len(res))
