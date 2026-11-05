import json
P1=[]; P2=[]
def s(lista,titolo,testo,compito=None,evid=None,camera=None,zoom=None,azione=None):
    d={"titolo":titolo,"testo":testo.strip()}
    if compito: d["compito"]=compito
    if evid: d["evid"]=evid
    if camera: d["camera"]=camera
    if zoom: d["zoom"]=zoom
    if azione: d["azione"]=azione
    lista.append(d)

s(P1,"Benvenuto a Omaha Beach","""
È il 6 giugno 1944, ore 06:15. Guiderai la [b]1ª Divisione US[/b] nello scenario introduttivo [b]Easy Fox[/b]: il settore Est della spiaggia, sedici turni da un quarto d'ora.

Questo tutorial ti accompagna turno per turno: ogni passo spiega una regola e spesso ti chiede di fare qualcosa (il [b]compito[/b] in arancio, che diventa verde quando lo hai fatto). Puoi sempre andare avanti con «Avanti» o tornare indietro.

Lo scopo: arrivare al turno 16 con almeno [b]9 Punti Vittoria[/b] senza perdere otto compagnie di fanteria.
""",camera="0712",zoom=0.55)
s(P1,"Muoversi sulla mappa","""
Trascina la mappa con il mouse (o il dito) per spostarti, usa la rotellina (o il pizzico) per lo zoom. I pulsanti + e - e «Spiaggia» sono in basso a sinistra.

Nota che il nord è in basso: il mare è in basso, l'entroterra in alto. Il pannello a destra mostra turno, ora, marea, azioni e il registro di tutto quello che succede.
""",compito={"tipo":"zoom","testo":"Prova a usare lo zoom o a spostare la mappa."})
s(P1,"La spiaggia e le maree","""
La spiaggia (sabbia chiara) ha tre linee tratteggiate: [b]bassa marea[/b] (verso il mare), [b]marea media[/b] e [b]alta marea[/b]. Ora c'è la bassa marea (turni 1-6): dal turno 7 la linea di bassa marea finisce sott'acqua, dal turno 16 anche quella media. Chi resta sulla linea sbagliata a fine turno 7 o 15 annega.

Gli esagoni con le croci grigie hanno gli [b]ostacoli antisbarco[/b] (e le mine): il Genio li bonifica turno dopo turno.

Gli esagoni evidenziati sono quelli di marea media: ricordali per il turno 7.
""",evid="media",camera="0612",zoom=0.7)
s(P1,"I riquadri di sbarco","""
La fila azzurra di riquadri sul mare (FG = Fox Green, ER = Easy Red) contiene le unità che stanno per sbarcare. Ogni riquadro «punta» verso un esagono di spiaggia, diverso secondo la marea.

Ogni turno: si pesca una [b]carta Sbarco[/b] per settore, le unità nei riquadri rischiano derive, ritardi e perdite (Tabella dello sbarco), poi sbarcano; infine le unità del turno successivo entrano nei riquadri. Il gioco fa tutto da solo e lo scrive nel registro.

Clicca un riquadro con dentro delle pedine per vedere chi c'è.
""",evid="box",camera="0410",zoom=0.6,compito={"tipo":"sel_box","testo":"Seleziona un'unità in un riquadro di sbarco."})
s(P1,"Le difese tedesche","""
Le croci colorate sono le [b]Widerstandsnest (WN)[/b], i capisaldi costieri: le pedine coperte sopra sono le unità tedesche, e quella sotto (se c'è) il [b]segnalino Incognita[/b], che aumenta forza e armi necessarie per batterle.

Gli esagoni con il bordo colorato e la lettera (A1, C3...) sono le [b]posizioni di rinforzo[/b]: per ora vuote, si riempiranno con gli eventi.

Passa il mouse su una WN (per esempio WN61, evidenziata): vedrai il suo [b]campo di fuoco[/b]. Colore pieno = fuoco intenso, medio = costante, leggero = sporadico.
""",evid="pos:WN61",camera="0809",zoom=0.8,compito={"tipo":"hover","testo":"Passa il mouse sopra una posizione tedesca."})
s(P1,"Le carte fuoco","""
Nella fase di fuoco il gioco pesca una carta per settore (la vedi nel pannello). I [b]tre quadrati colorati[/b] dicono quali posizioni sparano:
- quadrato singolo: sparano se occupate;
- quadrato doppio: sparano solo se hanno anche il segnalino Incognita;
- stella: possono colpire un leader; carro: colpiscono bene i carri.

Il [b]simbolo[/b] (rombo, triangolo, cerchio) decide chi viene colpito dal fuoco costante e sporadico: ogni pedina US ne ha uno stampato. Il fuoco intenso colpisce chiunque.

Leggi nel registro cosa è successo al turno 1: chi è sbarcato, chi è stato colpito.
""")
s(P1,"Le tue unità","""
Clicca una tua unità sulla spiaggia. Nella scheda trovi:
- [b]punti forza[/b] (da 1 a 4): la fanteria regolare ne ha 3; ogni colpo ne toglie uno;
- [b]attacco[/b], [b]gittata[/b] e [b]simbolo bersaglio[/b];
- le [b]armi[/b]: la fanteria a piena forza ha tutte quelle della tabella (bazooka, Bangalore, Browning, demolizioni, mortaio, radio), ridotta solo quelle stampate sulla pedina.

I carri (che arrivano nei riquadri dall'inizio) hanno gittata 5: possono sparare da lontano.
""",compito={"tipo":"sel_mappa","testo":"Seleziona una tua unità sulla spiaggia."},evid="us")
s(P1,"Le azioni","""
Ogni Divisione ha [b]2 azioni[/b] per turno; ogni unità ne fa al massimo una. Alcune azioni sono [b]gratuite[/b]: tutto ciò che fanno i Ranger, le unità con un Eroe, i leader, le unità vicine a un HQ o a un Generale, e il [b]riparo[/b] della fanteria.

Selezionata un'unità, gli esagoni colorati mostrano dove può andare:
- [b]verde[/b] movimento (costa un'azione);
- [b]azzurro[/b] riparo gratuito: la fanteria sulla spiaggia si avvicina a ciottoli, argini e dune, dove il fuoco è meno micidiale;
- [b]arancio[/b] scalata.

Porta una fanteria al riparo (esagono azzurro).
""",compito={"tipo":"log","cerca":"si mette al riparo","testo":"Fai un movimento di riparo con una fanteria."})
s(P1,"Muovere spendendo un'azione","""
Ora sposta un'altra unità su un esagono verde: guarda il contatore «Azioni» nel pannello scendere. Due unità nello stesso esagono possono muoversi insieme spendendo una sola azione: attiva «Muovi in coppia».

Attento all'[b]infiltrazione[/b]: muovere fra due esagoni adiacenti alla stessa posizione e nel suo campo di fuoco fa pescare una carta, e puoi perdere un punto forza.
""",compito={"tipo":"log","cerca":"si sposta","testo":"Muovi un'unità su un esagono verde."})
s(P1,"Fine della fase","""
Quando hai finito premi [b]Fine fase azioni[/b]. A fine fase:
- in ogni esagono restano al massimo [b]due unità[/b] (i leader non contano): le altre sono eliminate, e il gioco ti avvisa prima;
- il gioco risolve il turno successivo: sbarchi, evento, fuoco tedesco, Genio, fino alla tua nuova fase delle azioni.
""",compito={"tipo":"turno","valore":2,"testo":"Premi «Fine fase azioni»."})
s(P1,"Il turno 2","""
Leggi il registro: dal turno 2 c'è anche la [b]carta evento[/b] (la trovi sotto le carte fuoco). Gli eventi portano rinforzi tedeschi, segnalini Incognita, eroi, fuoco navale, fumo...

Il [b]Genio[/b] ha bonificato alcuni ostacoli (il segnalino sugli esagoni): due per turno con la bassa marea, uno con la media, solo dove non arriva il fuoco delle posizioni dei colori pescati.
""")
s(P1,"Le dune","""
La linea rossa tratteggiata è una [b]duna[/b] (bluff). La fanteria la supera con una [b]scalata[/b] (esagono arancio): entra oltre la duna e riceve il segnalino Scalata; al turno dopo lo toglie gratis (pulsante «Completa la scalata»). Dalla spiaggia non si attacca attraverso una duna: bisogna salire.

Gli esagoni evidenziati sono quelli della spiaggia da cui si sale una duna. Se puoi, fai salire una fanteria.
""",evid="dune",compito={"tipo":"log","cerca":"scala la duna","testo":"Fai scalare una duna a una fanteria (se possibile)."})
s(P1,"Attaccare una posizione","""
Per attaccare serve una [b]fanteria adiacente[/b] alla posizione. Seleziona la fanteria e premi [b]Attacca[/b]: le posizioni attaccabili diventano rosse; cliccane una e scegli chi partecipa (carri e contraerea possono unirsi da lontano se adiacenti alla fanteria o sotto comando).

La finestra mostra forza e armi. Il risultato dipende da:
- rapporto di forze (difesa raddoppiata da ciottoli, pendii, edifici, bocage);
- [b]armi richieste[/b]: sono stampate sull'unità tedesca e sul segnalino Incognita;
- se il segnalino Incognita è nascosto o rivelato.

Vedi la Tabella risultati attacco nell'aiuto. Prova un attacco appena una fanteria è adiacente a una WN.
""",compito={"tipo":"log","cerca":"Attacco contro","testo":"Attacca una posizione tedesca (quando puoi)."})
s(P1,"Il fuoco di sbarramento","""
I [b]carri[/b] possono sparare da lontano (non adiacenti) su una posizione, se sono nel suo campo di fuoco oppure se una fanteria non in confusione nel campo fa da osservatore. Seleziona un carro e premi [b]Fuoco di sbarramento[/b].

Si pesca una carta: se ha il colore della posizione o il simbolo del carro, la posizione può andare in [b]confusione[/b] (smette di sparare finché il suo colore non esce di nuovo). Una posizione colpita da sbarramento non può essere attaccata nello stesso turno, e viceversa.
""",compito={"tipo":"log","cerca":"spara su","testo":"Fai un fuoco di sbarramento con un carro (se possibile)."})
s(P1,"La confusione","""
Il fuoco sporadico, gli attacchi falliti e alcuni eventi mettono le tue unità in [b]confusione[/b] (segnalino rosso sulla pedina): non possono fare nient'altro che togliersi la confusione, gratis (pulsante «Togli confusione»). Conviene farlo dopo aver mosso le altre unità.

Nello stesso modo le posizioni tedesche in confusione non sparano.
""")
s(P1,"Eroi, HQ e Generali","""
Gli [b]eroi[/b] arrivano con gli eventi: danno all'unità un'azione gratuita e in attacco sostituiscono un'arma mancante o aggiungono 1. Se l'unità sta per morire, l'eroe si sacrifica e l'unità diventa Ispirata.

L'[b]HQ del 16° Reggimento[/b] (turno 7) e il [b]Generale Wyman[/b] (turno 10) comandano le unità nel loro esagono e in quelli adiacenti: azioni gratuite, radio, carri che sparano da lontano. Tienili vicino alla fanteria che deve attaccare. Se muovi il leader, smette di comandare per quel turno.
""")
s(P1,"Fuoco navale","""
Alcuni eventi ti danno un [b]segnalino di fuoco navale[/b] (il contatore è sul pulsante «Fuoco navale»). Puoi usarlo:
- dentro un attacco: +9 alla forza e le armi artiglieria, demolizioni, fuoco navale, se una fanteria che attacca ha la radio;
- da solo, gratis: la posizione va in confusione e perde il segnalino Incognita, se una tua fanteria con radio è nel suo campo di fuoco.
""")
s(P1,"Rinforzi e segnalini Incognita","""
Con gli eventi i tedeschi ricevono [b]rinforzi[/b] nelle posizioni delle zone indicate, scelti vicino alle tue unità, e [b]segnalini Incognita[/b] per l'unità più vicina a te. Serve sempre una linea di comunicazione verso un'uscita della mappa: se circondi una posizione, non riceve più niente.

I rinforzi della 352ª Divisione sconfitti si ritirano e possono tornare; quelli della 716ª e le WN sono eliminati.
""")
s(P1,"La marea che sale","""
Al turno 7 arriva la [b]marea media[/b]: a fine turno 7 le unità sulla linea di bassa marea annegano. Dal turno 7 le mine esplodono se sbarchi su un esagono di marea media non bonificato.

Prima di chiudere il turno 6, controlla che nessuna unità sia sulla linea di bassa marea. Il gioco la evidenzia.
""",evid="bassa")
s(P1,"Vittoria","""
Al turno 16 il gioco conta i [b]Punti Vittoria[/b]:
- 1 per ogni esagono di WN controllato,
- 1 per ogni posizione di rinforzo controllata,
- 5 per ogni valle (draw) controllata, evidenziate sulla mappa.

Un esagono è controllato se c'è o è adiacente a una tua unità, è collegato alla spiaggia senza attraversare campi di fuoco o dune, e non è nel campo di una posizione occupata. Nel pannello vedi in ogni momento i punti che avresti adesso.
""",evid="valli")
s(P1,"Ora tocca a te","""
Hai visto tutte le regole dei turni 1-16. Continua la partita: se vuoi un'idea, il pulsante [b]Gioca il turno per me[/b] fa le azioni al posto tuo.

In ogni momento puoi aprire l'[b]Aiuto[/b] (pulsante nel pannello o tasto F1) con il regolamento completo e le tabelle originali. La seconda parte del tutorial (dal menu) spiega la modalità estesa, dal turno 17.
""",compito={"tipo":"aiuto","testo":"Apri l'Aiuto per vedere com'è fatto."})

