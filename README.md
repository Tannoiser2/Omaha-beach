# D-Day at Omaha Beach - versione digitale

Versione digitale per uso personale di **D-Day at Omaha Beach** di John H. Butterfield (Decision Games, terza edizione):
il gioco in solitario sullo sbarco del 6 giugno 1944. I tedeschi sono interamente gestiti dal gioco, il giocatore comanda
la 1a e la 29a Divisione US.

Si gioca nel browser: https://tannoiser2.github.io/Omaha-beach/ (e nella ludoteca privata, se ci sono i segreti di Cloudflare).

## Scenari

- **Easy Fox** (introduttivo): solo il settore Est, la 1a Divisione e le sue unità fino al turno 10. Vittoria con 9 Punti Vittoria al turno 16.
- **La prima ondata** (The First Wave): turni 1-16 su tutta la spiaggia, regole 1-13. Vittoria con 19 Punti Vittoria.

La modalità estesa (turni 17-32, azioni tedesche, posti di comando e basi del Genio) non è ancora implementata.

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

La mappa è la mappa alternativa di Michael Evans del modulo Tabletop Simulator, digitalizzata con gli script del
lavoro preparatorio: griglia ricavata dai numeri degli esagoni, terreno, lati (dune, pendii, scogliere), le 18 WN e le
74 posizioni di rinforzo con i loro colori, circa 900 punti di fuoco classificati (intenso, costante, sporadico) e
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
