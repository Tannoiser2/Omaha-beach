## Azioni US (movimento, scalate, attacchi, sbarramenti, fuoco navale) e vittoria.
class_name Partita
extends Gioco

# ---------------------------------------------------------------- costo delle azioni
func in_comando(u: Dictionary, solo_hq := false) -> bool:
	for l in s["comando"].get(u["id"], []):
		if s["leader_mossi"].has(l): continue
		var lu = unita(l)
		if lu.is_empty() or lu["dove"] != "mappa": continue
		if solo_hq and tipo(lu) != "hq": continue
		return true
	return false

func hq_che_comanda(u: Dictionary) -> Array:
	var o: Array = []
	for l in s["comando"].get(u["id"], []):
		var lu = unita(l)
		if not lu.is_empty() and tipo(lu) == "hq" and lu["dove"] == "mappa":
			o.append(l)
	return o

func gratuita(u: Dictionary) -> bool:
	if tipo(u) == "ranger" or leader(u): return true
	if u["eroe"] >= 0 or u["ispirato"]: return true
	return in_comando(u)

func puo_agire(u: Dictionary) -> bool:
	if u["dove"] != "mappa" or u["agito"] or s["fase"] != "azioni": return false
	if gratuita(u): return true
	return s["azioni"][str(u["cmd"])] > 0

func paga(lista: Array) -> void:
	# due unità dello stesso esagono che fanno la stessa azione pagano una sola azione (7.21)
	var per_hex = {}
	for u in lista:
		u["agito"] = true
		if gratuita(u): continue
		var k: String = u["hex"] + "/" + str(u["cmd"])
		per_hex[k] = per_hex.get(k, 0) + 1
	for k in per_hex:
		var div: String = k.split("/")[1]
		var n: int = (per_hex[k] + 1) / 2
		s["azioni"][div] = max(0, s["azioni"][div] - n)

func azioni_rimaste(div: int) -> int:
	return s["azioni"][str(div)]

# ---------------------------------------------------------------- movimento
func _dist_riparo() -> Dictionary:
	var d = {}
	var coda: Array = []
	for h in mappa.protezione:
		d[h] = 0
		coda.append(h)
	while not coda.is_empty():
		var h: String = coda.pop_front()
		for v in mappa.vicini(h):
			if mappa.spiaggia(v) and not d.has(v):
				d[v] = d[h] + 1
				coda.append(v)
	return d

func sommerso(h: String) -> bool:
	var m = marea()
	if m == "media" and mappa.bassa_set.has(h): return true
	if m == "alta" and (mappa.bassa_set.has(h) or mappa.media_set.has(h)): return true
	return false

## Esagoni raggiungibili: hex -> "muovi" | "autocons" | "duna" | "scogliera"
func mosse(u: Dictionary) -> Dictionary:
	var o = {}
	var solo_auto = false
	if u["dove"] == "mappa" and not u["agito"] and s["fase"] == "azioni" and not puo_agire(u) and fanteria(u) and u["conf"] == 0 and u["scalata"] == "":
		solo_auto = true
	if (not puo_agire(u) and not solo_auto) or u["conf"] > 0 or u["scalata"] != "":
		if u["dove"] == "mappa" and not u["agito"] and u["scalata"].begins_with("scogliera:") and u["conf"] == 0:
			var dest: String = u["scalata"].split(":")[1]
			if not tedesco_in(dest): o[dest] = "fine_scogliera"
		return o
	var h: String = u["hex"]
	var tp = tipo(u)
	var dr = _dist_riparo() if fanteria(u) and mappa.spiaggia(h) else {}
	for v in mappa.vicini(h):
		if tedesco_in(v) or sommerso(v): continue
		if not leader(u) and combattenti_in(v).size() >= 2: continue
		var t = mappa.terreno(v)
		var l = mappa.lato(h, v)
		if tp == "generale":
			if l != "X": o[v] = "muovi"
			continue
		if l == "X" or t == "accidentato": continue
		if veicolo(u):
			if t in ["spiaggia", "pianoro"] and l == "": o[v] = "muovi"
			continue
		if tp == "hq":
			if l != "C": o[v] = "muovi"
			continue
		# fanteria
		if l == "B": o[v] = "duna"
		elif l == "C": o[v] = "scogliera"
		else: o[v] = "muovi"
		if o[v] == "muovi" and mappa.spiaggia(h) and mappa.spiaggia(v) and dr.has(v) and dr.has(h) and dr[v] < dr[h]:
			o[v] = "autocons"
	if solo_auto:
		for v in o.keys():
			if o[v] != "autocons": o.erase(v)
	return o

