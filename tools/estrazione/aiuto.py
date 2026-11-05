import json
C=[]
def cap(titolo, testo, tabelle=None):
    C.append({"titolo": titolo, "testo": testo.strip(), "tabelle": tabelle or []})

cap("Il gioco in breve", """
[b]D-Day at Omaha Beach[/b] è un gioco in solitario di John H. Butterfield (Decision Games) sullo sbarco americano del 6 giugno 1944 sulla costa del Calvados. Tu comandi le forze US: la [b]1ª Divisione[/b] (verde scuro, settore Est, a sinistra sulla mappa) e la [b]29ª Divisione[/b] (verde chiaro, settore Ovest, a destra). I tedeschi sono interamente gestiti dal gioco con le carte: non c'è nessun dado.

[b]Scopo.[/b] Sbarcare, sopravvivere al fuoco delle difese costiere, salire le dune e le scogliere, conquistare le posizioni tedesche e le quattro valli (draw) che portano nell'entroterra.

[b]Scenari[/b]
- [b]Easy Fox[/b] (introduttivo): solo settore Est, 1ª Divisione, turni 1-16. Vinci con 9 Punti Vittoria. Durata circa un'ora.
- [b]La prima ondata[/b]: tutta la spiaggia, turni 1-16 (06:15-10:00). Vinci con 19 Punti Vittoria.
- [b]D-Day at Omaha Beach[/b]: la giornata intera, turni 1-32. Al turno 16 primo controllo: con 25 punti vittoria decisiva, con 10 o meno sconfitta decisiva, altrimenti si continua con la modalità estesa fino alle 18:00 (vittoria da 40 punti).
- [b]Oltre la spiaggia[/b]: turni 17-32, gli americani sono già a terra e devono spingersi nell'entroterra. Vittoria da 45 punti.

[b]Sconfitta catastrofica.[/b] Perdi subito se una Divisione ha otto compagnie di fanteria regolare (14 dal turno 17) ridotte a un solo punto forza o eliminate. Il contatore è nel pannello: «Perdite fanteria».
""")

cap("Comandi dell'interfaccia", """
[b]Mappa[/b]
- [b]Trascina[/b] con il mouse (o con il dito) per spostare la mappa; [b]rotellina[/b] o pizzico per lo zoom; i pulsanti + e - in basso a sinistra fanno lo stesso; «Spiaggia» riporta la vista sulla spiaggia.
- [b]Clic su un'unità[/b] per selezionarla. Più clic sullo stesso esagono passano all'unità successiva (anche i leader e le unità nei riquadri di sbarco).
- [b]Clic su un esagono colorato[/b] per muovere l'unità selezionata. [b]Clic destro[/b] annulla la scelta in corso.
- Passa il mouse su una [b]posizione tedesca[/b] per vederne il campo di fuoco: più il colore è pieno, più il fuoco è forte (intenso, costante, sporadico). La casella «Campi di fuoco» accende o spegne questa visualizzazione.
- In basso compare la descrizione dell'esagono sotto il mouse: numero, terreno, ostacoli, linee di marea, riparo, posizione tedesca.

[b]Colori dei movimenti[/b]
- [b]Verde[/b]: movimento normale (costa un'azione se l'unità non ha un'azione gratuita).
- [b]Azzurro[/b]: movimento di riparo della fanteria sulla spiaggia, sempre gratuito.
- [b]Arancio[/b]: scalata di una duna o di una scogliera.
- [b]Rosso[/b]: bersagli dell'azione scelta (attacco, sbarramento, fuoco navale, Base del Genio).

[b]Pannello a destra[/b]
- Turno, ora, marea, fase, azioni rimaste per Divisione, perdite di fanteria, Punti Vittoria che avresti adesso e riserve tedesche.
- [b]Fine fase azioni[/b]: chiude le tue azioni e il gioco risolve il turno seguente fino alla tua prossima fase delle azioni.
- [b]Gioca il turno per me[/b]: un semplice giocatore automatico fa le azioni al posto tuo (poi premi Fine fase azioni).
- [b]Fuoco navale[/b]: usa un segnalino di fuoco navale contro una posizione.
- [b]Muovi in coppia[/b]: se attivo, due unità nello stesso esagono che si muovono insieme spendono una sola azione.
- Le [b]carte del turno[/b] (fuoco Est e Ovest) e l'[b]evento[/b] pescato.
- La scheda dell'[b]unità selezionata[/b] con i pulsanti delle azioni possibili.
- Il [b]registro[/b] di tutto quello che è successo.
- [b]Salva online[/b] (con un codice da 6 caratteri), [b]Menu[/b], [b]Aiuto[/b].

La partita si salva da sola sul dispositivo a ogni turno: dal menu scegli «Continua la partita salvata».
""")

