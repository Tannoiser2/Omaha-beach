import json, os, shutil
from PIL import Image
Image.MAX_IMAGE_PIXELS=None
P='/home/claude/omaha-beach'
IM='/home/claude/src/mod/Mods/Images/'
tiles=json.load(open('/home/claude/src/tiles.json'))
def save_tile(idx, name, side='f'):
    f=tiles[idx][side]
    im=Image.open(IM+f).convert('RGB').resize((128,128),Image.LANCZOS)
    im.save(f'{P}/assets/pedine/{name}.jpg',quality=88)
    return name
# ---------- MAPPA
m=Image.open(IM+'httpssteamusercontentaakamaihdnetugc102620265285965100533DDA44DA90E280CACC5597E492098D72B57967B.jpg')
SC=0.6; Y0=990
crop=m.crop((0,Y0,7000,4529)).resize((int(7000*SC),int((4529-Y0)*SC)),Image.LANCZOS)
crop.save(f'{P}/assets/mappa.jpg',quality=86)
mp=json.load(open('omaha_map.json'))
mp['grid'].update(scala=SC,y_taglio=Y0)
json.dump(mp,open(f'{P}/data/mappa.json','w'),separators=(',',':'),ensure_ascii=False)
# ---------- UNITA US
# (id, div, tipo, turno, box, tile_full, [passi dal pieno: (simbolo, nero, attacco, gittata)], armi_ridotte(passo2), tile_rid, simbolo_rid, armi_1)
INF=[]
def inf(uid,div,turn,box,tile,sym,att,rng,sym2,w2,rtile,rsym,w1):
    return dict(id=uid,div=div,tipo='fanteria' if rng==1 else 'pesante',turno=turn,box=box,
      passi=[dict(s=sym,n=1,a=att,g=rng,img=f'{uid}_3',armi=[]),dict(s=sym2,n=1,a=4,g=1,img=f'{uid}_2',armi=w2),dict(s=rsym,n=0,a=2,g=1,img=f'{uid}_1',armi=[w1])],
      _t=[(tile,'f',f'{uid}_3'),(tile,'b',f'{uid}_2'),(rtile,'f',f'{uid}_1')])