func _infiltrazione(h: String, v: String) -> Array:
	var o: Array = []
	var visti = {}
	for pid in mappa.posizioni:
		var g: String = mappa.posizioni[pid].get("gruppo", pid)
		if visti.has(g): continue
		visti[g] = true
		var parti = gruppo(pid)
		var attiva = false
		var hexs: Array = []
		for x in parti:
			hexs += mappa.posizioni[x]["hex"]
			if occupata(x) and not s["de"][x]["conf"]: attiva = true
		if not attiva: continue
		var campo = mappa.campo(pid)
		var adj_h = hexs.any(func(x): return Mappa.distanza(x, h) == 1)
		var adj_v = hexs.any(func(x): return Mappa.distanza(x, v) == 1)
		if adj_h and adj_v and campo.has(h) and campo.has(v):
			o.append(pid)
	return o

## Muove l'unità (e, se richiesto, la sua compagna di esagono con la stessa azione).
func muovi(u: Dictionary, v: String, compagna: Dictionary = {}) -> String:
	var m = mosse(u)
	if not m.has(v): return "Movimento non permesso."
	var k: String = m[v]
	var gruppo_m: Array = [u]
	if not compagna.is_empty() and compagna != u and mosse(compagna).get(v, "") == k and k in ["muovi", "duna"]:
		gruppo_m.append(compagna)
	var h: String = u["hex"]
	if k == "scogliera":
		u["scalata"] = "scogliera:" + v
		paga([u])
		dlog("%s inizia a scalare la scogliera verso %s." % [u["id"], v], "azione")
		return ""
	if k == "fine_scogliera":
		u["agito"] = true
		u["hex"] = v
		u["scalata"] = "duna"
		dlog("%s supera la scogliera ed entra in %s." % [u["id"], v], "azione")
		return ""
	if leader(u) and gruppo_m.size() == 1 and not _infiltrazione(h, v).is_empty():
		return "Un comando da solo non può infiltrarsi tra due esagoni battuti dalla stessa posizione."
	if k == "autocons":
		for x in gruppo_m: x["agito"] = true
	else:
		paga(gruppo_m)
	if leader(u):
		s["leader_mossi"][u["id"]] = true
	var inf = _infiltrazione(h, v)
	for x in gruppo_m:
		x["hex"] = v
		if k == "duna" and not leader(x):
			x["scalata"] = "duna"
	var nomi = ", ".join(gruppo_m.map(func(x): return x["id"]))
	dlog("%s %s in %s." % [nomi, "scala la duna ed entra" if k == "duna" else ("si mette al riparo" if k == "autocons" else "si sposta"), v], "azione")
	if not inf.is_empty():
		var n = pesca()
		var c = carta(n)
		dlog("Infiltrazione sotto il fuoco di %s: carta %d." % [", ".join(inf.map(func(p): return nome_pos(p))), n], "carta")
		for x in gruppo_m:
			if leader(x): continue
			var colpito = false
			for pid in inf:
				var q = _quadrato(c, colore(pid))
				if q.is_empty(): continue
				var dm = gruppo(pid).any(func(p): return not s["de"][p]["dm"].is_empty())
				if q["doppio"] and not dm: continue
				if simbolo(x) == c["bersaglio"]: colpito = true
			if colpito:
				perdi_passo(x, "infiltrazione")
	return ""

func togli_confusione(u: Dictionary) -> void:
	if u["conf"] == 1 and not u["agito"] and u["dove"] == "mappa":
		u["conf"] = 0
		u["agito"] = true
		dlog("%s si riorganizza (tolta la confusione)." % u["id"], "azione")