cap("La mappa", """
Ogni esagono è di circa 250 metri e ha il numero stampato (riga e colonna, per esempio 0812). Il nord è in basso: il mare è in basso, l'entroterra in alto.

[b]Terreni[/b]
- [b]Spiaggia[/b]: sabbia scoperta, con le linee di bassa, media e alta marea e gli ostacoli antisbarco.
- [b]Pianoro / valle (draw)[/b]: fondovalle che dalla spiaggia sale verso l'interno; le quattro valli sono E-3, E-1, D-3 e D-1.
- [b]Altura[/b]: il terreno alto oltre le dune.
- [b]Bocage[/b]: campi chiusi da siepi; raddoppia la difesa tedesca.
- [b]Bosco / frutteto[/b]: raddoppia la forza dell'unità tedesca (non del segnalino Incognita).
- [b]Edifici[/b]: raddoppiano unità e segnalino Incognita.
- [b]Terreno accidentato[/b]: impraticabile per tutti.

[b]Lati d'esagono[/b]
- [b]Duna (bluff)[/b], linea rossa tratteggiata: la fanteria la supera con una scalata; i leader passano; gli altri solo lungo una strada. Dal basso non si attacca attraverso una duna.
- [b]Pendio (slope)[/b], linea grigia tratteggiata: raddoppia unità e segnalino se tutti attaccano attraverso lo stesso lato; i mezzi passano solo su strada.
- [b]Scogliera scalabile[/b]: solo la fanteria, con una scalata di tre turni (uno dal turno 17). Attacco proibito attraverso.
- [b]Scogliera a picco[/b]: invalicabile.
- [b]Ciottoli (shingle)[/b] e [b]muro o fosso anticarro[/b]: la fanteria passa, i mezzi no (salvo Basi del Genio dal turno 17); raddoppiano l'unità tedesca ma non il segnalino.
- [b]Argine (seawall)[/b]: i mezzi passano solo su strada; le Basi del Genio non lo eliminano.

[b]Strade[/b]: principali, secondarie, sentieri. Lungo una strada i mezzi possono entrare in terreni altrimenti vietati; dal turno 17 i carri corrono sulle strade. Le [b]strade minate[/b] (arancio) sono vietate ai mezzi finché il Genio non le bonifica.

[b]Posizioni tedesche[/b]
- [b]Widerstandsnest (WN)[/b], croci colorate: le difese costiere, occupate fin dall'inizio. Alcune sono su due esagoni (N e S) e hanno un campo di fuoco unico. Il simbolo dell'artiglieria o «88» indica le WN con cannoni.
- [b]Posizioni di rinforzo[/b], esagoni con il bordo colorato: zona (lettera A-G) e priorità (numero). Qui arrivano i rinforzi. Alcune danno punti vittoria (VP) e hanno una freccia di avanzata.
- Ogni posizione ha uno dei sei colori (verde, arancio, rosso, viola, marrone, blu): le carte fuoco dicono quali colori sparano.

[b]Riquadri di sbarco[/b]: la fila azzurra in basso (FG, ER, EG, DR, DW, DG, CH). Ogni riquadro punta verso un esagono di spiaggia diverso a seconda della marea. [b]Uscite[/b]: le lettere A-G sui bordi della mappa, dove passano le strade verso l'interno.
""")

cap("La sequenza del turno", """
[b]Turni 1-16[/b] (15 minuti ciascuno, dalle 06:15 alle 10:00)
1. [b]Operazioni anfibie[/b]: per ogni settore con unità nei riquadri si pesca una carta Sbarco e si applicano i rischi dello sbarco; poi le unità sbarcano sulla spiaggia e quelle del turno entrano nei riquadri.
2. [b]Evento[/b] (non al turno 1): si pesca una carta e si applica l'evento del turno attuale.
3. [b]Fuoco tedesco[/b]: una carta Fuoco per il settore Est e una per l'Ovest; sparano le posizioni dei colori indicati. Dal turno 4 può sparare anche l'artiglieria. Le posizioni in confusione del colore pescato si riorganizzano.
4. [b]Genio[/b] (dal turno 2): bonifica degli ostacoli sulla spiaggia.
5. [b]Azioni US[/b]: tocca a te.
6. [b]Fine turno[/b]: limite di due unità per esagono, marea che sale, rimescolo del mazzo ai turni 6 e 13.

Le fasi 1-4 le risolve il gioco da solo e le racconta nel registro.

[b]Turni 17-32[/b] (30 minuti ciascuno, fino alle 18:00): anfibie, primo evento, fuoco e azioni tedesche, secondo evento, Genio e HQ, azioni US (tre per Divisione), fine turno. Vedi i capitoli sulla modalità estesa.

[b]Maree[/b]
- Bassa marea: turni 1-6 e 28-32.
- Marea media: turni 7-15 e 23-27 (gli esagoni della linea di bassa marea sono sott'acqua).
- Alta marea: turni 16-22 (sott'acqua anche la linea di marea media).
Le unità rimaste in un esagono che sta per finire sott'acqua annegano a fine turno 7 (linea bassa) e 15 (linea media), salvo quelle con il segnalino Scalata.
""")

