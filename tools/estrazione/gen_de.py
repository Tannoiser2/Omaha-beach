import json
from PIL import Image
P='/home/claude/omaha-beach'; IM='/home/claude/src/mod/Mods/Images/'
tiles=json.load(open('/home/claude/src/tiles.json'))
def save(idx,name,side='f'):
    Image.open(IM+tiles[idx][side]).convert('RGB').resize((128,128),Image.LANCZOS).save(f'{P}/assets/pedine/{name}.jpg',quality=88)
G={}
wn=[(298,['BZ','BR'],2,''),(296,['MO','MG'],2,'75'),(299,['BG'],1,''),(290,['BZ','MG'],2,'88'),(300,['MO','BR'],1,''),(295,['BG','BZ'],3,'75'),
(291,['MO','BZ'],1,'75'),(289,['BG','MO'],2,'88'),(305,['BG'],1,''),(303,['BR'],1,''),(301,['BG'],2,''),(294,['BG','BR'],3,'75'),(292,['BG','MG'],2,'75'),
(304,['BZ'],2,''),(293,['BG','BZ'],2,'75'),(302,['BZ'],1,''),(306,['BG'],1,''),(297,['MO','BZ'],1,'razzi')]
G['wn']=[]
for i,(t,w,f,a) in enumerate(wn):
    save(t,f'wn_{i}'); G['wn'].append(dict(img=f'wn_{i}',armi=w,forza=f,cal=a))
save(298,'wn_retro','b')
dm={'wn':[(278,[],0,1),(279,['DE'],1,0),(276,['RD'],1,0),(277,['NA'],2,0),(271,['AR'],2,0),(272,[],0,1),(273,[],0,1),(274,['DE'],2,0),(275,['AR','RD'],1,0),
(280,['DE'],1,0),(281,['AR','RD'],2,0),(282,['FL','AR'],2,0),(288,['NA'],1,0),(287,[],0,1),(283,['NA'],2,0),(286,['RD'],2,0),(284,['AR','DE'],1,0),(285,['AR'],1,0)],
'mobile':[(268,['AR'],1,0),(357,['MG','FL'],3,0),(356,['MG'],1,0),(349,['FL'],2,0),(355,['AR'],2,0),(350,['DE'],1,0),(351,['RD','FL'],2,0),(352,['MG','FL'],2,0),(353,['MG'],2,0),
(354,['RD','MO'],2,0),(358,['RD','MO'],3,0),(339,['MO'],1,0),(340,['RD'],1,0),(343,['DE','FL'],2,0),(341,['AR','RD'],1,0),(342,['AR'],1,0),(344,['FL','RD'],1,0),(345,['MG','MO'],2,0),
(348,['FL','MO'],1,0),(346,['AR'],1,0),(347,['AR'],2,0),(336,['MG'],2,0),(335,['MG','MO'],1,0),(337,['FL','RD'],1,0),(338,['AR'],3,0)],
'edificio':[(359,[],2,0),(361,['NA'],1,0),(366,['RD','DE'],2,0),(360,['AR','DE'],1,0),(362,['RD','DE'],3,0),(365,['AR'],3,0),(363,['FL','DE'],2,0),(364,['FL'],3,0)]}
# il mod ha 25 mobile: 268 e' il segnalino espositore sopra il sacchetto, lo togliamo
dm['mobile']=[x for x in dm['mobile'] if x[0]!=268]
G['dm']={}
for k,l in dm.items():
    G['dm'][k]=[]
    for i,(t,w,f,tac) in enumerate(l):
        save(t,f'dm_{k}_{i}'); G['dm'][k].append(dict(img=f'dm_{k}_{i}',armi=w,forza=f,tattico=bool(tac)))
    save(l[0][0],f'dm_{k}_retro','b')
rin={'T':[(307,'5/2/916',['FL','BR'],4,352),(315,'11/3/726',['BZ'],1,716),(314,'8/2/916',['BZ','BR'],3,352),(308,'7/2/916',['FL','BZ'],4,352),(313,'9/3/726',['FL'],3,716),
(312,'10/3/726',['BZ','BR'],1,716),(310,'3/1/726',['BR'],2,716),(309,'1/1/726',['BR'],1,716),(311,'6/2/916',['FL','BZ'],2,352)],
'D':[(317,'7/2/915',['FL','BR'],4,352),(316,'8/2/915',['BR','BZ'],4,352),(318,'6/2/915',['FL','BZ'],4,352),(319,'5/2/915',['BZ','FL'],4,352),(320,'3R/352',['BR'],3,352),
(326,'2R/352',['BZ'],3,352),(324,'3P/352',['BZ','BR'],3,352),(325,'1R/352',['FL'],3,352),(321,'2/1/726',['BR'],3,716),(322,'1P/352',['FL','BR'],3,352),(323,'2P/352',['FL','BZ'],3,352)],
'M':[(327,'3/Fus/352',['BZ','BR'],3,352),(328,'1/Fus/352',['FL','BR'],3,352),(330,'4/1/915',['BR'],4,352),(329,'2/Fus/352',['FL'],3,352),(331,'2/1/915',['FL'],4,352),
(332,'3/Fus/352B',['BZ'],3,352),(333,'3/1/915',['FL','BZ'],4,352),(334,'1/1/915',['FL','BZ'],4,352)]}
G['rinforzi']={}
for k,l in rin.items():
    G['rinforzi'][k]=[]
    for t,n,w,f,dv in l:
        nm='r_'+n.replace('/','_'); save(t,nm); G['rinforzi'][k].append(dict(id=n,img=nm,armi=w,forza=f,div=dv))
save(317,'r_retro','b')
G['artiglieria']=[dict(id='1/1352 Est',cal='105',settore='E',oss=['WN60','WN61','WN62','A6'],img='art_1352'),dict(id='1/Flak Est',cal='88',settore='E',oss=['WN64','WN65','WN67'],img='art_flak'),
 dict(id='1/1352 Ovest',cal='105',settore='W',oss=['WN66','WN68','D4'],img='art_1352'),dict(id='1/Flak Ovest',cal='88',settore='W',oss=['WN70','WN71','WN72','G3'],img='art_flak')]
json.dump(G,open(f'{P}/data/tedeschi.json','w'),indent=0,ensure_ascii=False)
print({k:len(v) for k,v in G['dm'].items()})