func togli_scalata(u: Dictionary) -> void:
	if u["scalata"] != "" and not u["agito"] and u["conf"] == 0:
		if u["scalata"].begins_with("scogliera:"):
			dlog("%s rinuncia alla scalata della scogliera." % u["id"], "azione")
		else:
			dlog("%s completa la scalata." % u["id"], "azione")
		u["scalata"] = ""
		u["agito"] = true

# ---------------------------------------------------------------- attacco
func attaccabile(T: String) -> bool:
	if not tedesco_in(T): return false
	var pid = pos_di(T)
	return not s["attaccati"].has(pid) and not s["sbarrati"].has(pid)

func _tiro_vietato_dal_basso(da: String, T: String) -> bool:
	# 8.12: dalla spiaggia o dal pianoro non si spara a distanza su una posizione più alta,
	# a meno che proietti fuoco su almeno un esagono di spiaggia
	if not mappa.basso(da) or mappa.basso(T): return false
	var campo = mappa.campo(pos_di(T))
	for h in campo:
		if mappa.spiaggia(h): return false
	return true

func _adiacente_ok(da: String, T: String) -> bool:
	var l = mappa.lato(da, T)
	if l in ["C", "X"]: return false
	if l == "B" and mappa.basso(da) and not mappa.basso(T): return false
	return true

## Unità che possono partecipare a un attacco contro T. Restituisce [{u, motivo}].
func candidati_attacco(T: String) -> Array:
	var o: Array = []
	if not attaccabile(T): return o
	var fanterie = []
	for u in sulla_mappa():
		if not puo_agire(u) or u["conf"] > 0 or u["scalata"] != "" or leader(u): continue
		var d = Mappa.distanza(u["hex"], T)
		var tp = tipo(u)
		if fanteria(u):
			if d == 1 and _adiacente_ok(u["hex"], T):
				o.append(u); fanterie.append(u)
			elif d <= gittata(u) and d >= 1 and tp == "pesante" and u["passo"] == 0:
				o.append(u)
			elif d == 1 and tp == "pesante" and u["passo"] == 0:
				o.append(u)
		elif tp in ["carro", "anticarro", "antiaerea", "antiaerea_sp"]:
			if d <= gittata(u) and not (d > 1 and _tiro_vietato_dal_basso(u["hex"], T)):
				o.append(u)
		elif tp in ["artiglieria", "artiglieria_sp"]:
			if d > 1 and not _tiro_vietato_dal_basso(u["hex"], T) and not hq_che_comanda(u).is_empty():
				if tp == "artiglieria_sp" or not _in_campo_attivo(u["hex"]):
					o.append(u)
	return o

func _in_campo_attivo(h: String) -> bool:
	for pid in pos_attive():
		if s["de"][pid]["conf"]: continue
		if mappa.campo(pid).has(h): return true
	return false

## Controlla la validità del gruppo d'attacco scelto; "" se valido.
func verifica_attacco(T: String, lista: Array) -> String:
	if lista.is_empty(): return "Scegli almeno un'unità."
	var adj_inf = lista.filter(func(u): return fanteria(u) and Mappa.distanza(u["hex"], T) == 1 and _adiacente_ok(u["hex"], T))
	if adj_inf.is_empty():
		return "Serve almeno una fanteria adiacente all'obiettivo (da un lato che permette l'attacco)."
	var inf_cmd = adj_inf.any(func(u): return in_comando(u))
	for u in lista:
		var d = Mappa.distanza(u["hex"], T)
		var tp = tipo(u)
		if tp in ["carro", "anticarro", "antiaerea", "antiaerea_sp"]:
			var ok = d == 1 or adj_inf.any(func(f): return Mappa.distanza(f["hex"], u["hex"]) <= 1) or in_comando(u) or inf_cmd
			if not ok: return "%s non può unirsi: deve essere adiacente all'obiettivo o a una fanteria che attacca, oppure sotto comando." % u["id"]
		if tp in ["artiglieria", "artiglieria_sp"]:
			var hq = hq_che_comanda(u)
			var ok2 = false
			for f in adj_inf:
				for q in hq_che_comanda(f):
					if q in hq: ok2 = true
			if not ok2: return "%s può sparare solo con un HQ che comanda anche una fanteria che attacca." % u["id"]
		if fanteria(u) and d == 1 and not _adiacente_ok(u["hex"], T):
			if not (tipo(u) == "pesante" and u["passo"] == 0):
				return "%s non può attaccare attraverso quel lato." % u["id"]
		if fanteria(u) and d == 2 and not (tipo(u) == "pesante" and u["passo"] == 0):
			return "%s deve essere adiacente." % u["id"]
	return ""