cap("Sbarco", """
[b]Controllo dello sbarco.[/b] Per ogni settore con unità nei riquadri il gioco pesca una carta Sbarco. Ogni carta ha una lettera (A, B, C, D) per ciascuno dei tre simboli bersaglio (rombo, triangolo, cerchio). Per ogni unità si incrocia nella Tabella dello sbarco il tipo di unità e la lettera del suo simbolo: l'unità può [b]derivare[/b] di alcuni riquadri verso est o ovest, essere [b]ritardata[/b], [b]perdere punti forza[/b] o essere [b]eliminata[/b].

- Un'unità che deriva oltre l'ultimo riquadro è ritardata di due turni.
- Con l'alta marea, un'unità che deriva davanti a un riquadro senza spiaggia di alta marea è ritardata.
- La fanteria che sbarca dal turno 15 non fa il controllo.
- Gli HQ e i Generali non fanno il controllo.

[b]Mine sommerse[/b] (turni 7-22): se la carta mostra il simbolo della mina, una delle unità sbarcate su un esagono della linea di marea media non ancora bonificato perde un punto forza.

[b]Lo sbarco.[/b] Le unità rimaste nei riquadri vanno sull'esagono di spiaggia indicato dal riquadro per la marea attuale (bassa, media o alta). Un'unità che sbarca nel settore dell'altra Divisione passa al suo comando (pallino blu sulla pedina).

[b]Nuovi arrivi.[/b] Le unità del turno entrano nei riquadri indicati sulle pedine, al massimo due per riquadro (leader esclusi). I riquadri Charlie (CH) sono riservati ai Ranger.
""", ["sbarco"])

cap("Fuoco tedesco", """
[b]Le carte fuoco.[/b] Ogni carta mostra tre quadrati colorati e un simbolo bersaglio.
- [b]Quadrato singolo[/b]: sparano le posizioni di quel colore occupate da un'unità tedesca (non in confusione).
- [b]Quadrato doppio[/b]: sparano solo se la posizione ha anche il segnalino Incognita.
- [b]Stella[/b]: la posizione può colpire un leader (eroe, HQ, generale).
- [b]Carro[/b]: le unità corazzate US sono colpite come se non lo fossero.
- Alcune carte hanno la riga dell'[b]artiglieria[/b] (dal turno 4).
- Dal turno 17 le lettere F, R, M, P, A dicono quale azione fa la posizione.
La carta del settore Est fa sparare solo le posizioni del settore Est (anche se il loro campo sconfina a ovest), e viceversa.

[b]Campo di fuoco.[/b] I pallini colorati intorno a una posizione formano il suo campo di fuoco: [b]intenso[/b] (pieno), [b]costante[/b] (a quarti), [b]sporadico[/b] (anello).

[b]Effetti[/b] (vedi la Tabella fuoco tedesco)
- Fuoco intenso: qualsiasi unità perde un punto forza.
- Fuoco costante: le unità non corazzate con il simbolo della carta perdono un punto forza.
- Fuoco sporadico: le unità non corazzate con il simbolo della carta vanno in confusione.
- Se a sparare è un [b]rinforzo non rivelato[/b], chi perde un punto va anche in confusione.
- [b]Bersaglio concentrato[/b]: un esagono con cinque o più punti forza US conta come se tutte le unità avessero il simbolo della carta.

[b]Quante unità colpisce.[/b] Una posizione colpisce al massimo tante unità quanti sono i suoi segnalini (unità più segnalino Incognita); dal turno 17 il doppio. Priorità: prima il fuoco intenso, poi costante, poi sporadico; a parità la più vicina, poi quella con più punti forza. Nei turni 1-16 un'unità non perde più di un punto forza per fase.

[b]Leader.[/b] Con la stella, se resta un colpo, viene colpito un leader in un esagono a fuoco intenso o costante: l'eroe muore (l'unità diventa Ispirata), l'HQ esce e rientra fra due turni, il generale è ferito (la seconda volta ucciso).

[b]Artiglieria tedesca[/b] (dal turno 4). Si contano i pezzi non in confusione del calibro indicato sulla carta: WN di artiglieria del settore più l'artiglieria fuori mappa, attiva finché i suoi osservatori (le posizioni elencate nei riquadri German Artillery) non sono tutti sotto controllo US. Se bastano, perde un punto forza un'unità con il simbolo della carta, nell'ordine: fanteria in un riquadro di sbarco, non fanteria sulla spiaggia, fanteria in un riquadro, fanteria sulla spiaggia.

[b]Confusione tedesca.[/b] Una posizione in confusione non spara e non proietta il suo campo; si riorganizza quando il suo colore esce sulla carta del suo settore.
""", ["fuoco"])

