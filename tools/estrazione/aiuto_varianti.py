# Aggiunge (o aggiorna) il capitolo dell'aiuto sulle varianti opzionali e sui carri tedeschi
import json
P='/home/claude/omaha-beach/data/aiuto.json'
C=json.load(open(P))
cap={"titolo":"Varianti opzionali e carri tedeschi","tabelle":[],"testo":
"""Nel menu iniziale, sotto gli scenari, puoi attivare le [b]varianti opzionali[/b] del regolamento (regole 22 e 23). Si scelgono prima di avviare lo scenario e restano nel salvataggio. Il punteggio finale tiene conto della modifica ai Punti Vittoria di ciascuna variante (riga [i]varianti[/i] nel riepilogo).

[b]Bombardamento alleato efficace (22.1, -10 PV)[/b]
La partita inizia dal turno 4. Prima del primo turno vengono pescate due carte Fuoco: le WN il cui colore compare su entrambe sono distrutte, quelle il cui colore compare su una sola carta perdono il segnalino Incognita e vanno in confusione. Gli arrivi US slittano di tre turni (di uno dal turno 16) e il 62 AFA arriva al turno 26.

[b]I carri della prima ondata sono al sicuro (22.2, -5 PV)[/b]
I carri anfibi delle prime ondate usano la tabella di sbarco con un livello di pericolo più favorevole.

[b]I Ranger rinforzano Pointe du Hoc (22.3, +5 PV)[/b]
Tutti i Ranger vengono tolti dal gioco tranne C/2R, che sbarca al turno 1.

[b]Reazione tedesca migliorata (22.4, +5 PV, solo D-Day e Oltre la spiaggia)[/b]
Il Kampfgruppe Meyer non resta in riserva: le sue unità si mescolano con i rinforzi divisionali e i suoi segnalini Incognita con quelli mobili. Anche i rinforzi tattici arrivano con un segnalino Incognita.

[b]Carri tedeschi (23, solo D-Day e Oltre la spiaggia, +1 PV per ogni carro entrato)[/b]
Dal turno 17 un carro tedesco entra al posto di un rinforzo divisionale quando: il riquadro dei rinforzi tattici è vuoto; il rinforzo è richiesto dal [i]secondo[/i] evento del turno; la posizione scelta ha una strada principale o secondaria collegata, senza passare per esagoni US, alle uscite B, C, D o E. Al massimo un carro per turno. Il carro arriva rivelato, con un segnalino Incognita corazzato.

Il carro è una posizione tedesca che si muove: ha un proprio colore, un campo di fuoco che lo segue (intenso negli esagoni vuoti o boscosi adiacenti, moderato tra edifici e bocage; a due esagoni solo accanto a un esagono intenso) e agisce quando il suo colore compare sulla carta Fuoco del settore:
- [b]stella o quadrato semplice[/b]: spara se ha unità US nel campo, altrimenti si muove di 4;
- [b]R[/b] annientamento: si muove di 4 attraversando fino a una unità US non corazzata, che va in confusione;
- [b]M[/b] si muove di 4, se non può spara;
- [b]A[/b] fuoco mirato se ha US adiacenti, altrimenti si muove di 4;
- [b]P[/b] si muove di 3 e poi spara se ha US adiacenti.
Si muove solo lungo strade principali, secondarie e minate: verso le unità US entro tre esagoni di strada, altrimenti verso la fine strada più vicina sulla spiaggia (contorni rossi in mappa: 0811, 0723, 0530). Su un'altura spara verso il basso solo se è adiacente al terreno basso.

[b]Attenzione:[/b] se a fine turno un carro non in confusione occupa una fine strada, è [b]sconfitta decisiva[/b]. Si attacca come una qualsiasi posizione tedesca (servono le armi anticarro indicate sul segnalino); sconfitto, il carro è eliminato. La fanteria adiacente a un carro e nel suo campo di fuoco può allontanarsi di un esagono gratuitamente (23.6).

[b]Strade e sentieri[/b]
In mappa ci sono strade principali, strade secondarie, sentieri tratteggiati e strade minate (arancio). Per attraversare bocage e scogliere i mezzi possono usare qualsiasi strada o sentiero; i movimenti lunghi dei carri US (17.2) e i carri tedeschi usano solo strade principali e secondarie (le minate solo nel raggio del Genio, per gli US)."""}
C=[c for c in C if c['titolo']!=cap['titolo']]
i=[c['titolo'] for c in C].index('Consigli di gioco')
C.insert(i,cap)
json.dump(C,open(P,'w'),ensure_ascii=False,indent=1)
print(len(C))