func armi_unita(u: Dictionary, T: String) -> Array:
	var tp = tipo(u)
	var d = Mappa.distanza(u["hex"], T)
	var a: Array = []
	if fanteria(u):
		if u["passo"] == 0:
			if tp == "pesante" and (d > 1 or not _adiacente_ok(u["hex"], T)):
				a = ["BZ", "MO", "RD", "BR", "MG"]
			else:
				a = ARMI_PIENE.duplicate()
				if tp == "pesante": a.append("MG")
		else:
			a = passo(u)["armi"].duplicate()
		if d == 1 and not hq_che_comanda(u).is_empty() and in_comando(u, true):
			a.append("RD")
	elif tp == "carro":
		a = ["AR", "BZ"]
		if d <= 3: a += ["MG", "BR"]
	elif tp in ["antiaerea", "antiaerea_sp"]:
		a = ["MG", "BR"]
	elif tp in ["artiglieria", "artiglieria_sp"]:
		a = ["AR", "MO", "DE"]
	elif tp == "anticarro":
		a = ["AR", "BZ"]
	return a

func _moltiplicatori(T: String, lista: Array) -> Vector2i:
	var mu = 1
	var md = 1
	var t = mappa.terreno(T)
	if mappa.edifici(T) or t == "bocage":
		mu = 2; md = 2
	elif t == "bosco":
		mu = 2
	var adj = lista.filter(func(u): return Mappa.distanza(u["hex"], T) == 1)
	var su = 99
	var sd = 99
	var lati_usati = {}
	for u in adj:
		var l = mappa.lato(u["hex"], T)
		lati_usati[l + u["hex"]] = true
		var a = Vector2i(1, 1)
		if l == "L": a = Vector2i(2, 2)
		elif l == "B": a = Vector2i(2, 2)
		elif l == "W": a = Vector2i(2, 1)
		elif mappa.esagoni[u["hex"]].get("cio", 0) == 1 and not mappa.spiaggia(T): a = Vector2i(2, 1)
		su = min(su, a.x); sd = min(sd, a.y)
	if su == 99: su = 1
	if sd == 99: sd = 1
	# il pendio raddoppia solo se tutti attaccano attraverso lo stesso lato
	if su == 2 and sd == 2 and lati_usati.size() > 1:
		var tutti_l = true
		for u in adj:
			if mappa.lato(u["hex"], T) != "B": tutti_l = false
		if not tutti_l: su = 1; sd = 1
	return Vector2i(max(mu, su), max(md, sd))

func _aggiramento(T: String, lista: Array, quanti: int) -> bool:
	var hexs = {}
	for u in lista:
		if Mappa.distanza(u["hex"], T) == 1: hexs[u["hex"]] = true
	var hh: Array = hexs.keys()
	if quanti >= 2:
		return hh.size() >= 3
	for i in hh.size():
		for j in range(i + 1, hh.size()):
			if Mappa.distanza(hh[i], hh[j]) > 1: return true
	return false

## Valuta l'attacco senza applicarlo (per l'anteprima e per il giocatore automatico).
func valuta(T: String, lista: Array, navale := false) -> Dictionary:
	var pid = pos_di(T)
	var de: Dictionary = s["de"][pid]
	var forza = 0
	for u in lista: forza += attacco(u)
	if navale: forza += 9
	var armi = {}
	for u in lista:
		for a in armi_unita(u, T): armi[a] = true
	if navale:
		for a in ["NA", "AR", "DE"]: armi[a] = true
	var eroe = lista.any(func(u): return u["eroe"] >= 0 and not u["ispirato"] and Mappa.distanza(u["hex"], T) == 1)
	var m = _moltiplicatori(T, lista)
	return {"pid": pid, "forza": forza, "armi": armi, "eroe": eroe, "mu": m.x, "md": m.y, "de": de}

