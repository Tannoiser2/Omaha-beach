## Dati della mappa di Omaha Beach: esagoni, lati, posizioni tedesche, campi di fuoco,
## riquadri di sbarco. Tutto è letto da data/mappa.json (ricavato dalla mappa del modulo TTS).
## Gli esagoni hanno la numerazione originale "RRCC" (riga, colonna) stampata sulla mappa.
class_name Mappa
extends RefCounted

var esagoni: Dictionary = {}      # "0513" -> {t, s, ost, cio, ed, uscita}
var lati: Dictionary = {}         # "0513|0613" -> "B" duna, "L" pendio, "C" scogliera scalabile, "X" a picco, "W" muro o fosso anticarro, "A" argine, "G" ciottoli
var strade: Dictionary = {}       # "0830|0831" -> "P" principale, "S" secondaria o sentiero, "M" strada minata
var minati: Dictionary = {}       # esagoni con una strada minata
var posizioni: Dictionary = {}    # id -> {id, tipo, col, hex[], zona, prio, ed, art, gruppo}
var fuoco: Dictionary = {}        # id posizione (o gruppo WN) -> {hex: livello 3 intenso, 2 costante, 1 sporadico}
var box: Dictionary = {}          # "ER1" -> {box, div, s, bassa, media, alta}
var ordine_box: Array = []
var uscite: Dictionary = {}
var draws: Dictionary = {}
var griglia: Dictionary = {}
var hex_pos: Dictionary = {}      # hex -> id posizione
var bassa_set: Dictionary = {}
var media_set: Dictionary = {}
var alta_set: Dictionary = {}
var protezione: Dictionary = {}   # esagoni di spiaggia che offrono riparo

const BASSO := ["spiaggia", "pianoro"]

func carica(percorso := "res://data/mappa.json") -> void:
	var f := FileAccess.open(percorso, FileAccess.READ)
	var d: Dictionary = JSON.parse_string(f.get_as_text())
	esagoni = d["hexes"]
	lati = d["sides"]
	strade = d.get("strade", {})
	for k in strade:
		if strade[k] == "M":
			for h in k.split("|"): minati[h] = true
	posizioni = d["pos"]
	fuoco = d["fire"]
	box = d["boxes"]
	ordine_box = d["ordine_box"]
	uscite = d["exits"]
	draws = d["draws"]
	griglia = d["grid"]
	for id in posizioni:
		for h in posizioni[id]["hex"]:
			hex_pos[h] = id
	for b in box.values():
		if b.has("bassa"): bassa_set[b["bassa"]] = true
		if b.has("media"): media_set[b["media"]] = true
		if b.has("alta"): alta_set[b["alta"]] = true
	for h in esagoni:
		if esagoni[h]["t"] != "spiaggia":
			continue
		var ok := false
		for v in vicini(h):
			var l := lato(h, v)
			if l in ["B", "L", "C", "W", "A", "G"] or esagoni[v]["t"] in ["pianoro", "altura", "bocage", "bosco", "accidentato"]:
				ok = true
		if ok:
			protezione[h] = true

static func rc(h: String) -> Vector2i:
	return Vector2i(int(h.substr(0, 2)), int(h.substr(2, 2)))

static func hk(r: int, c: int) -> String:
	return "%02d%02d" % [r, c]

## Righe pari: vicini in alto/basso a (c, c+1); righe dispari: (c-1, c).
static func vicini_raw(h: String) -> Array:
	var p := rc(h)
	var r := p.x
	var c := p.y
	var o: Array = [hk(r, c - 1), hk(r, c + 1)]
	var a := c if r % 2 == 0 else c - 1
	for dr in [-1, 1]:
		o.append(hk(r + dr, a))
		o.append(hk(r + dr, a + 1))
	return o

func vicini(h: String) -> Array:
	var o: Array = []
	for v in vicini_raw(h):
		if esagoni.has(v):
			o.append(v)
	return o

static func assiale(h: String) -> Vector2i:
	var p := rc(h)
	return Vector2i(p.y - (p.x + (p.x & 1)) / 2, p.x)

static func distanza(a: String, b: String) -> int:
	var x := assiale(a)
	var y := assiale(b)
	return (abs(x.x - y.x) + abs(x.y - y.y) + abs(x.x + x.y - y.x - y.y)) / 2

func lato(a: String, b: String) -> String:
	var k := a + "|" + b if a < b else b + "|" + a
	return lati.get(k, "")

func strada(a: String, b: String) -> String:
	var k := a + "|" + b if a < b else b + "|" + a
	return strade.get(k, "")

func ha_strada(h: String, tipi := ["P", "S"]) -> bool:
	for v in vicini(h):
		if strada(h, v) in tipi: return true
	return false

func terreno(h: String) -> String:
	return esagoni[h]["t"] if esagoni.has(h) else ""

func settore(h: String) -> String:
	if esagoni.has(h):
		return esagoni[h]["s"]
	var p := rc(h)
	return "E" if p.y <= 18 + (p.x % 2) else "W"

func basso(h: String) -> bool:
	return terreno(h) in BASSO

func alto(h: String) -> bool:
	return terreno(h) in ["altura", "bocage", "bosco"]

func spiaggia(h: String) -> bool:
	return terreno(h) == "spiaggia"

func edifici(h: String) -> bool:
	return esagoni.has(h) and esagoni[h].get("ed", 0) == 1

## Centro dell'esagono in pixel sulla mappa ridotta del gioco.
func centro(h: String) -> Vector2:
	var p := rc(h)
	var g := griglia
	var x: float = g["x0"] + g["W"] * p.y + (g["odd"] if p.x % 2 == 1 else 0.0) + g["dx"]
	var y: float = g["y0"] - g["RS"] * p.x
	return Vector2(x * g["scala"], (y - g["y_taglio"]) * g["scala"])

func raggio() -> float:
	return griglia["size"] * griglia["scala"]

func da_pixel(pt: Vector2) -> String:
	var g := griglia
	var y: float = pt.y / g["scala"] + g["y_taglio"]
	var r0 := int(round((g["y0"] - y) / g["RS"]))
	var best := ""
	var bd := 1e20
	for r in range(r0 - 1, r0 + 2):
		for c in range(0, 40):
			var h := hk(r, c)
			var d := centro(h).distance_squared_to(pt)
			if d < bd:
				bd = d
				best = h
	return best

## Campo di fuoco della posizione (le WN su due esagoni hanno un campo unico).
func campo(id: String) -> Dictionary:
	var g: String = posizioni[id].get("gruppo", id)
	return fuoco.get(g, {})