cap("Le tue azioni", """
Ogni Divisione ha [b]2 azioni[/b] per turno (3 dal turno 17). Ogni unità può fare [b]una sola azione[/b] per turno, anche se gratuita.

[b]Azioni gratuite[/b] (non consumano le azioni della Divisione)
- Tutte le azioni dei [b]Ranger[/b].
- Le unità con un [b]Eroe[/b] o [b]Ispirate[/b].
- Le unità con un segnalino [b]Confusione[/b] o [b]Scalata[/b] (solo per toglierlo o continuare la scalata).
- [b]HQ e Generali[/b].
- Le unità [b]sotto comando[/b]: nello stesso esagono o adiacenti a un HQ o a un Generale all'inizio della fase. Se il leader si muove, smette di dare azioni gratuite per il resto della fase.
- Il [b]movimento di riparo[/b] della fanteria sulla spiaggia, verso un esagono di spiaggia più vicino a un riparo (ciottoli, argine, pendio, duna, scogliera scalabile): in azzurro sulla mappa.
- Dal turno 17: le unità nel raggio di un Posto di Comando, e i movimenti dalla spiaggia nel raggio di una Base del Genio.

[b]Due unità dello stesso esagono[/b] che fanno esattamente la stessa azione (stesso movimento o stesso attacco) pagano una sola azione: attiva «Muovi in coppia» per muoverle insieme.

[b]Le azioni possibili[/b]
- [b]Muovere di un esagono[/b] (due dal turno 17 per fanteria e leader).
- [b]Scalare una duna[/b] (fanteria): entri nell'esagono oltre la duna e ricevi il segnalino Scalata; il turno dopo lo togli gratis.
- [b]Scalare una scogliera[/b] (fanteria): primo turno metti il segnalino, secondo turno passi la scogliera, terzo turno lo togli.
- [b]Togliere la confusione[/b] (gratis, ma è l'unica azione dell'unità).
- [b]Attaccare[/b], [b]fuoco di sbarramento[/b] (carri; artiglieria dal turno 17), [b]fuoco navale[/b].

[b]Infiltrazione.[/b] Muovere da un esagono adiacente a una posizione attiva e nel suo campo verso un altro esagono adiacente e nel campo della stessa posizione è un'infiltrazione: si pesca una carta e, se ha il colore della posizione e il simbolo dell'unità, l'unità perde un punto forza. Un leader da solo non può infiltrarsi.

[b]Raggruppamento.[/b] A fine fase al massimo due unità per esagono (leader esclusi): le eccedenti sono eliminate. Il gioco ti avvisa prima di chiudere la fase.

[b]Movimento dei mezzi[/b] (carri, artiglieria, contraerea, anticarro): non attraversano dune, pendii, argini, ciottoli, fossi e muri se non lungo una strada, né entrano in boschi e bocage senza strada: per questo nei primi turni restano sulla spiaggia.
""")