func _confronto(forza: int, difesa: int, armi_ok: bool) -> String:
	if armi_ok:
		if forza >= 2 * difesa: return "d2"
		if forza > difesa: return "gt"
		if forza == difesa: return "eq"
		return "lt"
	if forza >= 2 * difesa: return "d2"
	if forza > difesa: return "gt"
	return "le"

func _richieste(pid: String, con_dm: bool) -> Array:
	var r: Array = def_tedesca(pid)["armi"].duplicate()
	if con_dm and not s["de"][pid]["dm"].is_empty():
		r += def_dm(pid)["armi"]
	return r

## Risolve l'attacco. Restituisce un resoconto testuale.
func attacca(T: String, lista: Array, navale := false, logoramento := true) -> String:
	var err = verifica_attacco(T, lista)
	if err != "": return err
	if navale and s["navali"] <= 0: return "Non hai segnalini di fuoco navale."
	if navale and not lista.any(func(u): return fanteria(u) and (("RD" in armi_unita(u, T)) or in_comando(u, true))):
		return "Per il fuoco navale serve una fanteria con radio o sotto comando di un HQ."
	var v = valuta(T, lista, navale)
	var pid: String = v["pid"]
	var de: Dictionary = s["de"][pid]
	paga(lista)
	if navale: s["navali"] -= 1
	s["attaccati"][pid] = true
	var righe: Array = []
	righe.append("Attacco contro %s (%s) con %s: forza %d%s." % [nome_pos(pid), T, ", ".join(lista.map(func(u): return u["id"])), v["forza"], " + fuoco navale" if navale else ""])
	if not de["u"]["riv"]:
		de["u"]["riv"] = true
		righe.append("Si rivela l'unità tedesca: %s." % descrivi_tedesco(pid))
	var ripeti = true
	var giri = 0
	var esito = ""
	while ripeti and giri < 3:
		giri += 1
		ripeti = false
		var col = "solo"
		if not de["dm"].is_empty():
			col = "dm_riv" if de["dm"]["riv"] else "dm_nasc"
		var du: Dictionary = def_tedesca(pid)
		var difesa: int = du["forza"] * v["mu"]
		if col == "dm_riv":
			difesa += def_dm(pid)["forza"] * v["md"]
		var req = _richieste(pid, col == "dm_riv")
		var mancano: Array = []
		var fl = 0
		for r in req:
			if r == "FL": fl += 1
			elif not v["armi"].has(r): mancano.append(r)
		var fl_ok = fl == 0 or _aggiramento(T, lista, fl)
		var forza: int = v["forza"]
		var uso_eroe = ""
		if v["eroe"]:
			if mancano.size() == 1 and fl_ok:
				mancano = []
				uso_eroe = "l'eroe sostituisce l'arma mancante"
			else:
				forza += 1
				uso_eroe = "l'eroe aggiunge 1 alla forza"
		var armi_ok = mancano.is_empty() and fl_ok
		var cf = _confronto(forza, difesa, armi_ok)
		righe.append("Difesa tedesca %d%s; armi richieste: %s -> %s%s." % [difesa, " (terreno favorevole)" if v["mu"] > 1 else "", ", ".join(req) if not req.is_empty() else "nessuna", "tutte presenti" if armi_ok else ("manca " + ", ".join(mancano + (["aggiramento"] if not fl_ok else []))), (" (" + uso_eroe + ")") if uso_eroe != "" else ""])
		var tab = {
			true: {"lt": {"solo": "ted_dm", "dm_nasc": "us_conf", "dm_riv": "nulla"},
				"eq": {"solo": "ted_conf", "dm_nasc": "nulla", "dm_riv": "ted_conf"},
				"gt": {"solo": "sconfitta", "dm_nasc": "rivela", "dm_riv": "dm_elim_conf"},
				"d2": {"solo": "sconfitta", "dm_nasc": "rivela", "dm_riv": "dm_elim_conf"}},
			false: {"le": {"solo": "us_conf_ted_dm", "dm_nasc": "us_conf_nasc", "dm_riv": "us_conf"},
				"gt": {"solo": "ted_dm", "dm_nasc": "us_conf", "dm_riv": "nulla"},
				"d2": {"solo": "ted_conf", "dm_nasc": "ted_conf", "dm_riv": "ted_conf_logor"}}}
		esito = tab[armi_ok][cf][col]
		match esito:
			"rivela":
				de["dm"]["riv"] = true
				var dd = def_dm(pid)
				if dd.get("tattico", false):
					righe.append("Il segnalino Incognita chiama un rinforzo tattico: l'unità tedesca è sconfitta.")
					de["dm"] = {}
					_sconfitta(pid, righe)
					rinforzo_da_wn(pid)
				else:
					righe.append("Si rivela il segnalino Incognita: forza %d, armi %s. Nuovo confronto." % [dd["forza"], ", ".join(dd["armi"]) if not dd["armi"].is_empty() else "nessuna"])
					ripeti = true
			"sconfitta":
				_sconfitta(pid, righe)
			"dm_elim_conf":
				de["dm"] = {}
				de["conf"] = true
				righe.append("Il segnalino Incognita è eliminato e l'unità tedesca va in confusione.")
			"ted_conf":
				de["conf"] = true
				righe.append("L'unità tedesca va in confusione.")
			"ted_conf_logor":
				de["conf"] = true
				righe.append("L'unità tedesca va in confusione.")
				if logoramento:
					var adj = lista.filter(func(u): return Mappa.distanza(u["hex"], T) == 1 and u["dove"] == "mappa")
					if not adj.is_empty():
						adj.sort_custom(func(a, b): return passi_rimasti(a) < passi_rimasti(b))
						righe.append("Logoramento: %s perde un punto forza e il segnalino Incognita è eliminato." % adj[0]["id"])
						de["dm"] = {}
						perdi_passo(adj[0], "logoramento")
			"ted_dm":
				if de["dm"].is_empty() and in_comunicazione(pid):
					de["dm"] = _dm_per(pid)
					righe.append("I tedeschi si rinforzano: arriva un segnalino Incognita." if not de["dm"].is_empty() else "Nessun effetto.")
				else:
					righe.append("Nessun effetto.")
			"us_conf":
				_conf_attaccanti(T, lista, righe)
			"us_conf_ted_dm":
				_conf_attaccanti(T, lista, righe)
				if de["dm"].is_empty() and in_comunicazione(pid):
					de["dm"] = _dm_per(pid)
					if not de["dm"].is_empty(): righe.append("I tedeschi ricevono un segnalino Incognita.")
			"us_conf_nasc":
				_conf_attaccanti(T, lista, righe)
				de["u"]["riv"] = false
				righe.append("L'unità tedesca torna nascosta.")
			"nulla":
				righe.append("Nessun effetto.")
	for r in righe: dlog(r, "attacco")
	return "\n".join(righe)