U=[]
D,T,C='D','T','C'
U+= [inf('E/2/16',1,1,'ER6',100,D,6,1,D,['BZ','BG','RD'],154,D,'BG'),
 inf('I/3/16',1,1,'FG2',108,D,6,1,D,['BZ','BG','RD'],151,D,'RD'),
 inf('L/3/16',1,1,'FG5',109,C,6,1,C,['BG','MO','BR'],152,C,'BR'),
 inf('F/2/16',1,1,'ER3',101,T,6,1,T,['BZ','BR','DE'],153,T,'BR'),
 inf('K/3/16',1,3,'FG4',106,T,6,1,T,['BZ','BR','DE'],149,T,'BZ'),
 inf('G/2/16',1,3,'ER2',107,C,6,1,C,['BG','MO','BR'],150,C,'MO'),
 inf('H/2/16',1,4,'ER4',103,D,7,2,D,['DE','MG','MO'],147,D,'DE'),
 inf('M/3/16',1,4,'FG4',104,C,7,2,C,['DE','MO','MG'],148,C,'MO'),
 inf('B/1/16',1,6,'ER',118,T,6,1,T,['BZ','BR','DE'],145,T,'DE'),
 inf('A/1/16',1,6,'ER',173,D,6,1,D,['BZ','BG','RD'],146,D,'BZ'),
 inf('C/1/16',1,6,'ER',117,C,6,1,C,['BG','MO','BR'],144,C,'BG'),
 inf('D/1/16',1,7,'ER',116,T,7,2,T,['DE','MG','MO'],143,T,'MG'),
 inf('F/2/18',1,16,'1',120,D,6,1,D,['BZ','BR','DE'],141,D,'BR'),
 inf('E/2/18',1,16,'1',123,C,6,1,C,['BZ','BG','RD'],142,C,'BG'),
 inf('G/2/18',1,16,'1',119,T,6,1,T,['BG','MO','BR'],140,T,'MO'),
 inf('H/2/18',1,16,'1',124,C,7,2,C,['DE','MG','MO'],139,C,'DE'),
 inf('A/1/18',1,20,'1',166,D,6,1,D,['BZ','BG','RD'],138,D,'BZ'),
 inf('B/1/18',1,20,'1',165,T,6,1,T,['BZ','BR','DE'],137,T,'DE'),
 inf('D/1/18',1,20,'1',163,D,7,2,D,['DE','MG','MO'],135,D,'MG'),
 inf('C/1/18',1,20,'1',164,C,6,1,C,['BG','MO','BR'],136,C,'BG'),
 inf('I/3/18',1,22,'1',162,T,6,1,T,['BZ','BG','RD'],134,T,'RD'),
 inf('K/3/18',1,22,'1',161,C,6,1,C,['BG','BR','DE'],133,C,'BZ'),
 inf('M/3/18',1,22,'1',159,T,7,2,T,['DE','MO','MG'],131,T,'MO'),
 inf('L/3/18',1,22,'1',160,D,6,1,D,['BG','MO','BR'],132,D,'BR'),
 inf('A/1/116',29,1,'DG4',14,C,6,1,C,['BZ','BG','RD'],53,C,'BZ'),
 inf('G/2/116',29,1,'DW3',11,D,6,1,D,['MO','BG','BR'],54,D,'MO'),
 inf('F/2/116',29,1,'DR2',10,T,6,1,T,['BZ','DE','BR'],57,T,'BR'),
 inf('E/2/116',29,1,'EG3',9,C,6,1,C,['BZ','BG','RD'],56,C,'BG'),
 inf('B/1/116',29,3,'DG2',30,C,6,1,C,['BZ','DE','BR'],51,C,'DE'),
 inf('H/2/116',29,3,'DR1',12,D,7,2,D,['MO','DE','MG'],52,D,'DE'),
 inf('L/3/116',29,4,'EG2',27,D,6,1,D,['MO','BG','BR'],49,D,'BR'),
 inf('K/3/116',29,4,'DW2',24,C,6,1,C,['BZ','DE','BR'],47,C,'BZ'),
 inf('I/3/116',29,4,'DR2',25,T,6,1,T,['BZ','BG','RD'],48,T,'RD'),
 inf('C/1/116',29,4,'DG1',23,D,6,1,D,['MO','BG','BR'],68,D,'BG'),
 inf('D/1/116',29,4,'DG3',28,T,7,2,T,['MO','DE','MG'],50,T,'MG'),
 inf('M/3/116',29,5,'DR',22,T,7,2,T,['MO','DE','MG'],87,T,'MO'),
 inf('C/1/115',29,16,'29',34,T,6,1,T,['MO','BG','BR'],76,T,'BG'),
 inf('B/1/115',29,16,'29',33,D,6,1,D,['BZ','DE','BR'],75,D,'DE'),
 inf('D/1/115',29,16,'29',35,C,7,2,C,['MO','DE','MG'],77,C,'MG'),
 inf('E/2/115',29,16,'29',36,D,6,1,D,['BZ','BG','RD'],71,D,'BG'),
 inf('A/1/115',29,16,'29',32,C,6,1,C,['BZ','BG','RD'],74,C,'BZ'),
 inf('F/2/115',29,16,'29',37,T,6,1,T,['BZ','DE','BR'],70,T,'BR'),
 inf('G/2/115',29,16,'29',38,C,6,1,C,['MO','BG','BR'],72,C,'MO'),
 inf('H/2/115',29,16,'29',39,D,7,2,D,['MO','DE','MG'],73,D,'DE'),
 inf('L/3/115',29,19,'29',42,D,6,1,D,['MO','BG','BR'],79,D,'BR'),
 inf('K/3/115',29,19,'29',41,C,6,1,C,['BZ','DE','BR'],69,C,'BZ'),
 inf('I/3/115',29,19,'29',40,T,6,1,T,['BZ','BG','RD'],78,T,'RD'),
 inf('M/3/115',29,19,'29',43,T,7,2,T,['MO','DE','MG'],63,T,'MO'),
]
def two(uid,div,tipo,turn,box,tile,sym,n1,a1,g,sym2,n2,a2,w2=None,extra=None):
    u=dict(id=uid,div=div,tipo=tipo,turno=turn,box=box,passi=[dict(s=sym,n=n1,a=a1,g=g,img=f'{uid}_2',armi=[]),dict(s=sym2,n=n2,a=a2,g=g,img=f'{uid}_1',armi=w2 or [])],_t=[(tile,'f',f'{uid}_2'),(tile,'b',f'{uid}_1')])
    return u
U+=[two('C/2R',29,'ranger',1,'CH2',0,T,1,3,1,T,0,2,['BR','BG']),
 two('A-B/2R',29,'ranger',5,'DG',1,D,1,5,1,D,0,3,['BZ','BG','RD']),
 two('C-D/5R',29,'ranger',6,'DG',2,C,1,5,1,C,0,3,['BZ','DE','BR']),
 two('E-F/5R',29,'ranger',6,'DG',246,D,1,5,1,D,0,3,['MO','BG','BR']),
 two('A-B/5R',29,'ranger',6,'DG',13,T,1,5,1,T,0,3,['BZ','BG','RD'])]
for uid,div,turn,box,tile,sym in [('1/B/743',29,0,'DG2',5,T),('2/B/743',29,0,'DG3',6,C),('2/C/743',29,0,'DW3',4,C),('1/C/743',29,0,'DW1',3,D),
  ('1/B/741',1,0,'FG2',95,D),('2/B/741',1,0,'FG5',96,T),('1/C/741',1,0,'ER3',97,C),('2/C/741',1,0,'ER5',98,D),
  ('1/A/741',1,1,'FG4',99,T),('2/A/741',1,1,'ER2',172,C),('1/A/743',29,1,'DR3',8,D),('2/A/743',29,1,'EG2',7,T)]:
    U.append(two(uid,div,'carro',turn,box,tile,sym,1,4,5,sym,1,2))