cap("Attaccare", """
[b]Chi può attaccare[/b]
- Serve almeno una [b]fanteria adiacente[/b] all'esagono tedesco (da un lato che permetta l'attacco).
- Altra fanteria: adiacente. Fanteria pesante a piena forza (gittata 2): adiacente o a un esagono di distanza.
- Carri, anticarro, contraerea: a portata di tiro e adiacenti all'obiettivo, oppure adiacenti a una fanteria che attacca, oppure sotto comando, oppure con una fanteria attaccante sotto comando.
- Artiglieria: a portata ma non adiacente, comandata da un HQ che comanda anche una fanteria che attacca; se non corazzata, fuori dal campo di fuoco nemico.
- Ogni unità che partecipa usa la sua azione. Ogni posizione può essere attaccata una sola volta per fase.
- Dal basso (spiaggia, pianoro) non si spara a distanza su una posizione più alta, a meno che questa spari sulla spiaggia. Dal basso non si attacca attraverso una duna; attraverso una scogliera mai.

[b]Come si risolve[/b]
1. Si rivela l'unità tedesca (il segnalino Incognita resta nascosto).
2. Si somma la forza degli attaccanti e la si confronta con la difesa tedesca, raddoppiata dal terreno quando previsto.
3. Si controlla se gli attaccanti hanno [b]tutte le armi richieste[/b] dall'unità tedesca (e dal segnalino Incognita, se rivelato).
4. Si legge la [b]Tabella risultati attacco[/b]: parte alta se mancano armi, bassa se ci sono tutte; riga del rapporto di forze; colonna della composizione tedesca.
5. Se il risultato rivela il segnalino Incognita, se ne aggiungono forza e armi e si rilegge la tabella.

[b]Armi[/b]: BZ bazooka, BG tubi Bangalore, BR fucile Browning, DE cariche da demolizione, MO mortaio, RD radio, MG mitragliatrice, AR artiglieria, NA fuoco navale, FL aggiramento. La fanteria a piena forza ha tutte le armi della tabella; ridotta, solo quelle stampate sulla pedina. Una fanteria adiacente sotto comando di un HQ ha anche la radio.

[b]Aggiramento (FL).[/b] Attacca da almeno due esagoni adiacenti all'obiettivo ma non adiacenti tra loro (tre esagoni qualsiasi se lo chiedono sia l'unità sia il segnalino).

[b]Eroe.[/b] Un'unità con eroe che attacca da un esagono adiacente può sostituire un'arma mancante (non l'aggiramento) oppure aggiungere 1 alla forza.

[b]Fuoco navale nell'attacco.[/b] Se una fanteria che attacca ha la radio o è sotto comando di un HQ, puoi aggiungere un segnalino di fuoco navale: +9 alla forza e le armi AR, DE, NA.

[b]Risultati[/b]: unità tedesca sconfitta (eliminata, o ritirata nei rinforzi se della 352ª Divisione e in comunicazione), segnalino Incognita eliminato, unità tedesca in confusione, i tedeschi ricevono un segnalino Incognita, o gli attaccanti adiacenti vanno in confusione. Con il [b]logoramento[/b] puoi far perdere un punto a un tuo attaccante per eliminare il segnalino Incognita (la finestra d'attacco ha la casella per accettarlo). Dal turno 17 un attacco con tutte le armi e forza almeno doppia elimina unità e segnalino insieme.
""", ["attacco", "armi"])

cap("Sbarramenti e fuoco navale", """
[b]Fuoco di sbarramento dei carri.[/b] Un carro a portata ma non adiacente spara su una posizione tedesca se si trova nel suo campo di fuoco, oppure se una fanteria non in confusione è nel campo di fuoco come osservatore (in questo caso il carro o l'osservatore devono essere sotto comando). Si pesca una carta: l'effetto dipende dalla presenza del colore della posizione e del simbolo del carro, dalla forza del carro e dal segnalino Incognita (Tabella fuoco di sbarramento). Non si spara su un rinforzo non rivelato, e la stessa posizione non può essere sia attaccata sia colpita da sbarramento nello stesso turno.

[b]Artiglieria[/b] (dal turno 17): come i carri, ma serve il comando di un HQ o Posto di Comando, e l'osservatore deve essere dello stesso comando.

[b]Fuoco navale.[/b] Alcuni eventi danno segnalini di fuoco navale, che puoi usare quando vuoi (anche nei turni successivi):
- dentro un attacco (vedi «Attaccare»);
- da solo, gratis, contro una WN o un rinforzo rivelato, se una fanteria con radio (o sotto comando di un HQ) è nel suo campo di fuoco: la posizione va in confusione e perde il segnalino Incognita, ma l'unità non viene eliminata.
""", ["sbarramento"])

cap("Rinforzi e segnalini Incognita", """
[b]Segnalino Incognita (depth marker).[/b] Sta sotto un'unità tedesca e ne aumenta forza e armi richieste. Si rivela solo quando un attacco è abbastanza forte.

[b]Nuovi segnalini[/b] arrivano con gli eventi o dopo un attacco fallito. Vanno all'unità più vicina a un'unità US, preferendo le WN di un solo esagono, poi quelle doppie, poi i rinforzi, poi l'ID più basso. L'unità deve essere in comunicazione. Si pescano dal mucchio giusto: WN per le WN, edifici per i rinforzi negli edifici, mobili per gli altri.

[b]Rinforzi da evento.[/b] Si pesca un rinforzo tattico (senza segnalino) e lo si piazza nella zona indicata: prima una posizione adiacente a un'unità US, poi entro due esagoni, poi quella con la priorità più bassa. Esauriti i tattici, arrivano i divisionali con un segnalino. Solo posizioni con un numero di priorità, in comunicazione e libere. Un generale da solo in quella posizione viene catturato.

[b]Rinforzo tattico nascosto in una WN.[/b] Se il segnalino Incognita rivelato di una WN è un «rinforzo tattico», l'unità WN è sconfitta e arriva un rinforzo nella posizione libera più vicina.

[b]Kampfgruppe Meyer.[/b] Riserve che entrano nei rinforzi divisionali solo con l'evento apposito. Nel punteggio finale della modalità estesa ogni unità rimasta nel riquadro Meyer toglie un punto.

[b]Comunicazioni tedesche.[/b] Una posizione è in comunicazione se può tracciare un percorso fino a un'uscita A-G senza passare da esagoni occupati o controllati da unità US, da spiaggia, terreno accidentato o pianori a ridosso della spiaggia. Un'unità tedesca adiacente annulla il controllo delle unità US vicine; un rinforzo occupato può passare attraverso un esagono di bocage adiacente anche se controllato.

[b]Controllo US.[/b] Ogni unità controlla il suo esagono; fanteria con 2 o 3 punti e carri controllano anche gli adiacenti (ma dal basso non quelli in altura). Generali ed eroi non controllano.
""")