func _conf_attaccanti(T: String, lista: Array, righe: Array) -> void:
	var n: Array = []
	for u in lista:
		if Mappa.distanza(u["hex"], T) == 1 and u["dove"] == "mappa" and u["conf"] == 0:
			u["conf"] = 2
			n.append(u["id"])
	righe.append("L'attacco fallisce: %s in confusione." % (", ".join(n) if not n.is_empty() else "nessuna unità"))

func _sconfitta(pid: String, righe: Array) -> void:
	var de: Dictionary = s["de"][pid]
	var u: Dictionary = de["u"]
	var d = def_tedesca(pid)
	var ritira: bool = u["k"] != "wn" and int(d.get("div", 716)) == 352 and in_comunicazione(pid)
	if ritira:
		s["pool"]["D"].append([u["k"], u["i"]])
		s["pool"]["D"] = _mescola(s["pool"]["D"])
		righe.append("L'unità tedesca è sconfitta e si ritira nei rinforzi divisionali.")
	else:
		righe.append("L'unità tedesca è sconfitta ed eliminata.")
	s["de"][pid] = {"u": {}, "dm": {}, "conf": false}

# ---------------------------------------------------------------- sbarramenti
func puo_sbarrare(u: Dictionary, T: String) -> String:
	if tipo(u) != "carro": return "Solo i carri fanno fuoco di sbarramento."
	if not puo_agire(u) or u["conf"] > 0: return "L'unità non può agire."
	if not tedesco_in(T): return "Nessun tedesco nell'esagono."
	var pid = pos_di(T)
	if s["attaccati"].has(pid): return "La posizione è già stata attaccata in questo turno."
	if mappa.posizioni[pid]["tipo"] == "R" and not s["de"][pid]["u"]["riv"]: return "Non si può sparare su un rinforzo non rivelato."
	var d = Mappa.distanza(u["hex"], T)
	if d <= 1 or d > gittata(u): return "Il carro deve essere a portata ma non adiacente."
	if _tiro_vietato_dal_basso(u["hex"], T): return "Dal basso non si vede la posizione sulle alture."
	var campo = mappa.campo(pid)
	if campo.has(u["hex"]): return ""
	for f in sulla_mappa():
		if fanteria(f) and f["conf"] == 0 and campo.has(f["hex"]) and (in_comando(f) or in_comando(u)):
			return ""
	return "Serve un osservatore: il carro o una fanteria sotto comando nel campo di fuoco della posizione."

