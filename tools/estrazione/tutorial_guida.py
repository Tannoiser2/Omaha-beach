# Dopo tutorial.py: collega gli esercizi alla guida dinamica (scripts/guida.gd), che sceglie
# l'unità e gli esagoni giusti nella partita in corso e prepara la situazione se serve.
import json
P='/home/claude/omaha-beach/data/tutorial.json'
t=json.load(open(P))
mp={('parte1',7):'riparo',('parte1',8):'muovi',('parte1',11):'duna',('parte1',12):'attacco',('parte1',13):'sbarramento',
    ('parte2',2):'due_esagoni',('parte2',3):'cp',('parte2',4):'base'}
for (pt,i),k in mp.items():
    t[pt]['passi'][i]['guida']=k
    t[pt]['passi'][i].pop('evid',None)
P1=t['parte1']['passi']; P2=t['parte2']['passi']
def rep(st,a,b):
    st['testo']=st['testo'].replace(a,b)
rep(P1[11],"Gli esagoni evidenziati sono quelli della spiaggia da cui si sale una duna. Se puoi, fai salire una fanteria.","Ora fai salire una fanteria: il compito qui sotto indica quale e dove.")
rep(P1[11],"Gli esagoni evidenziati sono quelli della spiaggia da cui si sale una duna. Ora fai","Ora fai")
rep(P1[12],"Prova un attacco appena una fanteria è adiacente a una WN.","Il compito qui sotto indica una fanteria già accanto a una posizione tedesca: attaccala.")
rep(P2[3],"Seleziona un HQ e trasformalo in Posto di Comando, se possibile.","Seleziona l'HQ indicato e trasformalo in Posto di Comando.")
P1[11]['compito']['testo']="Fai scalare una duna a una fanteria."
P1[12]['compito']['testo']="Attacca una posizione tedesca."
P1[13]['compito']['testo']="Fai un fuoco di sbarramento con un carro."
P2[3]['compito']['testo']="Stabilisci un Posto di Comando."
json.dump(t,open(P,'w'),ensure_ascii=False,indent=1)