cap("Eroi, HQ e Generali", """
[b]Eroi.[/b] Arrivano con gli eventi su un'unità della Divisione indicata (il gioco sceglie la più utile). Danno un'azione gratuita a quell'unità e un bonus in attacco. Se l'unità sta per essere eliminata, l'eroe può sacrificarsi al suo posto: l'unità sopravvive e diventa Ispirata (azione gratuita, senza bonus d'attacco).

[b]HQ (quartier generale).[/b] Si muove gratis di un esagono (non attraverso le scogliere). Comanda le unità nel suo esagono e in quelli adiacenti: azioni gratuite, radio, coordinamento di carri e artiglieria. Se colpito dal fuoco esce dalla mappa e rientra fra due turni in un riquadro di sbarco.

[b]Generali[/b] (Cota per la 29ª, Wyman per la 1ª). Si muovono gratis dove vogliono, comandano come un HQ (ma non danno la radio e non coordinano l'artiglieria). Il primo colpo li ferisce, il secondo li uccide.

[b]Posti di Comando[/b] (dal turno 17). Un HQ fuori dai campi di fuoco potenziali tedeschi può diventare Posto di Comando: non si muove più (se lo muovi torna HQ), ma comanda entro un raggio che cresce da 1 a 4 esagoni nei turni seguenti, se resta fuori dal fuoco. Un Posto di Comando nel campo di una posizione occupata non comanda.
""")

cap("Il Genio", """
[b]Turni 1-15.[/b] Nella fase del Genio le squadre di demolizione bonificano gli ostacoli sulla spiaggia: due esagoni per settore con la bassa marea (turni 2-6), uno con la marea media (7-15), nessuno con l'alta marea. Solo esagoni fuori dal campo di fuoco delle posizioni attive dei colori pescati. Gli esagoni bonificati non fanno esplodere le mine. Dal turno 24 tutti gli ostacoli della marea media sono demoliti.

[b]Basi del Genio[/b] (dal turno 17). Due per Divisione, su esagoni di spiaggia del proprio settore fuori dal campo di fuoco potenziale tedesco: usa i pulsanti «Base del Genio 1ª» e «Base del Genio 29ª» e clicca un esagono rosso. Ogni turno una Divisione può piazzare una base [b]oppure[/b] far crescere il raggio di una (il gioco lo fa da solo quando possibile): da 0 fino a 5 esagoni. Il fuoco dell'artiglieria tedesca nel settore blocca il Genio per quel turno.

Nel raggio di una base (ma non nei campi delle posizioni occupate):
- ciottoli, fossi e muri anticarro e strade minate sono bonificati: i mezzi passano;
- [b]gestione del traffico[/b]: le unità che partono da spiaggia, pianoro o da un esagono di duna si muovono gratis, anche verso le alture;
- [b]guarnigioni[/b]: le posizioni tedesche vuote e fuori dal fuoco ricevono una guarnigione US (GUA): i tedeschi non possono più entrarci e valgono come controllate per i punti vittoria. Un'avanzata tedesca riuscita le rimuove.
""")