func sbarramento(u: Dictionary, T: String) -> String:
	var e = puo_sbarrare(u, T)
	if e != "": return e
	var pid = pos_di(T)
	paga([u])
	s["sbarrati"][pid] = true
	var n = pesca()
	var c = carta(n)
	var col = not _quadrato(c, colore(pid)).is_empty()
	var sim: bool = c["bersaglio"] == simbolo(u)
	var dm: bool = not s["de"][pid]["dm"].is_empty()
	var f = attacco(u)
	var fascia = 0 if f <= 2 else (1 if f <= 5 else 2)
	var r = "nulla"
	if col and sim:
		r = "conf_dm" if fascia == 2 else "conf"
	elif sim:
		if dm: r = "conf" if fascia == 2 else "nulla"
		else: r = "nulla" if fascia == 0 else "conf"
	elif col:
		if dm: r = "nulla" if fascia == 0 else "conf"
		else: r = "conf"
	var t = "%s spara su %s: carta %d (%s, %s)." % [u["id"], nome_pos(pid), n, "colore presente" if col else "colore assente", "simbolo presente" if sim else "simbolo assente"]
	if r == "nulla":
		t += " Nessun effetto."
	else:
		s["de"][pid]["conf"] = true
		t += " La posizione va in confusione."
		if r == "conf_dm" and dm:
			s["de"][pid]["dm"] = {}
			t += " Il segnalino Incognita è eliminato."
	dlog(t, "attacco")
	return t

func osservatori_navali(T: String) -> Array:
	var pid = pos_di(T)
	var campo = mappa.campo(pid)
	return sulla_mappa().filter(func(f): return fanteria(f) and f["conf"] == 0 and campo.has(f["hex"]) and ((f["passo"] == 0) or ("RD" in passo(f)["armi"]) or in_comando(f, true)))

func puo_navale(T: String) -> String:
	if s["navali"] <= 0: return "Non hai segnalini di fuoco navale."
	if not tedesco_in(T): return "Nessun tedesco nell'esagono."
	var pid = pos_di(T)
	if s["attaccati"].has(pid): return "La posizione è già stata attaccata in questo turno."
	if mappa.posizioni[pid]["tipo"] == "R" and not s["de"][pid]["u"]["riv"]: return "Non si può colpire un rinforzo non rivelato."
	if osservatori_navali(T).is_empty(): return "Serve una fanteria con radio (o sotto comando di un HQ) nel campo di fuoco della posizione."
	return ""

func navale(T: String) -> String:
	var e = puo_navale(T)
	if e != "": return e
	var pid = pos_di(T)
	s["navali"] -= 1
	s["sbarrati"][pid] = true
	s["de"][pid]["conf"] = true
	var t = "Fuoco navale su %s: la posizione va in confusione" % nome_pos(pid)
	if not s["de"][pid]["dm"].is_empty():
		s["de"][pid]["dm"] = {}
		t += " e perde il segnalino Incognita"
	dlog(t + ".", "attacco")
	return t + "."

