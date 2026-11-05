# Estrazione dei dati dal modulo TTS

Script usati per ricavare `data/*.json` e le immagini delle pedine dal modulo Tabletop Simulator
(«D-Day at Omaha Beach (2090500545).ttsmod», in Desktop/Ludoteca/Omaha beach). Si lanciano dopo aver
scompattato il modulo; i percorsi in testa ai file vanno adattati.

Ordine: `ocr.py` (griglia dai numeri degli esagoni, risultato in `grid.py`), `detect.py`, `dots2.py`, `dots3.py`
(punti di fuoco), `terrain.py` e `classify.py` (terreno), `sides2.py` (lati), `build_map.py` (mappa.json),
`gen_data.py` (unità US, mappa ridotta e pedine), `gen_de.py` (tedeschi), `gen_cards.py` (carte e eventi in italiano).
Dopo `build_map.py` sono state applicate a mano alcune correzioni (riquadro di sbarco senza nome X1, valli, esagoni
della legenda tolti, ostacoli solo sulle linee di marea): vedi la cronologia del repository.