cap("Modalità estesa: azioni tedesche", """
Dal turno 17 la lettera nel quadrato colorato della carta fuoco dice cosa fanno le posizioni di quel colore. Si risolvono dalle posizioni con il numero più alto, e le avanzate per ultime.

- [b]F, stella, carro[/b]: fuoco, se ci sono unità US nel campo.
- [b]R[/b]
  - WN vuota in comunicazione e non occupata da US: [b]rioccupazione[/b] con un'unità WN eliminata (non di artiglieria).
  - Rinforzo occupato con US nel campo: [b]rifornimento[/b] (riceve un segnalino Incognita se non ce l'ha), poi spara.
  - Rinforzo occupato senza US nel campo: [b]reimpiego[/b] verso una posizione vuota del settore con US nel campo (le posizioni VP solo verso altre posizioni VP).
  - Rinforzo vuoto entro due esagoni da US e in comunicazione: [b]rinforzo[/b] con segnalino (se la posizione è VP, o se ci sono US nel suo fuoco intenso o costante).
  - WN occupata con US nel campo: fuoco.
- [b]M[/b]: con US nel campo fuoco; altrimenti [b]mortai[/b]: rinforzi entro 3 esagoni, WN sulla spiaggia e sui pianori vicini entro 5 o su pianori e alture entro 2. Perde un punto chi ha il simbolo della carta (uno, due se c'è il segnalino).
- [b]P[/b]: i rinforzi occupati fanno una [b]pattuglia[/b]: mandano in confusione tutte le unità US nel fuoco intenso e costante, oppure la più vicina entro 3 esagoni. Le WN sparano.
- [b]A[/b]
  - WN occupata senza US nel campo e con cannoni da 75 o 88: [b]artiglieria[/b] su un'unità con il simbolo della carta in tutta la mappa.
  - Rinforzo vuoto con US nel campo: [b]imboscata[/b] (un colpo nel fuoco intenso, oppure confusione negli altri).
  - Rinforzo occupato con freccia: [b]avanzata[/b] (vedi sotto).

[b]Avanzata.[/b] Se la posizione indicata dalla freccia è libera, l'unità tenta l'avanzata quando non ha US nel campo, oppure quando è rivelata, della 352ª e con segnalino, oppure nascosta con segnalino; negli altri casi spara. Il percorso è quello dei diagrammi del regolamento (gli esagoni fra partenza e arrivo, arrivo compreso). Le unità US sul percorso che non sono fanteria o carri, e quelle con il simbolo della carta, vanno in confusione. Se le altre sommano almeno 7 di forza (doppia in edifici e bocage, +1 per eroe) l'avanzata è respinta; altrimenti una perde un punto, le unità US nella destinazione si spostano e i tedeschi entrano.

Le posizioni vuote fanno azioni solo se in comunicazione; i rinforzi vuoti solo entro due esagoni da un'unità US. Il quadrato doppio conta solo per le posizioni occupate.
""", ["azioni_tedesche"])

cap("Modalità estesa: azioni US", """
- [b]Tre azioni[/b] per Divisione.
- [b]Fanteria, Ranger e leader[/b] si muovono fino a [b]due esagoni[/b]. La fanteria si ferma dopo un esagono se entra nel bocage senza strada o in un esagono con fuoco intenso o costante di una posizione occupata. Le dune si superano senza segnalino ma fermandosi; le scogliere in un solo turno (con il segnalino Scalata da togliere il turno dopo).
- [b]Carri sulle strade[/b]: partendo da una strada principale fino a 4 esagoni sulle principali; da una secondaria fino a 2 su secondarie e principali. Si fermano entrando nel fuoco intenso di una posizione occupata. Le strade minate solo se bonificate dal Genio.
- Artiglieria, contraerea e anticarro: sempre un esagono.
- [b]Sbarramento dell'artiglieria[/b] (vedi «Sbarramenti»).
- [b]Posti di Comando e Basi del Genio[/b] (vedi i capitoli relativi).
- [b]Uscita dalla mappa[/b]: fanteria regolare, Ranger e carri su un esagono di uscita A-G possono uscire (pulsante «Esci dalla mappa»): ogni punto forza vale un punto vittoria a fine partita.
- Nel fuoco tedesco il limite di colpi è doppio e un'unità può perdere più punti nella stessa fase (uno per posizione).
- La sconfitta catastrofica arriva a [b]14[/b] compagnie perse.
""")

cap("Punti vittoria", """
[b]Turni 1-16[/b] (fine della prima ondata e primo controllo del D-Day)
- 1 punto per ogni esagono di WN controllato (le WN doppie valgono 2 solo se controlli entrambi gli esagoni).
- 1 punto per ogni posizione di rinforzo controllata.
- 5 punti per ogni valle (draw) controllata: tutti i suoi esagoni oltre le barriere anticarro.
- Easy Fox: vittoria con 9. La prima ondata: vittoria con 19. D-Day: 25 o più vittoria decisiva subito, 10 o meno sconfitta decisiva, altrimenti si continua.

[b]Controllo per la vittoria.[/b] Un esagono conta se è occupato o controllato da un'unità US, è collegato alla spiaggia da una linea di comunicazione US (che non attraversa campi di fuoco tedeschi, terreno accidentato, dune o scogliere) e non è nel campo di fuoco di una posizione tedesca occupata, anche se in confusione. Le guarnigioni contano come controllo.

[b]Turno 32[/b] (D-Day e Oltre la spiaggia)
- +1 per ogni posizione di rinforzo VP controllata (42 sulla mappa).
- +4 per ogni valle aperta al traffico: tutti gli esagoni controllati e nel raggio di una Base del Genio.
- +1 per ogni unità non di fanteria e non leader sulle alture.
- +1 per ogni punto forza di carri e fanteria regolare uscito da un'uscita A-G, se a fine partita quell'uscita è collegata alla spiaggia; +1 per ogni punto dei Ranger usciti da F o G in ogni caso.
- -1 per ogni esagono di WN non controllato.
- -1 per ogni unità rimasta nel Kampfgruppe Meyer.

Livelli (D-Day): 60 vittoria decisiva, 50 operativa, 40 tattica (risultato storico), 30 sconfitta tattica, 20 sconfitta operativa, sotto 20 sconfitta decisiva. In Oltre la spiaggia tutte le soglie sono più alte di 5.

Il pannello mostra in ogni momento i punti che avresti adesso.
""")

