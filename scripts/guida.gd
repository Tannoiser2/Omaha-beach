## Guida del tutorial: per ogni esercizio trova un'unità che può davvero eseguirlo e,
## se nella partita non ce n'è nessuna, prepara la situazione (spostando o rendendo
## disponibile un'unità) in modo che il compito sia sempre possibile.
class_name Guida
extends RefCounted

var g: Partita

func _init(partita: Partita) -> void:
	g = partita

## Restituisce {"ok", "testo", "unita": hex, "mete": [hex], "nota"}
func trova(tipo: String) -> Dictionary:
	match tipo:
		"riparo": return _mossa("autocons", "una fanteria", "un esagono azzurro (riparo gratuito)")
		"muovi": return _mossa("muovi", "un'unità", "un esagono verde")
		"duna": return _mossa("duna", "una fanteria", "un esagono arancio (scalata della duna)")
		"due_esagoni": return _due_esagoni()
		"attacco": return _attacco()
		"sbarramento": return _sbarramento()
		"cp": return _cp()
		"base": return _base()
	return {"ok": false}

## Prova a trovare; se non c'è niente, prepara la situazione e riprova.
func guida(tipo: String) -> Dictionary:
	var r = trova(tipo)
	if r.get("ok", false): return r
	var nota = prepara(tipo)
	r = trova(tipo)
	if r.get("ok", false) and nota != "":
		r["nota"] = nota
	return r

func _nome(u: Dictionary) -> String:
	return "%s (esagono %s)" % [u["id"], u["hex"]]

func _azione_libera(u: Dictionary) -> bool:
	return g.puo_agire(u) and u["conf"] == 0 and u["scalata"] == ""

func _mossa(tipo: String, chi: String, dove: String) -> Dictionary:
	var migliore = {}
	var mete: Array = []
	for u in g.sulla_mappa():
		if not _azione_libera(u): continue
		if tipo != "muovi" and not g.fanteria(u): continue
		var mm: Dictionary = g.mosse(u)
		var qui: Array = []
		for h in mm:
			if mm[h] == tipo: qui.append(h)
		if qui.size() > mete.size():
			migliore = u
			mete = qui
	if migliore.is_empty(): return {"ok": false}
	return {"ok": true, "unita": migliore["hex"], "mete": mete,
		"testo": "Seleziona %s (bordo giallo; se nell'esagono ci sono più unità, clicca di nuovo per passare alla successiva) e clicca %s, evidenziato in bianco." % [_nome(migliore), dove]}

func _due_esagoni() -> Dictionary:
	for u in g.sulla_mappa():
		if not _azione_libera(u) or not g.fanteria(u): continue
		var mm: Dictionary = g.mosse(u)
		var qui: Array = []
		for h in mm:
			if mm[h] == "muovi" and Mappa.distanza(u["hex"], h) == 2: qui.append(h)
		if not qui.is_empty():
			return {"ok": true, "unita": u["hex"], "mete": qui,
				"testo": "Seleziona %s (bordo giallo) e clicca un esagono verde a due passi, come quelli evidenziati in bianco." % _nome(u)}
	return {"ok": false}

func _attacco() -> Dictionary:
	for pid in g.pos_attive():
		var T: String = g.mappa.posizioni[pid]["hex"][0]
		var c: Array = g.candidati_attacco(T)
		if c.is_empty() or g.verifica_attacco(T, c) != "": continue
		var inf = c.filter(func(u): return g.fanteria(u) and Mappa.distanza(u["hex"], T) == 1)
		if inf.is_empty(): continue
		return {"ok": true, "unita": inf[0]["hex"], "mete": [T],
			"testo": "Seleziona %s (bordo giallo), premi «Attacca» nella scheda e clicca la posizione %s (in bianco), poi conferma." % [_nome(inf[0]), g.nome_pos(pid)]}
	return {"ok": false}

func _sbarramento() -> Dictionary:
	for u in g.sulla_mappa():
		if g.tipo(u) != "carro": continue
		for pid in g.pos_attive():
			var T: String = g.mappa.posizioni[pid]["hex"][0]
			if g.puo_sbarrare(u, T) == "":
				return {"ok": true, "unita": u["hex"], "mete": [T],
					"testo": "Seleziona il carro %s (bordo giallo), premi «Fuoco di sbarramento» e clicca la posizione %s (in bianco)." % [_nome(u), g.nome_pos(pid)]}
	return {"ok": false}

func _cp() -> Dictionary:
	for u in g.sulla_mappa():
		if g.puo_cp(u) == "":
			return {"ok": true, "unita": u["hex"], "mete": [],
				"testo": "Seleziona l'HQ %s (bordo giallo) e premi «Posto di Comando» nella scheda." % _nome(u)}
	return {"ok": false}

func _base() -> Dictionary:
	for div in [1, 29]:
		var mete: Array = []
		for h in g.mappa.esagoni:
			if g.puo_base(h, div) == "": mete.append(h)
		if not mete.is_empty():
			return {"ok": true, "unita": "", "mete": mete,
				"testo": "Premi «Base del Genio %s» e clicca uno degli esagoni di spiaggia evidenziati in bianco." % ("1ª" if div == 1 else "29ª")}
	return {"ok": false}

# ---------------------------------------------------------------- preparazione

