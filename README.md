# D-Day at Omaha Beach - versione digitale

Versione digitale per uso personale di **D-Day at Omaha Beach** di John H. Butterfield (Decision Games, terza edizione):
il gioco in solitario sullo sbarco del 6 giugno 1944. I tedeschi sono interamente gestiti dal gioco, il giocatore comanda
la 1a e la 29a Divisione US.

Si gioca nel browser: https://tannoiser2.github.io/Omaha-beach/ (e nella ludoteca privata, se ci sono i segreti di Cloudflare).

## Scenari

- **Easy Fox** (introduttivo): solo il settore Est, la 1a Divisione e le sue unità fino al turno 10. Vittoria con 9 Punti Vittoria al turno 16.
- **La prima ondata** (The First Wave): turni 1-16 su tutta la spiaggia, regole 1-13. Vittoria con 19 Punti Vittoria.
- **D-Day at Omaha Beach**: la giornata intera, turni 1-32. Al turno 16 primo controllo (25 punti vittoria decisiva, 10 o meno
  sconfitta decisiva), poi la modalità estesa fino alle 18:00 (vittoria da 40 punti).
- **Oltre la spiaggia** (Beyond the Beach): turni 17-32 con la preparazione della regola 21 (vittoria da 45 punti).

Modalità estesa (regole 14-20): due eventi per turno, tre azioni per Divisione, fuoco tedesco con limite doppio, azioni
tedesche delle carte (rioccupazione, rifornimento, reimpiego, rinforzo, mortai, pattuglia, artiglieria delle WN, avanzata
lungo le frecce, imboscata), movimento di due esagoni di fanteria e leader, carri sulle strade, sbarramento
dell'artiglieria, Posti di Comando, Basi del Genio con gestione del traffico, bonifica di ciottoli, fossi, muri e strade
minate, guarnigioni, uscita dalla mappa e punti vittoria finali della regola 20.3.

Varianti opzionali (dal menu iniziale): bombardamento alleato efficace (22.1), carri della prima ondata al sicuro
(22.2), Ranger a Pointe du Hoc (22.3), reazione tedesca migliorata (22.4) e carri tedeschi (23) con ingresso dal
secondo evento, campo di fuoco mobile, azioni dalle carte, movimento lungo strade principali, secondarie e minate e
sconfitta decisiva se un carro raggiunge una fine strada sulla spiaggia. Le strade della mappa sono state ridigitalizzate
distinguendo principali, secondarie, sentieri e strade minate (tools/estrazione/strade_finali.py).

Approssimazioni: il carro tedesco senza bersagli US entro tre esagoni di strada segue il percorso stradale più breve
verso la fine strada più vicina invece della mappa degli ordini di movimento; il percorso delle avanzate tedesche usa i
diagrammi del regolamento.

## Tutorial e aiuto

- **Tutorial guidato** (dal menu): la prima parte gioca i turni di Easy Fox spiegando passo passo mappa, maree, sbarco,
  carte fuoco, azioni, riparo, dune, attacchi, sbarramenti, confusione, leader, fuoco navale, rinforzi e vittoria, con
  compiti da svolgere ed esagoni evidenziati; la seconda parte spiega la modalità estesa su «Oltre la spiaggia».
  I testi sono in `data/tutorial.json` (generati da `tools/estrazione/tutorial.py`).
- **Aiuto in linea** (pulsante «Aiuto» o tasto F1): il regolamento completo in 18 capitoli con le tabelle originali del
  gioco (`data/aiuto.json`, `assets/tabelle/`).

## Cosa fa il gioco da solo

- Controlli sullo sbarco per settore con la carta Sbarco (derive, ritardi, perdite, mine sommerse dal turno 7) e sbarco
  sull'esagono della marea attuale.
- Eventi delle carte per i turni 2-16 (rinforzi tedeschi per zona con le priorità 9.3, segnalini Incognita con le priorità 9.2,
  eroi, fumo, tiro piombante, fuoco navale, razzi di WN69, Kampfgruppe Meyer, iniziativa, ecc.).
- Fuoco tedesco per settore: colori, quadrati doppi, limite di colpi, priorità per intensità, distanza e punti forza,
  bersaglio concentrato, bonus contro i carri, colpi sui leader, un solo punto perso per fase; artiglieria dal turno 4
  (pezzi WN e artiglieria fuori mappa con i loro osservatori).
- Bonifica degli ostacoli del Genio (2 esagoni per settore con la bassa marea, 1 con la marea media), maree che salgono,
  limite di due unità per esagono, sconfitta catastrofica e Punti Vittoria finali.

## Cosa fa il giocatore

Le azioni US: movimento, scalate di dune e scogliere, riparo gratuito della fanteria, attacchi combinati (forza, armi,
aggiramento, eroe, radio degli HQ, fuoco navale, terreno), fuoco di sbarramento dei carri, fuoco navale separato,
rimozione di confusione e scalate. Il pulsante «Gioca il turno per me» usa un semplice giocatore automatico.

## Mappa e materiali

La mappa è quella del modulo Tabletop Simulator, digitalizzata con gli script di `tools/estrazione`: griglia ricavata
dai numeri degli esagoni, terreno, lati (dune, pendii, scogliere scalabili e a picco, ciottoli, argini, muri e fossi
anticarro), strade principali, secondarie e minate, linea di confine dei settori, le 18 WN e le 74 posizioni di rinforzo
con colori, punti VP e frecce di avanzata, circa 1000 punti di fuoco classificati (intenso, costante, sporadico) e
assegnati alla posizione più vicina dello stesso colore, riquadri di sbarco con gli esagoni di bassa, media e alta marea.
Le pedine sono quelle del modulo; le carte sono ridisegnate nel gioco con i testi degli eventi in italiano.

Font: Black Ops One (titoli), Oswald (interfaccia), Special Elite (registro), licenza OFL.

## Salvataggi

- Automatico sul dispositivo a ogni turno («Continua la partita salvata»).
- Online su Firebase (stesso progetto della ludoteca, radice `omahabeach/partite`): «Salva online» dà un codice di
  6 caratteri per riprendere la partita da qualsiasi dispositivo. Le regole del database sono in `firebase/`.

## Sviluppo

- Godot 4.7, rendering gl_compatibility, esportazione web.
- `scripts/mappa.gd` dati della mappa, `scripts/gioco.gd` sequenza del turno e automazione tedesca,
  `scripts/partita.gd` azioni US e vittoria, `scripts/main.gd` interfaccia, `scripts/net.gd` Firebase, `scripts/bot.gd`
  giocatore automatico.
- Prove: `godot --headless --path . --script res://tests/partite_auto.gd` (partite automatiche complete con salvataggio e
  ricarica), `xvfb-run godot --path . --script res://tests/screenshot.gd` (schermate), `python3 tools/controlla_glifi.py`
  (ogni carattere dei testi esiste nei font).

## Pubblicazione

Non parte a ogni modifica: si avvia a mano (Actions → Pubblica → Run workflow) oppure con un commit che nel messaggio
contiene `[pubblica]`. Pubblica su GitHub Pages e, se ci sono i segreti `CLOUDFLARE_API_TOKEN` e `CLOUDFLARE_ACCOUNT_ID`,
anche su https://omaha-beach.ludoteca-digitale.com/ (ludoteca privata).