s(P2,"La modalità estesa","""
Siamo alle 10:15 del 6 giugno: lo scenario [b]Oltre la spiaggia[/b] parte dal turno 17. Gli americani sono a terra e devono spingersi nell'entroterra fino alle 18:00.

Dal turno 17 cambiano molte cose: turni di mezz'ora, [b]due eventi[/b] per turno, [b]tre azioni[/b] per Divisione, i tedeschi compiono [b]azioni[/b] oltre a sparare, e arrivano Posti di Comando e Basi del Genio.
""",camera="0920",zoom=0.55)
s(P2,"Le azioni tedesche","""
Guarda le carte fuoco nel pannello: nei quadrati ora ci sono delle [b]lettere[/b].
- [b]F[/b] (o stella, o carro): fuoco.
- [b]R[/b]: le WN vuote vengono rioccupate, i rinforzi si riforniscono o si spostano verso di te, le posizioni vuote vicine ricevono rinforzi.
- [b]M[/b]: mortai contro le unità fuori dal campo di fuoco.
- [b]P[/b]: pattuglie che mettono in confusione.
- [b]A[/b]: avanzate lungo le frecce, imboscate dalle posizioni vuote, artiglieria delle WN.

Leggi nel registro cosa hanno fatto al turno 17. Il fuoco tedesco ora colpisce il doppio delle unità.
""")
s(P2,"Muoversi di due esagoni","""
Fanteria, Ranger e leader ora si muovono fino a [b]due esagoni[/b]. La fanteria si ferma dopo un esagono se entra nel bocage senza strada o sotto fuoco intenso o costante. Le dune si superano senza segnalino.

Seleziona una fanteria e muovila di due esagoni.
""",compito={"tipo":"log","cerca":"si sposta","testo":"Muovi una fanteria."})
s(P2,"Posti di Comando","""
Un [b]HQ[/b] fuori dal campo di fuoco potenziale dei tedeschi può diventare [b]Posto di Comando[/b] (pulsante sulla scheda dell'HQ, marchio CP). Non si muove più, ma il suo raggio di comando cresce turno dopo turno fino a 4 esagoni: tutte le unità nel raggio agiscono gratis, hanno la radio e coordinano carri e artiglieria.

Seleziona un HQ e trasformalo in Posto di Comando, se possibile.
""",compito={"tipo":"log","cerca":"Posto di Comando (raggio","testo":"Stabilisci un Posto di Comando."})
s(P2,"Basi del Genio","""
Premi [b]Base del Genio 1ª[/b] o [b]29ª[/b] e clicca un esagono di spiaggia rosso. La base ha raggio 0 e cresce di un esagono quasi ogni turno (fino a 5), a meno che l'artiglieria tedesca colpisca il settore.

Nel suo raggio (area gialla):
- ciottoli, fossi e muri anticarro e strade minate non fermano più i mezzi;
- le unità che partono da spiaggia, pianoro o duna si muovono [b]gratis[/b];
- le posizioni tedesche vuote ricevono una [b]guarnigione[/b] (GUA) che le tiene per i tuoi punti vittoria.
""",compito={"tipo":"log","cerca":"stabilisce una base","testo":"Piazza una Base del Genio."})
s(P2,"Carri e artiglieria","""
I [b]carri[/b] ora corrono sulle strade: 4 esagoni partendo da una strada principale, 2 da una secondaria; si fermano entrando sotto fuoco intenso. L'[b]artiglieria[/b] può fare fuoco di sbarramento, a distanza, se è sotto il comando di un HQ o Posto di Comando e una fanteria dello stesso comando fa da osservatore.

Fuori dalle strade i mezzi restano bloccati da pendii, dune e argini: per questo servono le Basi del Genio e le valli.
""")
s(P2,"Uscire dalla mappa","""
Le lettere A-G sui bordi sono le [b]uscite[/b] (evidenziate). Fanteria regolare, Ranger e carri su un esagono di uscita possono uscire (pulsante «Esci dalla mappa»): ogni punto forza vale un punto vittoria, se a fine partita l'uscita è collegata alla spiaggia (i Ranger usciti da F e G valgono sempre).
""",evid="uscite")
s(P2,"Vittoria alle 18:00","""
Al turno 32 contano:
- +1 per ogni posizione di rinforzo [b]VP[/b] controllata;
- +4 per ogni valle aperta (controllata e nel raggio di una Base del Genio);
- +1 per ogni mezzo sulle alture;
- +1 per ogni punto forza uscito dalla mappa;
- -1 per ogni esagono di WN non controllato e per ogni unità del Kampfgruppe Meyer mai arrivata.

In questo scenario vinci con 45 punti (40 nello scenario D-Day completo). La sconfitta catastrofica arriva a 14 compagnie perse. Buona fortuna!
""")
json.dump({"parte1":{"scenario":"easy_fox","seme":1944,"passi":P1},"parte2":{"scenario":"oltre","seme":1944,"passi":P2}},open('/home/claude/omaha-beach/data/tutorial.json','w'),ensure_ascii=False,indent=1)
print(len(P1),len(P2))