cap("Eventi", """
Gli eventi principali (la carta indica l'evento in base al turno):
- [b]Rinforzi tedeschi[/b] nelle zone indicate; [b]crisi tedesca[/b] e [b]piani US catturati[/b] fanno lo stesso.
- [b]Segnalino Incognita[/b] a un'unità tedesca (o una per settore).
- [b]Eroe[/b] su un'unità della Divisione indicata, a volte insieme a un segnalino Incognita per i tedeschi.
- [b]Fuoco navale[/b]: ricevi un segnalino.
- [b]Fumo sulla spiaggia[/b]: le WN indicate non sparano per il turno.
- [b]Tiro piombante[/b]: per il fuoco del turno i punti sporadici sulla spiaggia vicino ai ripari valgono costanti.
- [b]Togli la confusione[/b] da tutte le posizioni tedesche.
- [b]Iniziativa dei soldati[/b]: un'azione in più per Divisione; [b]fuoco intenso[/b]: una sola azione per Divisione.
- [b]Screaming Meemies![/b]: i razzi di WN69 colpiscono un'unità su spiaggia o pianoro fra 3 e 7 esagoni (la più forte).
- [b]Rinforzi alla fanteria US[/b]: una compagnia con un solo punto torna a due e lascia il conteggio delle perdite.
- [b]Rapporto di pattuglia[/b] e [b]prigioniero[/b]: si rivela un'unità tedesca.
- [b]Kampfgruppe Meyer[/b]: quattro unità di riserva passano nei rinforzi divisionali.
- Dal turno 17: [b]tedeschi nascosti[/b] (confusione alle unità US adiacenti a rinforzi non rivelati), [b]fuoco navale inatteso[/b] su una posizione, [b]cecchini[/b] (raggio dei Posti di Comando ridotto a 1), [b]artiglieria che blocca il Genio[/b].

In Easy Fox si ignorano gli eventi della 29ª Divisione, di WN69, del fumo su WN66 e oltre, del Kampfgruppe Meyer e i rinforzi nelle zone E, F, G.
""")

cap("Tabelle", """
Le tabelle originali del gioco, per consultarle durante la partita. Il gioco le applica da solo: servono per capire i risultati che leggi nel registro.
""", ["sbarco", "fuoco", "attacco", "armi", "sbarramento", "azioni_tedesche"])

cap("Consigli di gioco", """
- Nei primi turni la priorità è [b]sopravvivere[/b]: porta la fanteria al riparo (movimenti azzurri, gratuiti) contro ciottoli, argini e dune.
- Non lasciare unità sulla linea di bassa marea alla fine del turno 7, né sulla linea media alla fine del turno 15.
- Le posizioni con il [b]quadrato doppio[/b] sparano solo con il segnalino Incognita: eliminare i segnalini indebolisce molto il fuoco.
- Attacca quando hai [b]tutte le armi[/b]: una fanteria a piena forza le ha quasi tutte; una ridotta ne ha poche. Combina più unità e cerca l'aggiramento.
- Tieni vicini [b]HQ e Generali[/b]: le unità sotto comando agiscono gratis.
- Conserva il [b]fuoco navale[/b] per l'attacco decisivo contro una WN dura.
- Non ammassare più di cinque punti forza in un esagono sotto il fuoco: diventa un bersaglio concentrato.
- Le valli valgono molto: conquistarle apre la strada ai mezzi e dal turno 17, con il Genio, danno 4 punti ciascuna.
- Dal turno 17 stabilisci presto Posti di Comando e Basi del Genio: fanno crescere il raggio turno dopo turno.
""")
json.dump(C,open('/home/claude/omaha-beach/data/aiuto.json','w'),ensure_ascii=False,indent=1)
print(len(C))