## Rende l'esercizio possibile; restituisce la frase che spiega cosa è stato fatto ("" se nulla).
func prepara(tipo: String) -> String:
	var nota = ""
	# un'azione in più se la Divisione le ha finite
	for d in ["1", "29"]:
		if g.s["azioni"].has(d) and g.s["azioni"][d] == 0:
			g.s["azioni"][d] = 1
			nota = "Per l'esercizio il tutorial restituisce un'azione alla Divisione. "
	if trova(tipo).get("ok", false): return nota
	match tipo:
		"riparo", "muovi", "duna", "due_esagoni":
			var u = _fanteria_libera()
			if u.is_empty(): return nota
			var dest = _esagono_per(tipo, u)
			if dest == "": return nota
			u["hex"] = dest
			return nota + "Per l'esercizio %s è stata portata in %s." % [u["id"], dest]
		"attacco":
			var r = _prepara_attacco()
			if r != "": return nota + r
		"sbarramento":
			var r2 = _prepara_sbarramento()
			if r2 != "": return nota + r2
		"cp":
			for u in g.s["us"]:
				if g.tipo(u) != "hq" or u["dove"] != "mappa": continue
				var h = _esagono_sicuro(u["hex"])
				if h == "": continue
				u["hex"] = h
				u["agito"] = false
				g.s["leader_mossi"].erase(u["id"])
				return nota + "Per l'esercizio l'HQ %s è stato portato in %s, fuori dal fuoco tedesco." % [u["id"], h]
	return nota

func _fanteria_libera() -> Dictionary:
	for u in g.sulla_mappa():
		if g.fanteria(u) and not g.leader(u) and _azione_libera(u) and u["passo"] == 0: return u
	for u in g.sulla_mappa():
		if g.fanteria(u) and not g.leader(u) and _azione_libera(u): return u
	for u in g.s["us"]:
		if g.fanteria(u) and not g.leader(u) and u["dove"] in ["box", "traccia"]:
			u["dove"] = "mappa"; u["agito"] = false; u["conf"] = 0; u["scalata"] = ""
			u["hex"] = "0712"
			return u
	return {}

func _libero(h: String) -> bool:
	return g.combattenti_in(h).size() < 2 and not g.tedesco_in(h) and not g.sommerso(h)

func _esagono_per(tipo: String, u: Dictionary) -> String:
	var orig: String = u["hex"]
	var k = {"riparo": "autocons", "due_esagoni": "muovi"}.get(tipo, tipo)
	var cand: Array = g.mappa.esagoni.keys()
	# prima gli esagoni di spiaggia, poi gli altri esagoni bassi (pianori, valli)
	cand.sort_custom(func(a, b): return [0 if g.mappa.spiaggia(a) else 1, Mappa.distanza(orig, a)] < [0 if g.mappa.spiaggia(b) else 1, Mappa.distanza(orig, b)])
	for h in cand:
		if not g.mappa.basso(h) or not _libero(h): continue
		if g.easy() and g.mappa.settore(h) == "W": continue
		u["hex"] = h
		var ok = false
		var mm: Dictionary = g.mosse(u)
		for v in mm:
			if mm[v] == k and tipo != "due_esagoni": ok = true
			if tipo == "due_esagoni" and mm[v] == "muovi" and Mappa.distanza(h, v) == 2: ok = true
		u["hex"] = orig
		if ok: return h
	return ""

func _prepara_attacco() -> String:
	# porta due fanterie a piena forza accanto alla WN più vicina attaccabile
	var fanti: Array = []
	for u in g.sulla_mappa():
		if g.fanteria(u) and not g.leader(u) and _azione_libera(u): fanti.append(u)
	if fanti.is_empty(): return ""
	fanti.sort_custom(func(a, b): return a["passo"] < b["passo"])
	for pid in g.pos_attive():
		var T: String = g.mappa.posizioni[pid]["hex"][0]
		if not g.attaccabile(T): continue
		if g.easy() and g.mappa.settore(T) == "W": continue
		for v in g.mappa.vicini(T):
			if not g.mappa.esagoni.has(v) or not _libero(v) or not g._adiacente_ok(v, T): continue
			if g.combattenti_in(v).size() > 0: continue
			var mossi: Array = []
			for u in fanti.slice(0, 2):
				mossi.append([u, u["hex"]])
				u["hex"] = v
			if g.verifica_attacco(T, g.candidati_attacco(T)) == "":
				var nomi = " e ".join(mossi.map(func(x): return x[0]["id"]))
				return "Per l'esercizio %s %s in %s, accanto alla %s." % [nomi, "sono state portate" if mossi.size() > 1 else "è stata portata", v, g.nome_pos(pid)]
			for x in mossi: x[0]["hex"] = x[1]
	return ""

func _prepara_sbarramento() -> String:
	var carro = {}
	for u in g.sulla_mappa():
		if g.tipo(u) == "carro" and _azione_libera(u): carro = u; break
	if carro.is_empty():
		for u in g.s["us"]:
			if g.tipo(u) == "carro" and u["dove"] in ["box", "traccia"]:
				carro = u
				u["dove"] = "mappa"; u["agito"] = false; u["conf"] = 0; u["scalata"] = ""
				u["hex"] = "0712"
				break
	if carro.is_empty(): return ""
	var orig: String = carro["hex"]
	for pid in g.pos_attive():
		var T: String = g.mappa.posizioni[pid]["hex"][0]
		if g.easy() and g.mappa.settore(T) == "W": continue
		var campo = g.mappa.campo(pid)
		for h in campo:
			if not g.mappa.spiaggia(h) or not _libero(h): continue
			carro["hex"] = h
			if g.puo_sbarrare(carro, T) == "":
				return "Per l'esercizio il carro %s è stato portato in %s." % [carro["id"], h]
	carro["hex"] = orig
	return ""

func _esagono_sicuro(orig: String) -> String:
	var cand: Array = g.mappa.esagoni.keys()
	cand.sort_custom(func(a, b): return Mappa.distanza(orig, a) < Mappa.distanza(orig, b))
	for h in cand:
		if _libero(h) and not g.in_campo_potenziale(h): return h
	return ""
