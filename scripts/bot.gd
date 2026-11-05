## Giocatore US automatico, usato per le partite di prova e per il pulsante "Gioca il turno per me".
class_name Bot
extends RefCounted

var g: Partita

func _init(p: Partita) -> void:
	g = p

func gioca_turno() -> void:
	if g.s["fase"] != "azioni":
		return
	for u in g.sulla_mappa():
		if u["conf"] == 1 and not u["agito"]:
			g.togli_confusione(u)
		elif u["scalata"] != "" and not u["agito"] and u["conf"] == 0:
			if u["scalata"].begins_with("scogliera:"):
				var m = g.mosse(u)
				if not m.is_empty(): g.muovi(u, m.keys()[0])
			else:
				g.togli_scalata(u)
	# attacchi
	var tentati = {}
	for i in 6:
		var migliore = ""
		var best_val = 0.0
		var best_l: Array = []
		for pid in g.pos_attive():
			for T in g.mappa.posizioni[pid]["hex"]:
				if not g.tedesco_in(T) or tentati.has(T) or not g.attaccabile(T): continue
				var c = g.candidati_attacco(T)
				if c.is_empty(): continue
				if g.verifica_attacco(T, c) != "":
					c = c.filter(func(u): return g.verifica_attacco(T, [u]) == "" or g.fanteria(u))
					if g.verifica_attacco(T, c) != "": continue
				var v = g.valuta(T, c, false)
				var du = g.def_tedesca(pid)
				var dif: float = du["forza"] * v["mu"] if g.s["de"][pid]["u"]["riv"] else 2.5 * v["mu"]
				var r: float = float(v["forza"]) / max(1.0, dif)
				if r > best_val:
					best_val = r; migliore = T; best_l = c
		if migliore == "" or best_val < 1.5:
			break
		tentati[migliore] = true
		var usa_navale: bool = g.s["navali"] > 0 and best_val < 3.0
		var e = g.attacca(migliore, best_l, usa_navale)
		if e.begins_with("Per il fuoco navale"):
			g.attacca(migliore, best_l, false)
	# movimenti: lontano dalla marea che sale, al riparo, poi su per le dune verso le posizioni
	var esp = _esposizione()
	var ordine = g.sulla_mappa()
	ordine.sort_custom(func(a, b): return _urgenza(a) > _urgenza(b))
	for u in ordine:
		if u["agito"]: continue
		var m = g.mosse(u)
		if m.is_empty(): continue
		var scelta = ""
		var best = _valore(u, u["hex"], "", esp)
		for v in m:
			var val = _valore(u, v, m[v], esp)
			if val < best - 0.01:
				best = val; scelta = v
		if scelta != "":
			g.muovi(u, scelta)
	# sbarramenti dei carri
	for u in g.sulla_mappa():
		if g.tipo(u) != "carro" or not g.puo_agire(u): continue
		for pid in g.pos_attive():
			var T: String = g.mappa.posizioni[pid]["hex"][0]
			if g.puo_sbarrare(u, T) == "":
				g.sbarramento(u, T)
				break

func _urgenza(u: Dictionary) -> float:
	var t: int = g.s["turno"]
	var v := 0.0
	if t >= 4 and t <= 7 and g.mappa.bassa_set.has(u["hex"]): v += 10.0
	if g.combattenti_in(u["hex"]).size() > 2: v += 8.0
	if g.fanteria(u): v += 1.0
	return v

func _esposizione() -> Dictionary:
	var e = {}
	for pid in g.pos_attive():
		if g.s["de"][pid]["conf"]: continue
		var c = g.mappa.campo(pid)
		for h in c:
			e[h] = e.get(h, 0.0) + float(c[h])
	return e

func _valore(u: Dictionary, h: String, k: String, esp: Dictionary) -> float:
	var t: int = g.s["turno"]
	var v = _distanza_obiettivo(h) * 1.0 + esp.get(h, 0.0) * 0.6
	if t >= 4 and t <= 7 and g.mappa.bassa_set.has(h): v += 20.0
	if t >= 12 and g.mappa.media_set.has(h): v += 20.0
	if g.mappa.protezione.has(h): v -= 1.5
	if k == "scogliera": v += 2.0
	if k == "duna": v += 0.5
	return v

func _distanza_obiettivo(h: String) -> float:
	var dmin = 99.0
	for pid in g.pos_attive():
		for x in g.mappa.posizioni[pid]["hex"]:
			dmin = min(dmin, float(Mappa.distanza(h, x)))
	if dmin == 99.0:
		return 0.0
	return dmin