# ---------------------------------------------------------------- vittoria
func esagoni_controllati() -> Dictionary:
	var ctrl = controllo()
	var campi = {}
	for pid in pos_attive():
		for h in mappa.campo(pid): campi[h] = true
	# comunicazione US: verso la spiaggia senza attraversare campi di fuoco, terreno accidentato, dune o scogliere
	var com = {}
	var coda: Array = []
	for h in mappa.esagoni:
		if mappa.spiaggia(h) and not campi.has(h):
			com[h] = true
			coda.append(h)
	while not coda.is_empty():
		var h: String = coda.pop_front()
		for v in mappa.vicini(h):
			if com.has(v) or campi.has(v) or tedesco_in(v): continue
			if mappa.terreno(v) == "accidentato": continue
			if mappa.lato(h, v) in ["B", "C", "X"]: continue
			com[v] = true
			coda.append(v)
	var o = {}
	for h in ctrl:
		if com.has(h) and not campi.has(h) and not tedesco_in(h):
			o[h] = true
	return o

func punti_vittoria() -> Dictionary:
	var c = esagoni_controllati()
	var wn = 0
	var rin = 0
	var dr = 0
	var fatti = {}
	for pid in mappa.posizioni:
		var p: Dictionary = mappa.posizioni[pid]
		if easy() and mappa.settore(p["hex"][0]) == "W": continue
		if p["tipo"] == "WN":
			var g: String = p.get("gruppo", pid)
			if fatti.has(g): continue
			fatti[g] = true
			var parti = gruppo(pid)
			var tutti = parti.all(func(x): return c.has(mappa.posizioni[x]["hex"][0]))
			if tutti: wn += parti.size()
		else:
			if c.has(p["hex"][0]): rin += 1
	for nome in mappa.draws:
		var hh: Array = mappa.draws[nome]
		if easy() and mappa.settore(hh[0]) == "W": continue
		if hh.all(func(h): return c.has(h)): dr += 5
	return {"wn": wn, "rinforzi": rin, "valli": dr, "totale": wn + rin + dr, "soglia": 9 if easy() else 19}

func vittoria_finale() -> void:
	var p = punti_vittoria()
	s["vp"] = p["totale"]
	s["fase"] = "fine_partita"
	if p["totale"] >= p["soglia"]:
		s["fine"] = "vittoria"
		dlog("VITTORIA! Alle 10:00 le Divisioni US tengono %d Punti Vittoria (servono %d): la testa di ponte su Omaha Beach è stabilita." % [p["totale"], p["soglia"]], "finale")
	else:
		s["fine"] = "sconfitta"
		dlog("Sconfitta: alle 10:00 le Divisioni US hanno solo %d Punti Vittoria su %d necessari." % [p["totale"], p["soglia"]], "finale")
	dlog("Posizioni WN controllate: %d, posizioni di rinforzo: %d, valli: %d." % [p["wn"], p["rinforzi"], p["valli"]], "finale")

# ---------------------------------------------------------------- salvataggi
func esporta() -> Dictionary:
	return {"v": 1, "s": s, "rng": rng.state, "seme": rng.seed}

func importa(d: Dictionary) -> void:
	s = d["s"]
	rng.seed = int(d.get("seme", 1))
	rng.state = int(d.get("rng", 1))
	# JSON trasforma i numeri in float: li riporto a interi dove servono
	s["turno"] = int(s["turno"])
	s["navali"] = int(s["navali"])
	for k in ["1", "29"]:
		s["azioni"][k] = int(s["azioni"][k])
	for u in s["us"]:
		for f in ["i", "div", "cmd", "passo", "arrivo", "conf", "eroe"]:
			u[f] = int(u[f])
	for pid in s["de"]:
		var de: Dictionary = s["de"][pid]
		if not de["u"].is_empty(): de["u"]["i"] = int(de["u"]["i"])
		if not de["dm"].is_empty(): de["dm"]["i"] = int(de["dm"]["i"])
	for k in s["pool"]:
		var l: Array = s["pool"][k]
		for i in l.size():
			if l[i] is Array:
				l[i] = [l[i][0], int(l[i][1])]
			else:
				l[i] = int(l[i])
	for k in ["mazzo", "scarti"]:
		s[k] = s[k].map(func(x): return int(x))
	for k in s["eroi"]:
		s["eroi"][k] = s["eroi"][k].map(func(x): return int(x))
	for k in s["carte_turno"]:
		s["carte_turno"][k] = int(s["carte_turno"][k])
