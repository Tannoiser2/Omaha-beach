import json
P='/home/claude/omaha-beach'
CM={'o':'arancio','r':'rosso','p':'viola','g':'verde','b':'blu','m':'marrone'}
FIRE="""1 od rd p D
2 od r* p C
3 od rd bt T
4 o rdt b C 3:75,88,105
5 o* r gd D
6 o r gd T 2:88,105
7 od r md* T
8 od rt m C
9 ot pd b D
10 ot pd b T
11 od p* g T
12 o pd gd* C
13 odt p m D
14 o bd gd T 1:88
15 od* bd g C
16 o b md D
17 o b md C
18 o g mdt T
19 o g* md D
20 r p bd* D
21 rd p b C
22 r pdt g D
23 rd pd m T 4:75,88,105
24 r pd gdt T
25 rd b gd C 4:75,88,105
26 rd pt md C
27 rd b* gd T
28 rt bd m* D
29 rd* bd m T
30 rd gd mt D
31 r gdt md C
32 pt b gdt D
33 p bd g C
34 p bd m D
35 p bdt md T
36 pdt g md T
37 pd* g m C 2:88,105
38 bdt gd m D
39 b gt md C
40 odt g m D 5:75,88,105
41 o rdt g D
42 o pd bt D 1:88
43 rd p bd D
44 rd g m D
45 ot r pd C 2:88
46 o pd md C 4:75,88,105
47 o bdt g C 3:75,88,105
48 o b mdt C 5:75,88,105
49 r pd mt C
50 p bd g T
51 o rdt m T
52 r pdt b T
53 bd gt md T
54 p gd mdt T"""
LAND="AAC* AAB CAA AAB BAA BAA ACA BAA ADA ABA DAB ABA* ABD BAD BDA ADB DAB DBA ABD BAD BDA ADB* DAB DBA ABD BAC* BCA ACB CAB CBA ABC BAC* BCA ACB CAB CBA ABC* BAC BCA ACB CAB CBA* ABC BAC BCA ACB CAB CBA ABC BAC BCA ACB* CAB* CBA".split()
# eventi: per ogni carta [(da,a,codice,parametri,testo)]
def R(*z): return ('RINF',list(z))
EV={1:[(2,10,R('E','G')),(11,20,R('C','D','E')),(21,31,('TOGLI_CONF',None))],
2:[(2,10,('CRISI',['A','C','G'])),(11,20,('PIOMBANTE',None)),(21,31,('NAVALE',None))],
3:[(2,10,('FUMO',['WN72','WN73'])),(11,20,R('B','D','E')),(21,31,('RINFORZA_US',1))],
4:[(2,10,('NAVALE',['E'])),(11,31,('RINFORZA_US',29))],
5:[(2,10,('RAZZI',None)),(11,20,('TOGLI_CONF',None)),(21,31,('RINFORZA_US',29))],
6:[(2,20,('NAVALE',['C'])),(21,31,('CECCHINI',None))],
7:[(2,20,('EROE',[1,1])),(21,31,('NAVALE_INATTESO',{'D':'WN62','T':'A4','C':'C1'}))],
8:[(2,20,('INIZIATIVA',None)),(21,31,('NAVALE_INATTESO',{'D':'WN66','T':'A6','C':'G5'}))],
9:[(2,10,('FUMO',['WN66','WN68'])),(11,20,R('A','D','E')),(21,31,('NASCOSTI',['C','D']))],
10:[(2,10,('FUMO',['WN62'])),(11,20,('TOGLI_CONF',None)),(21,31,R('A','G'))],
11:[(2,10,('FUMO',['WN64','WN65'])),(11,20,R('C','E','F')),(21,31,R('B','E'))],
12:[(2,10,('EROE',[29,1])),(11,20,('GENIO_BLOCCATO',None)),(21,31,('NASCOSTI',['C','T']))],
13:[(2,10,R('A','D')),(11,20,('PIANI',['A','C','D','E'])),(21,31,R('C','E'))],
14:[(2,10,('FUMO',['WN60','WN61'])),(11,31,('NAVALE',None))],
15:[(2,10,R('C','G')),(11,20,R('A','D','F')),(21,31,('CECCHINI',None))],
16:[(2,10,('FUMO',['WN70','WN71'])),(11,31,('INIZIATIVA',None))],
17:[(2,10,('INIZIATIVA',None)),(11,20,('PIOMBANTE',None)),(21,31,('NAVALE',None))],
18:[(2,20,('INIZIATIVA',None)),(21,31,('RINFORZA_US',1))],
19:[(2,10,R('C','G')),(11,20,R('B','D','G')),(21,31,R('C','G'))],
20:[(2,10,('DM_SETTORI',None)),(11,31,R('A','C','G'))],
21:[(2,20,('EROE',[1,1])),(21,31,('NAVALE',None))],
22:[(2,10,R('A','D')),(11,31,('RAZZI',None))],
23:[(2,20,('DM',None)),(21,31,('TOGLI_CONF',None))],
24:[(2,10,('DM_SETTORI',None)),(11,20,R('B','D','E')),(21,31,('NASCOSTI',['D','T']))],
25:[(2,20,('EROE',[1,1])),(21,31,R('B','D'))],
26:[(2,10,('DM',None)),(11,20,R('C','D','G')),(21,31,('RINFORZA_US',1))],
27:[(2,20,('DM',None)),(21,31,('TOGLI_CONF',None))],
28:[(2,20,('EROE',[29,1])),(21,31,R('C','D'))],
29:[(2,10,('DM',None)),(11,20,R('C','D','G')),(21,31,('NASCOSTI',['D','T']))],
30:[(2,10,('DM_SETTORI',None)),(11,31,('EROE',[29,0]))],
31:[(2,10,('EROE',[29,1])),(11,20,R('B','D','G')),(21,31,R('D','E'))],
32:[(2,10,('DM',None)),(11,31,('MEYER',None))],
33:[(2,10,('DM',None)),(11,31,('RAZZI_DISTRUTTI',None))],
34:[(2,10,('EROE',[1,0])),(11,20,R('A','C','E')),(21,31,('TOGLI_CONF',None))],
35:[(2,20,('EROE',[1,1])),(21,31,('NASCOSTI',['D','C']))],
36:[(2,10,('DM',None)),(11,20,('PATTUGLIA',29)),(21,31,('TOGLI_CONF',None))],
37:[(2,20,('DM',None)),(21,31,R('D','E'))],
38:[(2,10,('DM_SETTORI',None)),(11,20,R('A','C','E')),(21,31,('EROE',[1,0]))],
39:[(2,10,('FUOCO_INTENSO',None)),(11,20,('NAVALE',None)),(21,31,('DM_SETTORI',None))],
40:[(2,20,('DM',None)),(21,31,R('E','F'))],
41:[(2,20,('EROE',[29,1])),(21,31,('TOGLI_CONF',None))],
42:[(2,10,('EROE',[29,1])),(11,31,('DM_SETTORI',None))],
43:[(2,10,('DM',None)),(11,20,('TOGLI_CONF',None)),(21,31,R('A','F'))],
44:[(2,20,('DM',None)),(21,31,('NASCOSTI',['C','T']))],
45:[(2,10,('FUOCO_INTENSO',None)),(11,31,R('C','E','F'))],
46:[(2,10,R('A','G')),(11,31,('DM_SETTORI',None))],
47:[(2,10,R('D')),(11,31,('DM_SETTORI',None))],
48:[(2,10,('EROE',[1,1])),(11,31,('DM_SETTORI',None))],
49:[(2,20,('EROE',[29,1])),(21,31,('PATTUGLIA',1))],
50:[(2,20,('DM',None)),(21,31,('MEYER',None))],
51:[(2,10,R('A','D')),(11,20,R('A','E','G')),(21,31,('DM_SETTORI',None))],
52:[(2,20,R('E')),(21,31,('NAVALE_INATTESO',{'D':'WN72','T':'G3','C':'WN67'}))],
53:[(2,10,R('A','E')),(11,20,('PRIGIONIERO',1)),(21,31,R('D'))],
54:[(2,10,R('D','G')),(11,20,R('C','D','E')),(21,31,('PRIGIONIERO',29))]}
SIM={'D':'rombo','T':'triangolo','C':'cerchio'}
def testo(cod,par):
    if cod=='RINF': return 'Rinforzi tedeschi: uno in ciascuna zona '+', '.join(par)+' (9.3).' if len(par)>1 else 'Un rinforzo tedesco nella zona '+par[0]+' (9.3).'
    if cod=='CRISI': return 'I tedeschi segnalano una crisi. Rinforzi: uno in ciascuna zona '+', '.join(par)+' (9.3).'
    if cod=='PIANI': return 'I tedeschi catturano i piani US. Rinforzi: uno in ciascuna zona '+', '.join(par)+' (9.3).'
    if cod=='TOGLI_CONF': return 'Togli la confusione da tutte le posizioni tedesche.'
    if cod=='PIOMBANTE': return 'Tiro piombante tedesco: i punti di fuoco sporadico negli esagoni di spiaggia vicini a lati protettivi valgono come costanti.'
    if cod=='NAVALE': return 'Ricevi un segnalino Fuoco Navale (8.5)'+(' e piazza un rinforzo tedesco nella zona '+par[0]+' (9.3).' if par else '.')
    if cod=='FUMO': return 'Il fumo copre la spiaggia: in questo turno non sparano '+' e '.join(par)+'.'
    if cod=='RINFORZA_US': return 'Soldati dei reparti di supporto si uniscono alla fanteria: aggiungi un punto forza a una fanteria con 1 punto della %s Divisione.'%('1a' if par==1 else '29a')
    if cod=='RAZZI': return 'Screaming Meemies! I lanciarazzi di WN69 colpiscono un\'unità US.'
    if cod=='CECCHINI': return 'I cecchini colpiscono le staffette (solo modalità estesa).'
    if cod=='EROE': return 'Piazza un Eroe su un\'unità della %s Divisione'%('1a' if par[0]==1 else '29a')+(' e aggiungi un segnalino Incognita a un\'unità tedesca (9.2).' if par[1] else '.')
    if cod=='NAVALE_INATTESO': return 'Fuoco navale US inatteso colpisce una posizione: rombo %s, triangolo %s, cerchio %s.'%(par['D'],par['T'],par['C'])
    if cod=='INIZIATIVA': return 'Iniziativa dei soldati: in questo turno ogni Divisione ha un\'azione in più.'
    if cod=='NASCOSTI': return 'Tedeschi nascosti: vanno in confusione le unità US con simbolo %s e %s adiacenti a rinforzi tedeschi non rivelati.'%(SIM[par[0]],SIM[par[1]])
    if cod=='GENIO_BLOCCATO': return 'L\'artiglieria tedesca impedisce le operazioni del Genio in questo turno.'
    if cod=='DM': return 'Aggiungi un segnalino Incognita a un\'unità tedesca (9.2).'
    if cod=='DM_SETTORI': return 'Aggiungi un segnalino Incognita a un\'unità tedesca in ciascun settore (9.2).'
    if cod=='MEYER': return 'Le riserve tedesche arrivano a Omaha: quattro unità del Kampfgruppe Meyer passano nei rinforzi divisionali (9.5).'
    if cod=='RAZZI_DISTRUTTI': return 'Se i razzi di WN69 hanno già sparato, il fuoco navale US li distrugge.'
    if cod=='PATTUGLIA': return 'Rapporto di pattuglia US: rivela l\'unità tedesca più vicina a un\'unità della %s Divisione.'%('1a' if par==1 else '29a')
    if cod=='PRIGIONIERO': return 'Un prigioniero tedesco parla: rivela un\'unità tedesca a scelta nel settore della %s Divisione.'%('1a' if par==1 else '29a')
    if cod=='FUOCO_INTENSO': return 'Il fuoco tedesco intenso riduce le azioni a una per Divisione in questo turno.'
    return cod
cards=[]
for line,land in zip(FIRE.splitlines(),LAND):
    parts=line.split(); n=int(parts[0])
    sq=[]
    for s in parts[1:4]:
        sq.append(dict(col=CM[s[0]],doppio='d' in s,stella='*' in s,carri='t' in s))
    tgt=parts[4]; art=None
    if len(parts)>5:
        a,cs=parts[5].split(':'); art=dict(n=int(a),cal=cs.split(','))
    ev=[dict(da=a,a=b,cod=c[0],par=c[1],testo=testo(c[0],c[1])) for a,b,c in EV[n]]
    cards.append(dict(n=n,sbarco=dict(D=land[0],T=land[1],C=land[2]),mina=land.endswith('*'),fuoco=sq,bersaglio=tgt,art=art,eventi=ev))
json.dump(cards,open(f'{P}/data/carte.json','w'),indent=0,ensure_ascii=False)
print(len(cards), sum(c['mina'] for c in cards))