for uid,div,turn,box,tile,sym in [('1-2/397',1,3,'FG5',105,D),('3-4/397',29,3,'EG3',29,D),('5-6/397',29,3,'DW3',82,T)]:
    U.append(two(uid,div,'antiaerea',turn,box,tile,sym,0,4,3,sym,0,2))
for uid,div,turn,box,tile,sym in [('A-B/197',1,9,'FG',111,C),('C-D/197',1,9,'ER',110,D),('A-B/467',29,9,'EG',17,C),('C-D/467',29,9,'DW',16,T)]:
    U.append(two(uid,div,'antiaerea_sp',turn,box,tile,sym,1,3,3,sym,1,1))
for uid,div,turn,box,tile,sym in [('AT/16',1,9,'ER',122,T),('AT/116',29,9,'DR',15,D),('AT/115',29,20,'29',45,D),('AT/18',1,23,'1',157,C)]:
    U.append(dict(id=uid,div=div,tipo='anticarro',turno=turn,box=box,passi=[dict(s=sym,n=0,a=2,g=5,img=f'{uid}_1',armi=[])],_t=[(tile,'f',f'{uid}_1')]))
U.append(two('A-C/81C',1,'artiglieria',5,'FG',102,T,1,4,99,T,0,2))
U.append(two('B-D/81C',29,'artiglieria',5,'DW',26,C,0,4,99,C,0,2))
U.append(two('Can/16',1,'artiglieria',8,'ER',112,C,0,3,99,T,0,1))
U.append(two('Can/116',29,'artiglieria',8,'DW',18,C,0,3,99,C,0,1))
def art4(uid,div,tipo,turn,box,big,small,sym,n):
    st=[dict(s=sym,n=1,a=9,g=99,img=f'{uid}_4',armi=[]),dict(s=sym,n=1,a=6,g=99,img=f'{uid}_3',armi=[]),dict(s=sym,n=1,a=4,g=99,img=f'{uid}_2',armi=[])]
    t=[(big,'f',f'{uid}_4'),(big,'b',f'{uid}_3'),(small,'f',f'{uid}_2')]
    if n==4:
        st.append(dict(s=sym,n=1,a=2,g=99,img=f'{uid}_1',armi=[])); t.append((small,'b',f'{uid}_1'))
    return dict(id=uid,div=div,tipo=tipo,turno=turn,box=box,passi=st,_t=t)
U.append(art4('62AFA',1,'artiglieria_sp',7,'FG',114,130,C,3))
U.append(art4('58AFA',29,'artiglieria_sp',7,'DW',20,80,D,4))
U.append(art4('7FA',1,'artiglieria',8,'ER',113,129,D,3))
U.append(art4('111FA',29,'artiglieria',8,'EG',19,81,T,4))
for uid,div,turn,box,tile in [('16 HQ',1,7,'FG',115),('116 HQ',29,5,'DW',21),('115 HQ',29,19,'29',44),('18 HQ',1,22,'1',158)]:
    U.append(dict(id=uid,div=div,tipo='hq',turno=turn,box=box,passi=[dict(s='',n=0,a=0,g=0,img=f'{uid}',armi=['RD'])],_t=[(tile,'f',uid)]))
U.append(dict(id='Gen. Cota',div=29,tipo='generale',turno=5,box='DW',passi=[dict(s='',n=0,a=0,g=0,img='Cota',armi=[])],_t=[(31,'f','Cota'),(31,'b','Cota_ferito')]))
U.append(dict(id='Gen. Wyman',div=1,tipo='generale',turno=10,box='1',passi=[dict(s='',n=0,a=0,g=0,img='Wyman',armi=[])],_t=[(121,'f','Wyman'),(121,'b','Wyman_ferito')]))
for u in U:
    for idx,side,name in u.pop('_t'):
        save_tile(idx,name.replace('/','_'),side)
    for p in u['passi']: p['img']=p['img'].replace('/','_')
json.dump(U,open(f'{P}/data/unita.json','w'),indent=0,ensure_ascii=False)
# eroi e segnalini
eroi={1:[170,169,168,167,171],29:[59,58,62,61,60]}
E=[]
for div,l in eroi.items():
    for i,idx in enumerate(l):
        save_tile(idx,f'eroe_{div}_{i}','f'); save_tile(idx,f'ispirato_{div}_{i}','b'); E.append(dict(div=div,img=f'eroe_{div}_{i}',img2=f'ispirato_{div}_{i}'))
json.dump(E,open(f'{P}/data/eroi.json','w'))
for idx,name,side in [(206,'confusione_us','f'),(235,'confusione_de','f'),(210,'navale','f'),(214,'scalata','f'),(214,'scalata_scogliera','b'),(219,'bonificato','f'),(241,'fumo','f'),(128,'azione','f'),(244,'art_1352','f'),(245,'art_flak','f'),(244,'art_inattiva','b'),(90,'trasferimento_1','f'),(90,'trasferimento_29','b')]:
    save_tile(idx,name,side)
print(len(U))
