## Motore delle regole di D-Day at Omaha Beach (Decision Games, J. Butterfield).
## Scenari "La prima ondata" (Turni 1-16, regole 1-13) e "Easy Fox" (introduttivo, solo settore Est).
## I tedeschi sono interamente automatici; il giocatore comanda le Divisioni US.
## Tutto lo stato è in dizionari e liste, così si salva come JSON (locale e Firebase).
class_name Gioco
extends RefCounted

signal registro(testo: String, tipo: String)

const SIMBOLI := {"D": "rombo", "T": "triangolo", "C": "cerchio"}
const ORARI := ["", "06:15", "06:30", "06:45", "07:00", "07:15", "07:30", "07:45", "08:00", "08:15", "08:30", "08:45", "09:00", "09:15", "09:30", "09:45", "10:00",
	"10:15", "10:45", "11:15", "11:45", "12:15", "12:45", "13:15", "13:45", "14:15", "14:45", "15:15", "15:45", "16:15", "16:45", "17:15", "17:45"]
## Tracciati del raggio dei Posti di Comando e delle Basi del Genio (valori ripetuti = più turni per crescere)
const TRACCIA_CP := [1, 1, 2, 2, 3, 3, 3, 4]
const TRACCIA_GENIO := [0, 1, 2, 2, 3, 3, 4, 4, 5]
const ARMI_PIENE := ["BZ", "BG", "BR", "DE", "MO", "RD"]
const NOMI_ARMI := {"BZ": "Bazooka", "BG": "Bangalore", "BR": "Fucile Browning", "DE": "Demolizioni", "MO": "Mortaio", "RD": "Radio", "MG": "Mitragliatrice", "AR": "Artiglieria", "NA": "Fuoco navale", "FL": "Aggiramento"}

var mappa: Mappa
var def_unita: Array = []
var def_tedeschi: Dictionary = {}
var carte: Array = []

var s: Dictionary = {}   # stato completo (salvabile)
var rng = RandomNumberGenerator.new()
var log_righe: Array = []

# ---------------------------------------------------------------- caricamento
func _init() -> void:
	mappa = Mappa.new()
	mappa.carica()
	def_unita = _json("res://data/unita.json")
	def_tedeschi = _json("res://data/tedeschi.json")
	carte = _json("res://data/carte.json")

static func _json(p: String):
	var f = FileAccess.open(p, FileAccess.READ)
	return JSON.parse_string(f.get_as_text())

func carta(n: int) -> Dictionary:
	return carte[n - 1]

func dlog(t: String, tipo := "") -> void:
	log_righe.append([t, tipo])
	s["log"].append([s.get("turno", 0), t, tipo])
	if s["log"].size() > 600:
		s["log"] = s["log"].slice(s["log"].size() - 600)
	registro.emit(t, tipo)

# ---------------------------------------------------------------- nuova partita
func nuova(scenario := "prima_ondata", seme := 0) -> void:
	if seme == 0:
		seme = int(Time.get_unix_time_from_system() * 1000) % 2000000000
	rng.seed = seme
	s = {"scenario": scenario, "seme": seme, "turno": 1, "fase": "inizio", "log": [], "us": [], "de": {},
		"pool": {}, "mazzo": [], "scarti": [], "carte_turno": {}, "navali": 0, "bonificati": {}, "fumo": [],
		"flag": {}, "perdite": {"1": [], "29": []}, "eroi": {"1": [0, 1, 2, 3, 4], "29": [0, 1, 2, 3, 4]},
		"azioni": {"1": 2, "29": 2}, "attaccati": {}, "sbarrati": {}, "fine": "", "vp": 0, "razzi_sparati": false,
		"comando": {}, "leader_mossi": {}, "conta_carte": 0, "wn_elim": [], "basi": [], "cp": {}, "guarnigioni": {},
		"usciti": [], "art_settore": {}, "genio_fatto": {}}
	var easy = scenario == "easy_fox"
	# --- unità US
	for i in def_unita.size():
		var d: Dictionary = def_unita[i]
		if easy and (d["div"] != 1 or (d["turno"] > 10)):
			continue
		if scenario == "prima_ondata" and d["turno"] > 16:
			continue
		var u = {"i": i, "id": d["id"], "div": int(d["div"]), "cmd": int(d["div"]), "passo": 0, "dove": "traccia",
			"arrivo": int(d["turno"]), "box": "", "hex": "", "conf": 0, "scalata": "", "eroe": -1, "ispirato": false,
			"ferito": false, "agito": false}
		if d["turno"] == 0:
			u["dove"] = "box"
			u["box"] = d["box"]
		s["us"].append(u)
	# --- tedeschi
	var wn_dm = _mescola(range(def_tedeschi["dm"]["wn"].size()))
	var wn_u = range(def_tedeschi["wn"].size())
	var art88: Array = []
	var art75: Array = []
	var altre: Array = []
	var razzi = -1
	for i in wn_u:
		var c: String = def_tedeschi["wn"][i]["cal"]
		if c == "88": art88.append(i)
		elif c == "75": art75.append(i)
		elif c == "razzi": razzi = i
		else: altre.append(i)
	art88 = _mescola(art88); art75 = _mescola(art75); altre = _mescola(altre)
	var con_dm = ["WN60", "WN61", "WN62N", "WN65N", "WN66N", "WN68N", "WN70", "WN72N", "WN73"]
	var piazza = {}
	if easy:
		con_dm = ["WN60", "WN61", "WN62N", "WN65N"]
		piazza["WN61"] = art88[0]
		var a3 = ["WN60", "WN62S", "WN65S"]
		for k in 3: piazza[a3[k]] = art75[k]
		var n3 = ["WN62N", "WN64", "WN65N"]
		for k in 3: piazza[n3[k]] = altre[k]
	else:
		piazza["WN61"] = art88[0]
		piazza["WN72S"] = art88[1]
		var a6 = ["WN60", "WN62S", "WN65S", "WN68S", "WN70", "WN73"]
		for k in 6: piazza[a6[k]] = art75[k]
		piazza["WN69"] = razzi
		var resto = []
		for id in mappa.posizioni:
			if mappa.posizioni[id]["tipo"] == "WN" and not piazza.has(id):
				resto.append(id)
		resto.sort()
		for k in resto.size(): piazza[resto[k]] = altre[k]
	for id in mappa.posizioni:
		s["de"][id] = {"u": {}, "dm": {}, "conf": false}
	var dmi = 0
	for id in piazza:
		s["de"][id]["u"] = {"k": "wn", "i": piazza[id], "riv": false}
	for id in con_dm:
		s["de"][id]["dm"] = {"p": "wn", "i": wn_dm[dmi], "riv": false}
		dmi += 1
	var resto_dm: Array = wn_dm.slice(dmi)
	if easy:
		resto_dm = resto_dm.slice(0, 4)
	s["pool"]["wn"] = resto_dm
	s["pool"]["T"] = _mescola(range(def_tedeschi["rinforzi"]["T"].size()))
	s["pool"]["D"] = [] if easy else _mescola(range(def_tedeschi["rinforzi"]["D"].size())).map(func(x): return ["D", x])
	s["pool"]["M"] = [] if easy else _mescola(range(def_tedeschi["rinforzi"]["M"].size()))
	var mob = _mescola(range(def_tedeschi["dm"]["mobile"].size()))
	s["pool"]["meyer_dm"] = [] if easy else mob.slice(0, 4)
	s["pool"]["mobile"] = mob.slice(0, 10) if easy else mob.slice(4)
	s["pool"]["edificio"] = _mescola(range(def_tedeschi["dm"]["edificio"].size()))
	# artiglieria fuori mappa
	s["art"] = []
	for a in def_tedeschi["artiglieria"]:
		if easy and a["settore"] == "W":
			continue
		s["art"].append(a.duplicate())
	# carte (la 55 è il riepilogo e non entra nel mazzo)
	s["mazzo"] = _mescola(range(1, 55))
	if scenario == "oltre":
		prepara_oltre()
	dlog("Nuova partita: %s." % nome_scenario(), "titolo")
	inizia_turno()

func nome_scenario() -> String:
	return {"easy_fox": "Easy Fox (introduttivo)", "prima_ondata": "La prima ondata", "dday": "D-Day at Omaha Beach", "oltre": "Oltre la spiaggia"}.get(s["scenario"], "")

## Turni 17-32: regole della modalità estesa (sezioni 14-20)
func estesa() -> bool:
	return s["turno"] >= 17

func easy() -> bool:
	return s["scenario"] == "easy_fox"

func ultimo_turno() -> int:
	return 32 if s["scenario"] in ["dday", "oltre"] else 16

func _mescola(a) -> Array:
	var b: Array = Array(a).duplicate()
	for i in range(b.size() - 1, 0, -1):
		var j = rng.randi_range(0, i)
		var t = b[i]; b[i] = b[j]; b[j] = t
	return b

func pesca() -> int:
	if s["mazzo"].is_empty():
		s["mazzo"] = _mescola(s["scarti"])
		s["scarti"] = []
		dlog("Il mazzo è finito: rimescolo gli scarti.", "info")
	var n: int = s["mazzo"].pop_back()
	s["scarti"].append(n)
	s["conta_carte"] += 1
	return n

# ---------------------------------------------------------------- informazioni
func marea(t := -1) -> String:
	if t < 0: t = s["turno"]
	if t <= 6: return "bassa"
	if t <= 15: return "media"
	if t <= 22: return "alta"
	return "media"

func nome_marea() -> String:
	return {"bassa": "Bassa marea", "media": "Marea media", "alta": "Alta marea"}[marea()]

func defu(u: Dictionary) -> Dictionary:
	return def_unita[u["i"]]

func passo(u: Dictionary) -> Dictionary:
	return defu(u)["passi"][u["passo"]]

func tipo(u: Dictionary) -> String:
	return defu(u)["tipo"]

func leader(u: Dictionary) -> bool:
	return tipo(u) in ["hq", "generale"]

func fanteria(u: Dictionary) -> bool:
	return tipo(u) in ["fanteria", "pesante", "ranger"]

func regolare(u: Dictionary) -> bool:
	return tipo(u) in ["fanteria", "pesante"]

func corazzata(u: Dictionary) -> bool:
	return tipo(u) in ["carro", "artiglieria_sp", "antiaerea_sp"]

func veicolo(u: Dictionary) -> bool:
	return not fanteria(u) and not leader(u)

func passi_rimasti(u: Dictionary) -> int:
	return defu(u)["passi"].size() - u["passo"]

func simbolo(u: Dictionary) -> String:
	return passo(u)["s"]

func attacco(u: Dictionary) -> int:
	return passo(u)["a"]

func gittata(u: Dictionary) -> int:
	return passo(u)["g"]

func unita(uid: String) -> Dictionary:
	for u in s["us"]:
		if u["id"] == uid:
			return u
	return {}

func sulla_mappa() -> Array:
	return s["us"].filter(func(u): return u["dove"] == "mappa")

func unita_in(h: String) -> Array:
	return s["us"].filter(func(u): return u["dove"] == "mappa" and u["hex"] == h)

func combattenti_in(h: String) -> Array:
	return unita_in(h).filter(func(u): return not leader(u))

func passi_hex(h: String) -> int:
	var t = 0
	for u in combattenti_in(h):
		t += passi_rimasti(u)
	return t

func tedesco_in(h: String) -> bool:
	if not mappa.hex_pos.has(h):
		return false
	return not s["de"][mappa.hex_pos[h]]["u"].is_empty()

func pos_di(h: String) -> String:
	return mappa.hex_pos.get(h, "")

func gruppo(pid: String) -> Array:
	var g: String = mappa.posizioni[pid].get("gruppo", "")
	if g == "":
		return [pid]
	var o: Array = []
	for k in mappa.posizioni:
		if mappa.posizioni[k].get("gruppo", "") == g:
			o.append(k)
	o.sort()
	return o

func occupata(pid: String) -> bool:
	return not s["de"][pid]["u"].is_empty()

func def_tedesca(pid: String) -> Dictionary:
	var u: Dictionary = s["de"][pid]["u"]
	if u.is_empty(): return {}
	if u["k"] == "wn": return def_tedeschi["wn"][u["i"]]
	return def_tedeschi["rinforzi"][u["k"]][u["i"]]

func def_dm(pid: String) -> Dictionary:
	var d: Dictionary = s["de"][pid]["dm"]
	if d.is_empty(): return {}
	return def_tedeschi["dm"][d["p"]][d["i"]]

func colore(pid: String) -> String:
	return mappa.posizioni[pid]["col"]

func settore_pos(pid: String) -> String:
	return mappa.settore(mappa.posizioni[pid]["hex"][0])

func nome_pos(pid: String) -> String:
	if pid.begins_with("R"):
		return "posizione " + pid.substr(1)
	return pid

func pos_attive() -> Array:
	var o: Array = []
	for pid in s["de"]:
		if occupata(pid):
			o.append(pid)
	return o

# ---------------------------------------------------------------- turno
func inizia_turno() -> void:
	var t: int = s["turno"]
	dlog("Turno %d - ore %s - %s" % [t, ORARI[t] if t < ORARI.size() else "", nome_marea()], "turno")
	s["fumo"] = []
	s["flag"] = {}
	s["carte_turno"] = {}
	s["azioni"] = {"1": 2, "29": 2}
	s["attaccati"] = {}
	s["sbarrati"] = {}
	s["art_settore"] = {}
	s["genio_fatto"] = {}
	for u in s["us"]:
		u["agito"] = false
		if u["conf"] == 2: u["conf"] = 1
	if t == 24:
		for h in mappa.media_set:
			s["bonificati"][h] = true
		dlog("Tutti gli ostacoli sulla linea di marea media sono demoliti (19.4).", "info")
	fase_anfibia()
	if t > 1:
		fase_evento()
	if s["fine"] != "":
		return
	fase_fuoco()
	if s["fine"] != "":
		return
	if estesa() and t < 32:
		fase_evento()
		if s["fine"] != "":
			return
	if t >= 2:
		fase_genio()
	if estesa():
		fase_genio_hq()
	inizia_azioni()

func inizia_azioni() -> void:
	s["fase"] = "azioni"
	var base_az = 3 if estesa() else 2
	s["azioni"] = {"1": base_az, "29": base_az}
	if s["flag"].get("iniziativa", false):
		s["azioni"] = {"1": base_az + 1, "29": base_az + 1}
	if s["flag"].get("fuoco_intenso", false):
		s["azioni"] = {"1": 1, "29": 1}
	s["comando"] = {}
	s["leader_mossi"] = {}
	for l in sulla_mappa():
		if not leader(l):
			continue
		for u in sulla_mappa():
			if u == l or leader(u): continue
			if u["hex"] == l["hex"] or Mappa.distanza(u["hex"], l["hex"]) == 1:
				if not s["comando"].has(u["id"]):
					s["comando"][u["id"]] = []
				s["comando"][u["id"]].append(l["id"])
	# Posti di Comando (18.3): comandano entro il loro raggio, se non sono sotto il fuoco
	for hq in s["cp"]:
		var l = unita(hq)
		if l.is_empty() or l["dove"] != "mappa": continue
		if in_campo_occupato(l["hex"]): continue
		var r: int = raggio_cp(hq)
		for u in sulla_mappa():
			if u == l or leader(u): continue
			if Mappa.distanza(u["hex"], l["hex"]) <= r:
				if not s["comando"].has(u["id"]):
					s["comando"][u["id"]] = []
				if not hq in s["comando"][u["id"]]:
					s["comando"][u["id"]].append(hq)
	if easy():
		dlog("Fase delle azioni US: %d azioni per la 1ª Divisione." % s["azioni"]["1"], "fase")
	else:
		dlog("Fase delle azioni US: %d azioni per la 1ª Divisione, %d per la 29ª." % [s["azioni"]["1"], s["azioni"]["29"]], "fase")

func fine_azioni() -> void:
	if s["fase"] != "azioni":
		return
	s["fase"] = "fine"
	# limite di raggruppamento (7.63)
	var visti = {}
	for u in sulla_mappa():
		visti[u["hex"]] = true
	for h in visti:
		var c = combattenti_in(h)
		if c.size() > 2:
			c.sort_custom(func(a, b): return passi_rimasti(a) > passi_rimasti(b))
			for k in range(2, c.size()):
				elimina(c[k], "troppe unità nell'esagono %s" % h)
	for u in s["us"]:
		if u["conf"] == 2: u["conf"] = 1
	var t: int = s["turno"]
	# unità che escono dalla mappa sono già registrate; guarnigioni nelle posizioni sicure
	if estesa():
		aggiorna_guarnigioni()
	# marea che sale (5.21)
	if t == 7:
		for u in sulla_mappa():
			if mappa.bassa_set.has(u["hex"]) and u["scalata"] == "":
				elimina(u, "sommersa dalla marea")
	if t == 15:
		for u in sulla_mappa():
			if mappa.media_set.has(u["hex"]) and u["scalata"] == "":
				elimina(u, "sommersa dall'alta marea")
	s["fumo"] = []
	if t in [6, 13]:
		s["mazzo"] = _mescola(s["mazzo"] + s["scarti"])
		s["scarti"] = []
		dlog("Rimescolo il mazzo (Shuffle Cards).", "info")
	controlla_catastrofe()
	if s["fine"] != "":
		return
	if t >= ultimo_turno():
		vittoria_finale()
		return
	if t == 16 and s["scenario"] == "dday":
		controllo_prima_vittoria()
		if s["fine"] != "":
			return
	s["turno"] = t + 1
	inizia_turno()

# ---------------------------------------------------------------- fase anfibia
func box_di_settore(sett: String) -> Array:
	var o: Array = []
	for b in mappa.ordine_box:
		if mappa.box[b]["s"] == sett:
			o.append(b)
	return o

func in_box(b: String) -> Array:
	return s["us"].filter(func(u): return u["dove"] == "box" and u["box"] == b)

func fase_anfibia() -> void:
	s["fase"] = "anfibia"
	var t: int = s["turno"]
	for sett in ["E", "W"]:
		if easy() and sett == "W":
			continue
		var da_controllare: Array = []
		for b in box_di_settore(sett):
			for u in in_box(b):
				if not leader(u) and _richiede_controllo(u, t):
					da_controllare.append(u)
		var mina = false
		if not da_controllare.is_empty() or (t >= 7 and t <= 22):
			var n = pesca()
			s["carte_turno"]["sbarco_" + sett] = n
			var c = carta(n)
			mina = c["mina"] and t >= 7 and t <= 22
			dlog("Carta sbarco settore %s: n.%d (rombo %s, triangolo %s, cerchio %s)%s" % [_nome_sett(sett), n, c["sbarco"]["D"], c["sbarco"]["T"], c["sbarco"]["C"], ", mine!" if c["mina"] else ""], "carta")
			for u in da_controllare:
				_esito_sbarco(u, c["sbarco"][simbolo(u)], t)
		# sbarco sulla spiaggia
		var sbarcati: Array = []
		for b in box_di_settore(sett):
			for u in in_box(b):
				var h = hex_sbarco(b, marea())
				if h == "":
					ritarda(u, 2, "nessuna spiaggia per la marea attuale")
					continue
				u["dove"] = "mappa"
				u["hex"] = h
				u["box"] = ""
				if mappa.settore(h) != ("E" if u["div"] == 1 else "W"):
					var nd: int = 29 if mappa.settore(h) == "W" else 1
					if u["cmd"] != nd:
						u["cmd"] = nd
						dlog("%s sbarca nel settore dell'altra Divisione e passa al suo comando." % u["id"], "info")
				sbarcati.append(u)
		if not sbarcati.is_empty():
			dlog("Sbarcano nel settore %s: %s." % [_nome_sett(sett), ", ".join(sbarcati.map(func(u): return "%s (%s)" % [u["id"], u["hex"]]))], "sbarco")
		if mina:
			var colpiti: Array = sbarcati.filter(func(u): return mappa.media_set.has(u["hex"]) and not s["bonificati"].has(u["hex"]))
			if not colpiti.is_empty():
				var non_l = colpiti.filter(func(u): return not leader(u))
				if non_l.is_empty():
					var hq = colpiti.filter(func(u): return tipo(u) == "hq")
					if not hq.is_empty():
						ritarda(hq[0], 2, "mina: il comando deve riorganizzarsi")
				else:
					non_l.sort_custom(func(a, b): return passi_rimasti(a) > passi_rimasti(b))
					dlog("Esplode una mina sommersa!", "danno")
					perdi_passo(non_l[0], "mina")
	# nuove unità ai riquadri di sbarco
	for u in s["us"]:
		if u["dove"] == "traccia" and u["arrivo"] <= t:
			metti_in_box(u)

func _nome_sett(x: String) -> String:
	return "Est" if x == "E" else "Ovest"

func _richiede_controllo(u: Dictionary, t: int) -> bool:
	var tp = tipo(u)
	if tp in ["fanteria", "pesante", "ranger"] and t >= 15:
		return false
	return true

func _esito_sbarco(u: Dictionary, lettera: String, t: int) -> void:
	var tp = tipo(u)
	var b: String = u["box"]
	var dg = b.begins_with("DG") or b.begins_with("CH")
	var e = ""
	if t <= 3 and tp == "carro":
		if t == 1:
			e = {"A": "ritardo_t2", "B": "eliminata", "C": "perde1", "D": "perde1_est2"}[lettera]
		else:
			e = {"A": "", "B": "est1", "C": "perde1", "D": "est3"}[lettera]
	elif tp in ["fanteria", "pesante", "ranger"]:
		if t <= 3 and not dg:
			e = {"A": "est4", "B": "est2", "C": "est9", "D": ""}[lettera]
		else:
			e = {"A": "", "B": "est1", "C": "est4", "D": "ovest1"}[lettera]
	elif tp == "artiglieria" and defu(u)["id"] in ["7FA", "111FA", "Can/16", "Can/116"]:
		e = {"A": "eliminata", "B": "perde1", "C": "perde2", "D": ""}[lettera]
	else:
		if t <= 14:
			e = {"A": "ritardo3", "B": "est2", "C": "perde1", "D": ""}[lettera]
		else:
			e = {"A": "ritardo3", "B": "rimossa", "C": "", "D": "perde1"}[lettera]
	match e:
		"":
			pass
		"ritardo_t2":
			ritarda(u, 1, "sbarco ritardato")
		"ritardo3":
			ritarda(u, 3, "sbarco ritardato")
		"eliminata":
			elimina(u, "affondata durante lo sbarco")
		"rimossa":
			u["dove"] = "rimossa"
			dlog("%s ritardata al 7 giugno: esce dal gioco." % u["id"], "danno")
		"perde1":
			perdi_passo(u, "sbarco")
		"perde2":
			perdi_passo(u, "sbarco")
			if u["dove"] != "eliminata": perdi_passo(u, "sbarco")
		"perde1_est2":
			perdi_passo(u, "sbarco")
			if u["dove"] == "box": deriva(u, -2)
		"est1": deriva(u, -1)
		"est2": deriva(u, -2)
		"est3": deriva(u, -3)
		"est4": deriva(u, -4)
		"est9": deriva(u, -9)
		"ovest1": deriva(u, 1)

## Deriva lungo la fila dei riquadri: negativo = verso est (a sinistra sulla mappa).
func deriva(u: Dictionary, n: int) -> void:
	var o: Array = mappa.ordine_box
	var i = o.find(u["box"])
	var j = i + n
	if j < 0 or j >= o.size():
		ritarda(u, 2, "deriva fuori dalla fila dei riquadri")
		return
	var nb: String = o[j]
	if marea() == "alta" and not mappa.box[nb].has("alta"):
		ritarda(u, 2, "deriva davanti a una costa senza spiaggia di alta marea")
		return
	dlog("%s deriva di %d riquadri verso %s: da %s a %s." % [u["id"], abs(n), "est" if n < 0 else "ovest", u["box"], nome_box(nb)], "sbarco")
	u["box"] = nb

func nome_box(b: String) -> String:
	return "riquadro senza nome" if b.begins_with("X") else b

func hex_sbarco(b: String, m: String) -> String:
	var d: Dictionary = mappa.box[b]
	if d.has(m):
		var h: String = d[m]
		if tedesco_in(h):
			return ""
		return h
	return ""

func ritarda(u: Dictionary, n: int, motivo: String) -> void:
	u["dove"] = "traccia"
	u["arrivo"] = s["turno"] + n
	u["box"] = ""
	dlog("%s in ritardo (%s): arriverà al turno %d." % [u["id"], motivo, u["arrivo"]], "sbarco")
	if u["arrivo"] > ultimo_turno():
		u["dove"] = "rimossa"

func metti_in_box(u: Dictionary) -> void:
	var d = defu(u)
	var spec: String = d["box"]
	var scelte: Array = []
	if u["arrivo"] > 10 and u["arrivo"] != d["turno"]:
		spec = str(u["div"])
	if mappa.box.has(spec) and u["arrivo"] <= 10:
		scelte = [spec]
	elif spec == "1" or spec == "29":
		var sett = "E" if spec == "1" else "W"
		scelte = box_di_settore(sett).filter(func(b): return not b.begins_with("X") and not b.begins_with("CH"))
	else:
		var pref = spec.substr(0, 2)
		scelte = mappa.ordine_box.filter(func(b): return b.begins_with(pref))
		if scelte.is_empty():
			scelte = box_di_settore("E" if u["div"] == 1 else "W").filter(func(b): return not b.begins_with("X"))
	if easy():
		scelte = scelte.filter(func(b): return mappa.box[b]["s"] == "E")
		if scelte.is_empty():
			scelte = box_di_settore("E").filter(func(b): return not b.begins_with("X"))
	# il riquadro meno affollato (al massimo due unità, leader esclusi)
	var migliore = ""
	var bc = 99
	for b in scelte:
		var n = in_box(b).filter(func(x): return not leader(x)).size()
		if leader(u) and n == 0 and scelte.size() > 1:
			n = 5
		if n < bc:
			bc = n
			migliore = b
	u["dove"] = "box"
	u["box"] = migliore
	u["hex"] = ""

# ---------------------------------------------------------------- perdite
func perdi_passo(u: Dictionary, motivo := "") -> void:
	if u["dove"] == "eliminata":
		return
	var tot: int = defu(u)["passi"].size()
	if u["passo"] + 1 >= tot:
		if u["eroe"] >= 0 and not u["ispirato"]:
			u["ispirato"] = true
			dlog("L'eroe di %s si sacrifica per salvare l'unità (ora è Ispirata)." % u["id"], "eroe")
			return
		elimina(u, motivo)
		return
	u["passo"] += 1
	dlog("%s perde un punto forza (%s): ora ha %d %s." % [u["id"], motivo, passi_rimasti(u), "punto" if passi_rimasti(u) == 1 else "punti"], "danno")
	if regolare(u) and passi_rimasti(u) == 1:
		_conta_perdita(u)

func _conta_perdita(u: Dictionary) -> void:
	var k = str(u["div"])
	if not s["perdite"][k].has(u["id"]):
		s["perdite"][k].append(u["id"])

func elimina(u: Dictionary, motivo := "") -> void:
	if u["dove"] == "eliminata":
		return
	u["dove"] = "eliminata"
	dlog("%s eliminata (%s)." % [u["id"], motivo], "danno")
	if regolare(u):
		_conta_perdita(u)

func controlla_catastrofe() -> void:
	for k in ["1", "29"]:
		if easy() and k == "29": continue
		if s["perdite"][k].size() >= (14 if estesa() else 8):
			s["fine"] = "sconfitta"
			s["fase"] = "fine_partita"
			dlog("SCONFITTA CATASTROFICA: la %s Divisione ha perso otto compagnie di fanteria. Il comando chiude la spiaggia agli sbarchi." % ("1ª" if k == "1" else "29ª"), "finale")

# ---------------------------------------------------------------- eventi
func fase_evento() -> void:
	s["fase"] = "evento"
	var n = pesca()
	s["carte_turno"]["evento"] = n
	var t: int = s["turno"]
	for e in carta(n)["eventi"]:
		if t >= e["da"] and t <= e["a"]:
			dlog("Evento (carta %d): %s" % [n, e["testo"]], "evento")
			esegui_evento(e["cod"], e["par"])
			return

func esegui_evento(cod: String, par) -> void:
	match cod:
		"RINF", "CRISI", "PIANI":
			var zone: Array = par
			if easy():
				zone = zone.filter(func(z): return not z in ["E", "F", "G"])
			for z in zone:
				rinforzo_zona(z)
		"TOGLI_CONF":
			for pid in s["de"]:
				s["de"][pid]["conf"] = false
		"PIOMBANTE":
			s["flag"]["piombante"] = true
		"NAVALE":
			s["navali"] += 1
			dlog("Ricevi un segnalino Fuoco Navale (ne hai %d)." % s["navali"], "info")
			if par != null:
				for z in par:
					if not (easy() and z in ["E", "F", "G"]):
						rinforzo_zona(z)
		"FUMO":
			for w in par:
				var num: int = int(w.substr(2))
				if easy() and num >= 66: continue
				s["fumo"].append(w)
		"RINFORZA_US":
			rinforza_us(int(par))
		"RAZZI":
			razzi()
		"EROE":
			var div: int = par[0]
			if easy() and div == 29:
				return
			var sett = eroe(div)
			if par[1] == 1:
				aggiungi_dm(sett if sett != "" else "")
		"INIZIATIVA":
			s["flag"]["iniziativa"] = true
		"GENIO_BLOCCATO":
			s["flag"]["genio_bloccato"] = true
		"DM":
			aggiungi_dm("")
		"DM_SETTORI":
			if easy():
				aggiungi_dm("")
			else:
				aggiungi_dm("E")
				aggiungi_dm("W")
		"MEYER":
			if easy(): return
			for k in 4:
				if s["pool"]["M"].is_empty(): break
				var i: int = s["pool"]["M"].pop_back()
				s["pool"]["D"].append(["M", i])
			s["pool"]["D"] = _mescola(s["pool"]["D"])
			dlog("Il Kampfgruppe Meyer viene dirottato su Omaha Beach.", "info")
		"RAZZI_DISTRUTTI":
			if s["razzi_sparati"] and s["de"].has("WN69") and occupata("WN69"):
				s["de"]["WN69"]["u"] = {}
				s["de"]["WN69"]["dm"] = {}
				dlog("Il fuoco navale distrugge i lanciarazzi di WN69.", "info")
		"PATTUGLIA":
			pattuglia(int(par))
		"PRIGIONIERO":
			prigioniero(int(par))
		"FUOCO_INTENSO":
			s["flag"]["fuoco_intenso"] = true
		"NAVALE_INATTESO":
			navale_inatteso(par)
		"CECCHINI":
			s["flag"]["cecchini"] = true
		"NASCOSTI":
			tedeschi_nascosti(par)
		_:
			dlog("(Evento della modalità estesa: nessun effetto nei turni 1-16.)", "info")

func rinforza_us(div: int) -> void:
	var cand: Array = []
	for d in [div, 29 if div == 1 else 1]:
		cand = sulla_mappa().filter(func(u): return u["div"] == d and regolare(u) and passi_rimasti(u) == 1)
		if not cand.is_empty(): break
	if cand.is_empty():
		dlog("Nessuna fanteria con un solo punto forza: l'evento non ha effetto.", "info")
		return
	var u: Dictionary = cand[0]
	u["passo"] -= 1
	s["perdite"][str(u["div"])].erase(u["id"])
	dlog("%s riceve rinforzi e torna a 2 punti forza." % u["id"], "info")

func razzi() -> void:
	if not s["de"].has("WN69") or not occupata("WN69") or s["de"]["WN69"]["conf"]:
		dlog("I lanciarazzi di WN69 non sono in grado di sparare.", "info")
		return
	var u69: Dictionary = s["de"]["WN69"]["u"]
	if u69["k"] != "wn" or def_tedeschi["wn"][u69["i"]]["cal"] != "razzi":
		return
	s["razzi_sparati"] = true
	var cand = sulla_mappa().filter(func(u): return not leader(u) and mappa.basso(u["hex"]) and Mappa.distanza(u["hex"], "1222") >= 3 and Mappa.distanza(u["hex"], "1222") <= 7)
	if cand.is_empty():
		dlog("I razzi cadono senza colpire nessuno.", "info")
		return
	cand.sort_custom(func(a, b): return passi_rimasti(a) > passi_rimasti(b))
	perdi_passo(cand[0], "razzi Nebelwerfer")

func eroe(div: int) -> String:
	var k = str(div)
	if s["eroi"][k].is_empty():
		return ""
	var cand = sulla_mappa().filter(func(u): return u["div"] == div and fanteria(u) and u["eroe"] < 0)
	if cand.is_empty():
		cand = s["us"].filter(func(u): return u["div"] == div and u["dove"] in ["box", "mappa"] and not leader(u) and u["eroe"] < 0)
	if cand.is_empty():
		return ""
	# l'unità più forte vicina a una posizione tedesca
	cand.sort_custom(func(a, b): return _valore_eroe(a) > _valore_eroe(b))
	var u: Dictionary = cand[0]
	u["eroe"] = s["eroi"][k].pop_front()
	dlog("Un eroe si distingue con %s." % u["id"], "eroe")
	return mappa.settore(u["hex"]) if u["dove"] == "mappa" else ("E" if div == 1 else "W")

func _valore_eroe(u: Dictionary) -> float:
	var v = float(passi_rimasti(u)) * 2.0 + attacco(u) * 0.3
	if u["dove"] == "mappa":
		var dmin = 99
		for pid in pos_attive():
			for h in mappa.posizioni[pid]["hex"]:
				dmin = min(dmin, Mappa.distanza(u["hex"], h))
		v += 10.0 - dmin
	return v

func pattuglia(div: int) -> void:
	var best = ""
	var bd = 99
	for pid in pos_attive():
		var de: Dictionary = s["de"][pid]
		if de["u"]["riv"] and (de["dm"].is_empty() or de["dm"]["riv"]):
			continue
		for u in sulla_mappa():
			if u["div"] != div: continue
			var d = Mappa.distanza(u["hex"], mappa.posizioni[pid]["hex"][0])
			if d < bd:
				bd = d; best = pid
	if best != "":
		rivela_tutto(best)

func prigioniero(div: int) -> void:
	var sett = "E" if div == 1 else "W"
	var lista = pos_attive().filter(func(p): return not s["de"][p]["u"]["riv"] or (not s["de"][p]["dm"].is_empty() and not s["de"][p]["dm"]["riv"]))
	var nel = lista.filter(func(p): return settore_pos(p) == sett)
	if nel.is_empty(): nel = lista
	if nel.is_empty(): return
	nel.sort_custom(func(a, b): return _dist_us(a) < _dist_us(b))
	rivela_tutto(nel[0])

func rivela_tutto(pid: String) -> void:
	var de: Dictionary = s["de"][pid]
	de["u"]["riv"] = true
	dlog("Rivelata %s: %s." % [nome_pos(pid), descrivi_tedesco(pid)], "info")
	if not de["dm"].is_empty():
		de["dm"]["riv"] = true
		if def_dm(pid).get("tattico", false):
			de["dm"] = {}
			dlog("Il segnalino Incognita di %s chiama un rinforzo tattico." % nome_pos(pid), "info")
			rinforzo_da_wn(pid, true)

func descrivi_tedesco(pid: String) -> String:
	var d = def_tedesca(pid)
	if d.is_empty(): return "vuota"
	var t = "forza %d, armi richieste %s" % [d["forza"], ", ".join(d["armi"]) if not d["armi"].is_empty() else "nessuna"]
	return t

# ---------------------------------------------------------------- rinforzi e segnalini incognita
func _dist_us(pid: String) -> int:
	var dmin = 99
	for u in sulla_mappa():
		if leader(u): continue
		for h in mappa.posizioni[pid]["hex"]:
			dmin = min(dmin, Mappa.distanza(u["hex"], h))
	return dmin

func _pesca_rinforzo(divisionale_ok := true) -> Array:
	if not s["pool"]["T"].is_empty():
		return ["T", s["pool"]["T"].pop_back()]
	if divisionale_ok and not s["pool"]["D"].is_empty():
		return s["pool"]["D"].pop_back()
	return []

func _dm_per(pid: String) -> Dictionary:
	var u: Dictionary = s["de"][pid]["u"]
	if u.is_empty(): return {}
	var pool = "mobile"
	if u["k"] == "wn":
		pool = "wn"
	elif mappa.posizioni[pid].get("ed", 0) == 1:
		pool = "edificio"
	if pool == "edificio" and s["pool"]["edificio"].is_empty():
		pool = "mobile"
	if s["pool"][pool].is_empty():
		return {}
	return {"p": pool, "i": s["pool"][pool].pop_back(), "riv": false}

func rinforzo_zona(z: String) -> void:
	var cand: Array = []
	for pid in mappa.posizioni:
		var p: Dictionary = mappa.posizioni[pid]
		if p["tipo"] != "R" or p["zona"] != z: continue
		if occupata(pid): continue
		if not in_comunicazione(pid): continue
		cand.append(pid)
	if cand.is_empty():
		dlog("Nessuna posizione della zona %s può ricevere rinforzi." % z, "info")
		return
	var scelta = ""
	for crit in [1, 2, 99]:
		var ok = cand.filter(func(pid): return _dist_us(pid) <= crit)
		if not ok.is_empty():
			ok.sort_custom(func(a, b): return mappa.posizioni[a]["prio"] < mappa.posizioni[b]["prio"])
			scelta = ok[0]
			break
	var r = _pesca_rinforzo()
	if r.is_empty():
		dlog("I rinforzi tedeschi sono esauriti.", "info")
		return
	piazza_rinforzo(scelta, r, r[0] != "T", false)

func piazza_rinforzo(pid: String, r: Array, con_dm: bool, rivelato: bool) -> void:
	var h: String = mappa.posizioni[pid]["hex"][0]
	for u in unita_in(h):
		if tipo(u) == "generale":
			elimina(u, "catturato dai tedeschi")
	s["de"][pid] = {"u": {"k": r[0], "i": r[1], "riv": rivelato}, "dm": {}, "conf": false}
	if con_dm:
		s["de"][pid]["dm"] = _dm_per(pid)
	dlog("Rinforzo tedesco nella %s (%s)%s." % [nome_pos(pid), h, " con segnalino Incognita" if not s["de"][pid]["dm"].is_empty() else ""], "tedesco")

func rinforzo_da_wn(wn_pid: String, rivelato := false) -> void:
	if s["pool"]["T"].is_empty():
		dlog("Niente rinforzi tattici disponibili.", "info")
		return
	var base: String = mappa.posizioni[wn_pid]["hex"][0]
	var cand: Array = []
	for pid in mappa.posizioni:
		var p: Dictionary = mappa.posizioni[pid]
		if p["tipo"] != "R" or occupata(pid): continue
		if easy() and p["zona"] in ["E", "F", "G"]: continue
		if not in_comunicazione(pid): continue
		cand.append(pid)
	if cand.is_empty():
		return
	cand.sort_custom(func(a, b):
		var da = Mappa.distanza(base, mappa.posizioni[a]["hex"][0])
		var db = Mappa.distanza(base, mappa.posizioni[b]["hex"][0])
		if da != db: return da < db
		var ua = _dist_us(a); var ub := _dist_us(b)
		if ua != ub: return ua < ub
		return mappa.posizioni[a]["prio"] < mappa.posizioni[b]["prio"])
	piazza_rinforzo(cand[0], ["T", s["pool"]["T"].pop_back()], false, rivelato)

func aggiungi_dm(sett: String) -> void:
	var cand: Array = []
	for pid in pos_attive():
		if not s["de"][pid]["dm"].is_empty(): continue
		if sett != "" and settore_pos(pid) != sett: continue
		if not in_comunicazione(pid): continue
		cand.append(pid)
	if cand.is_empty() and sett != "":
		aggiungi_dm("")
		return
	cand.sort_custom(func(a, b):
		var da = _dist_us(a); var db := _dist_us(b)
		if da != db: return da < db
		var ta = _ordine_tipo(a); var tb := _ordine_tipo(b)
		if ta != tb: return ta < tb
		return _num_id(a) < _num_id(b))
	for pid in cand:
		var u: Dictionary = s["de"][pid]["u"]
		if u["k"] == "wn" and s["pool"]["wn"].is_empty():
			continue
		var dm = _dm_per(pid)
		if dm.is_empty():
			continue
		s["de"][pid]["dm"] = dm
		dlog("La %s riceve un segnalino Incognita." % nome_pos(pid), "tedesco")
		return
	dlog("Nessuna unità tedesca può ricevere un segnalino Incognita.", "info")

func _ordine_tipo(pid: String) -> int:
	var p: Dictionary = mappa.posizioni[pid]
	if p["tipo"] == "WN":
		return 1 if p.get("gruppo", "") != "" else 0
	return 2

func _num_id(pid: String) -> float:
	var p: Dictionary = mappa.posizioni[pid]
	if p["tipo"] == "WN":
		return float(int(pid.substr(2, 2)))
	return float(p["prio"]) + (p["zona"].unicode_at(0) / 1000.0 if p["zona"] != "" else 0.0)

# ---------------------------------------------------------------- controllo e comunicazioni
func controllo() -> Dictionary:
	# esagono -> lista di unità US che lo controllano
	var c = {}
	for u in sulla_mappa():
		if tipo(u) == "generale": continue
		var h: String = u["hex"]
		if not c.has(h): c[h] = []
		c[h].append(u)
		if passo(u)["n"] == 1 and not leader(u):
			for v in mappa.vicini(h):
				if mappa.basso(h) and mappa.alto(v):
					continue
				if not c.has(v): c[v] = []
				c[v].append(u)
	return c

func in_comunicazione(pid: String, ctrl = null) -> bool:
	if ctrl == null:
		ctrl = controllo()
	var occ_us = {}
	for u in sulla_mappa():
		if tipo(u) != "generale":
			occ_us[u["hex"]] = true
	var ted = {}
	for p in pos_attive():
		for h in mappa.posizioni[p]["hex"]:
			if tedesco_in(h): ted[h] = true
	var bloccato = func(h: String) -> bool:
		if occ_us.has(h): return true
		if ctrl.has(h):
			for u in ctrl[h]:
				var annullato = false
				for v in mappa.vicini(u["hex"]):
					if ted.has(v): annullato = true
				if not annullato and u["hex"] != h:
					return true
		return false
	var start: Array = mappa.posizioni[pid]["hex"]
	if not occupata(pid) and start.any(func(x): return occ_us.has(x)):
		return false
	var coda: Array = start.duplicate()
	var visti = {}
	for h in coda: visti[h] = true
	var occupata_r: bool = occupata(pid) and mappa.posizioni[pid]["tipo"] == "R"
	while not coda.is_empty():
		var h: String = coda.pop_front()
		if mappa.esagoni.has(h) and mappa.esagoni[h].has("uscita"):
			return true
		for v in mappa.vicini(h):
			if visti.has(v): continue
			var t = mappa.terreno(v)
			if t in ["spiaggia", "accidentato"]: continue
			if t == "pianoro" and mappa.vicini(v).any(func(x): return mappa.spiaggia(x)): continue
			if bloccato.call(v):
				if not (occupata_r and h in start and t == "bocage" and not occ_us.has(v)):
					continue
			visti[v] = true
			coda.append(v)
	return false

# ---------------------------------------------------------------- fuoco tedesco
func fase_fuoco() -> void:
	s["fase"] = "fuoco"
	for sett in ["E", "W"]:
		if easy() and sett == "W": continue
		var n = pesca()
		s["carte_turno"]["fuoco_" + sett] = n
		var c = carta(n)
		dlog("Carta fuoco settore %s: n.%d - colori %s, simbolo %s." % [_nome_sett(sett), n, ", ".join(c["fuoco"].map(func(q): return q["col"] + (" (doppio)" if q["doppio"] else ""))), SIMBOLI[c["bersaglio"]]], "carta")
		if estesa():
			azioni_tedesche(sett, c)
		else:
			fuoco_settore(sett, c)
		if s["turno"] >= 4 and c["art"] != null:
			artiglieria(sett, c)
		# tolgo la confusione alle posizioni dei colori pescati (6.4)
		var cols: Array = c["fuoco"].map(func(q): return q["col"])
		for pid in s["de"]:
			if s["de"][pid]["conf"] and settore_pos(pid) == sett and colore(pid) in cols:
				s["de"][pid]["conf"] = false
				dlog("La %s si riorganizza (tolta la confusione)." % nome_pos(pid), "tedesco")
	s["flag"].erase("piombante")
	controlla_catastrofe()

func _quadrato(c: Dictionary, col: String) -> Dictionary:
	for q in c["fuoco"]:
		if q["col"] == col: return q
	return {}

func _fumo(pid: String) -> bool:
	for w in s["fumo"]:
		if pid.begins_with(w): return true
	return false

## Restituisce i gruppi di fuoco del settore: [{pid principale, parti[], limite, colonna}]
func posizioni_che_sparano(sett: String, c: Dictionary) -> Array:
	var o: Array = []
	var fatti = {}
	for pid in mappa.posizioni:
		if fatti.has(pid): continue
		var g = gruppo(pid)
		for x in g: fatti[x] = true
		if settore_pos(pid) != sett: continue
		var q = _quadrato(c, colore(pid))
		if q.is_empty(): continue
		if _fumo(pid): continue
		var limite = 0
		var dm = false
		var occ = false
		var rivelata = true
		for x in g:
			var de: Dictionary = s["de"][x]
			if de["u"].is_empty(): continue
			occ = true
			if not de["dm"].is_empty(): dm = true
			if de["conf"]: continue
			limite += 1 + (0 if de["dm"].is_empty() else 1)
			if mappa.posizioni[x]["tipo"] == "R" and not de["u"]["riv"]:
				rivelata = false
		if not occ or limite == 0: continue
		if q["doppio"] and not dm: continue
		if estesa(): limite *= 2
		o.append({"pid": pid, "parti": g, "limite": limite, "nascosta": not rivelata, "q": q})
	return o

func fuoco_settore(sett: String, c: Dictionary) -> void:
	var gia_passo = {}
	var colpi = 0
	for f in posizioni_che_sparano(sett, c):
		colpi += fuoco_pos(f, c, gia_passo)
	if colpi == 0:
		dlog("Il fuoco tedesco nel settore %s non colpisce nessuno." % _nome_sett(sett), "info")

## Fuoco di una posizione (6.3). Restituisce il numero di unità colpite.
func fuoco_pos(f: Dictionary, c: Dictionary, gia_passo: Dictionary) -> int:
	var colpi = 0
	if true:
			var campo = mappa.campo(f["pid"])
			var q: Dictionary = f["q"]
			var cand: Array = []
			for h in campo:
				var liv: int = campo[h]
				if liv == 1 and s["flag"].get("piombante", false) and mappa.protezione.has(h):
					liv = 2
				var conc = passi_hex(h) >= 5
				for u in combattenti_in(h):
					var sim_ok: bool = conc or simbolo(u) == c["bersaglio"]
					var cor: bool = corazzata(u) and not q["carri"]
					var eff = ""
					if liv == 3:
						eff = "passo_conf" if f["nascosta"] else "passo"
					elif liv == 2:
						if not cor and sim_ok:
							eff = "passo_conf" if f["nascosta"] else "passo"
					else:
						if not cor and sim_ok:
							eff = "conf"
					if eff != "":
						cand.append({"u": u, "liv": liv, "d": Mappa.distanza(h, mappa.posizioni[f["pid"]]["hex"][0]), "eff": eff})
			cand.sort_custom(func(a, b):
				if a["liv"] != b["liv"]: return a["liv"] > b["liv"]
				var pa: bool = gia_passo.has(a["u"]["id"]) and a["eff"] != "conf"
				var pb: bool = gia_passo.has(b["u"]["id"]) and b["eff"] != "conf"
				if pa != pb: return pb
				if a["d"] != b["d"]: return a["d"] < b["d"]
				return passi_rimasti(a["u"]) > passi_rimasti(b["u"]))
			var resto: int = f["limite"]
			var colpite: Array = []
			for k in cand:
				if resto <= 0: break
				var u: Dictionary = k["u"]
				if u["dove"] != "mappa": continue
				var e: String = k["eff"]
				if e.begins_with("passo") and gia_passo.has(u["id"]):
					if e == "passo_conf":
						e = "conf"
					else:
						continue
				resto -= 1
				colpite.append(u["id"])
				if e.begins_with("passo"):
					gia_passo[u["id"]] = true
					perdi_passo(u, "fuoco da %s" % nome_pos(f["pid"]))
				if e.ends_with("conf") and u["dove"] == "mappa":
					if u["conf"] == 0:
						u["conf"] = 1
						dlog("%s in confusione (fuoco da %s)." % [u["id"], nome_pos(f["pid"])], "danno")
				colpi += 1
			# leader (11.4)
			if q["stella"] and resto > 0:
				for h in campo:
					if campo[h] < 2: continue
					var fatto = false
					for u in unita_in(h):
						if leader(u):
							colpisci_leader(u)
							fatto = true
							break
						if u["eroe"] >= 0 and not u["ispirato"]:
							u["ispirato"] = true
							dlog("L'eroe di %s cade sotto il fuoco: l'unità diventa Ispirata." % u["id"], "eroe")
							fatto = true
							break
					if fatto: break
	return colpi

func colpisci_leader(u: Dictionary) -> void:
	if tipo(u) == "hq":
		dlog("Il comando %s è colpito e deve riorganizzarsi: rientrerà fra due turni." % u["id"], "danno")
		ritarda(u, 2, "comando colpito")
	else:
		if u["ferito"]:
			elimina(u, "il generale è ucciso")
		else:
			u["ferito"] = true
			dlog("%s è ferito leggermente." % u["id"], "danno")

func artiglieria_attiva(sett: String, cal: Array) -> int:
	var n = 0
	for pid in pos_attive():
		if settore_pos(pid) != sett or s["de"][pid]["conf"]: continue
		var u: Dictionary = s["de"][pid]["u"]
		if u["k"] != "wn": continue
		var c: String = def_tedeschi["wn"][u["i"]]["cal"]
		if c in cal: n += 1
	for a in s["art"]:
		if a["settore"] == sett and a["cal"] in cal and art_fuori_attiva(a):
			n += 1
	return n

func art_fuori_attiva(a: Dictionary) -> bool:
	var ctrl = controllo()
	for o in a["oss"]:
		for pid in mappa.posizioni:
			if pid == o or mappa.posizioni[pid].get("gruppo", "") == o:
				if occupata(pid): return true
				var h: String = mappa.posizioni[pid]["hex"][0]
				if not ctrl.has(h): return true
	return false

func artiglieria(sett: String, c: Dictionary) -> void:
	var a: Dictionary = c["art"]
	var n = artiglieria_attiva(sett, a["cal"])
	if n < a["n"]:
		dlog("Artiglieria tedesca: %d pezzi utili su %d richiesti, nessun colpo." % [n, a["n"]], "info")
		return
	var sim: String = c["bersaglio"]
	var gruppi = [[], [], [], []]
	for u in s["us"]:
		if leader(u) or simbolo(u) != sim: continue
		var in_b: bool = u["dove"] == "box" and mappa.box[u["box"]]["s"] == sett
		var in_sp: bool = u["dove"] == "mappa" and mappa.spiaggia(u["hex"]) and mappa.settore(u["hex"]) == sett
		if in_b and fanteria(u): gruppi[0].append(u)
		elif in_sp and not fanteria(u): gruppi[1].append(u)
		elif in_b: gruppi[2].append(u)
		elif in_sp: gruppi[3].append(u)
	for g in gruppi:
		if g.is_empty(): continue
		g.sort_custom(func(x, y): return passi_rimasti(x) > passi_rimasti(y))
		dlog("L'artiglieria tedesca colpisce!", "danno")
		s["art_settore"][sett] = true
		perdi_passo(g[0], "artiglieria")
		return
	dlog("L'artiglieria tedesca non trova bersagli con il simbolo %s." % SIMBOLI[sim], "info")

# ---------------------------------------------------------------- genio
func fase_genio() -> void:
	s["fase"] = "genio"
	var t: int = s["turno"]
	if t > 15 or s["flag"].get("genio_bloccato", false):
		if s["flag"].get("genio_bloccato", false):
			dlog("Il Genio non può operare in questo turno.", "info")
		return
	var max_n = 2 if t <= 6 else 1
	for sett in ["E", "W"]:
		if easy() and sett == "W": continue
		var key = "fuoco_" + sett
		if not s["carte_turno"].has(key): continue
		var c = carta(s["carte_turno"][key])
		var cols: Array = c["fuoco"].map(func(q): return q["col"])
		var sotto = {}
		for pid in pos_attive():
			if s["de"][pid]["conf"] or not colore(pid) in cols: continue
			for h in mappa.campo(pid):
				sotto[h] = true
		var cand: Array = []
		for h in mappa.esagoni:
			var e: Dictionary = mappa.esagoni[h]
			if e.get("ost", 0) == 1 and e["s"] == sett and not s["bonificati"].has(h) and not sotto.has(h):
				cand.append(h)
		cand.sort_custom(func(a, b): return int(mappa.media_set.has(a)) > int(mappa.media_set.has(b)) or (mappa.media_set.has(a) == mappa.media_set.has(b) and a < b))
		var fatti: Array = cand.slice(0, max_n)
		for h in fatti:
			s["bonificati"][h] = true
		if not fatti.is_empty():
			dlog("Il Genio bonifica gli ostacoli in %s." % ", ".join(fatti), "info")

# ridefinita in Partita
func vittoria_finale() -> void:
	pass

func controllo_prima_vittoria() -> void:
	pass


# ================================================================ modalità estesa (turni 17-32)
func in_campo_occupato(h: String) -> bool:
	for pid in pos_attive():
		if mappa.campo(pid).has(h): return true
	return false

## Campo di fuoco potenziale: occupate oppure vuote ma in comunicazione (19.1)
func in_campo_potenziale(h: String) -> bool:
	for pid in mappa.posizioni:
		if not mappa.campo(pid).has(h): continue
		if occupata(pid) or in_comunicazione(pid): return true
	return false

func raggio_cp(hq: String) -> int:
	if s["flag"].get("cecchini", false): return 1
	return TRACCIA_CP[min(int(s["cp"][hq]), TRACCIA_CP.size() - 1)]

func raggio_base(b: Dictionary) -> int:
	return TRACCIA_GENIO[min(int(b["i"]), TRACCIA_GENIO.size() - 1)]

## Esagoni nel raggio delle Basi del Genio (19.31-19.32)
func area_genio() -> Dictionary:
	var o = {}
	if s["basi"].is_empty(): return o
	var occ = {}
	for pid in pos_attive():
		for h in mappa.campo(pid): occ[h] = true
	for b in s["basi"]:
		var r = raggio_base(b)
		for h in mappa.esagoni:
			if Mappa.distanza(h, b["hex"]) <= r and not occ.has(h):
				o[h] = true
	return o

func fase_genio_hq() -> void:
	# Posti di Comando: crescono di uno spazio se non sono nel campo di fuoco nemico (18.2)
	for hq in s["cp"].keys():
		var l = unita(hq)
		if l.is_empty() or l["dove"] != "mappa":
			s["cp"].erase(hq)
			continue
		if not in_campo_potenziale(l["hex"]) and int(s["cp"][hq]) < TRACCIA_CP.size() - 1:
			s["cp"][hq] = int(s["cp"][hq]) + 1
	# Basi del Genio: una crescita per Divisione per turno, non se c'è stato fuoco d'artiglieria (19.21, 19.33)
	if s["flag"].get("genio_bloccato", false):
		dlog("L'artiglieria tedesca blocca le operazioni del Genio in questo turno.", "info")
		return
	for b in s["basi"]:
		var sett = mappa.settore(b["hex"])
		if s["art_settore"].get(sett, false): continue
		if s["genio_fatto"].has(str(b["div"])): continue
		if in_campo_potenziale(b["hex"]): continue
		if int(b["i"]) < TRACCIA_GENIO.size() - 1:
			b["i"] = int(b["i"]) + 1
			s["genio_fatto"][str(b["div"])] = true
	aggiorna_guarnigioni()

func aggiorna_guarnigioni() -> void:
	var area = area_genio()
	for pid in mappa.posizioni:
		if occupata(pid) or s["guarnigioni"].has(pid): continue
		var h: String = mappa.posizioni[pid]["hex"][0]
		if area.has(h) and not in_campo_occupato(h):
			s["guarnigioni"][pid] = true
			dlog("Una guarnigione US presidia la %s." % nome_pos(pid), "info")

func puo_base(h: String, div: int) -> String:
	if not estesa(): return "Le Basi del Genio si stabiliscono dal turno 17."
	if s["basi"].filter(func(b): return b["div"] == div).size() >= 2: return "La Divisione ha già due Basi del Genio."
	if s["genio_fatto"].has(str(div)): return "In questo turno la Divisione ha già fatto un'operazione del Genio."
	if not mappa.spiaggia(h): return "La base va su un esagono di spiaggia."
	if mappa.settore(h) != ("E" if div == 1 else "W"): return "La base va nel settore della sua Divisione."
	if in_campo_potenziale(h): return "L'esagono è nel campo di fuoco di una posizione tedesca."
	if s["flag"].get("genio_bloccato", false) or s["art_settore"].get(mappa.settore(h), false): return "L'artiglieria tedesca blocca il Genio in questo turno."
	return ""

func stabilisci_base(h: String, div: int) -> String:
	var e = puo_base(h, div)
	if e != "": return e
	s["basi"].append({"hex": h, "div": div, "i": 0})
	s["genio_fatto"][str(div)] = true
	dlog("Il Genio della %s Divisione stabilisce una base in %s." % ["1ª" if div == 1 else "29ª", h], "azione")
	return ""

func puo_cp(u: Dictionary) -> String:
	if not estesa(): return "I Posti di Comando si stabiliscono dal turno 17."
	if tipo(u) != "hq" or u["dove"] != "mappa": return "Solo un HQ sulla mappa."
	if s["cp"].has(u["id"]): return "È già un Posto di Comando."
	if u["agito"] or s["leader_mossi"].has(u["id"]): return "L'HQ si è già mosso in questo turno."
	if in_campo_potenziale(u["hex"]): return "L'esagono è nel campo di fuoco di una posizione tedesca."
	return ""

func stabilisci_cp(u: Dictionary) -> String:
	var e = puo_cp(u)
	if e != "": return e
	s["cp"][u["id"]] = 0
	u["agito"] = true
	dlog("%s diventa Posto di Comando (raggio 1)." % u["id"], "azione")
	inizia_comando()
	return ""

func abbandona_cp(u: Dictionary) -> void:
	if s["cp"].has(u["id"]):
		s["cp"].erase(u["id"])
		dlog("%s smonta il Posto di Comando." % u["id"], "azione")

## Ricalcola il comando (dopo un nuovo Posto di Comando)
func inizia_comando() -> void:
	pass

# ---------------------------------------------------------------- azioni tedesche (16)
const ORDINE_ZONE := "ABCDEFG"

func _ordine_azione(pid: String) -> float:
	var p: Dictionary = mappa.posizioni[pid]
	if p["tipo"] == "WN": return 1000.0 + float(int(pid.substr(2, 2)))
	return float(p["prio"]) * 10.0 + float(ORDINE_ZONE.find(p["zona"]) if p["zona"] != "" else -1) * 0.1

func us_nel_campo(pid: String, livelli := [1, 2, 3]) -> Array:
	var campo = mappa.campo(pid)
	var o: Array = []
	for h in campo:
		if not int(campo[h]) in livelli: continue
		for u in combattenti_in(h): o.append(u)
	return o

func azioni_tedesche(sett: String, c: Dictionary) -> void:
	var fatti = {}
	var lista: Array = []
	for pid in mappa.posizioni:
		var g: String = mappa.posizioni[pid].get("gruppo", pid)
		if fatti.has(g): continue
		fatti[g] = true
		if settore_pos(pid) != sett: continue
		var q = _quadrato(c, colore(pid))
		if q.is_empty(): continue
		lista.append(pid)
	# prima le posizioni con il numero maggiore (16, sequenza delle azioni)
	lista.sort_custom(func(a, b): return _ordine_azione(a) > _ordine_azione(b))
	var avanzate: Array = []
	var colpi = 0
	for pid in lista:
		var q = _quadrato(c, colore(pid))
		var az: String = q.get("az", "F")
		var parti = gruppo(pid)
		var occ = parti.any(func(x): return occupata(x))
		var wn: bool = mappa.posizioni[pid]["tipo"] == "WN"
		if _fumo(pid): continue
		if occ:
			var attive = parti.filter(func(x): return occupata(x) and not s["de"][x]["conf"])
			if attive.is_empty(): continue
			var con_dm = parti.any(func(x): return occupata(x) and not s["de"][x]["dm"].is_empty())
			var nel_campo = not us_nel_campo(pid).is_empty()
			if q["doppio"] and not con_dm:
				# 16.21: il rifornimento si fa anche con il quadrato doppio
				if not (az == "R" and not wn and nel_campo):
					continue
			if az == "F":
				if nel_campo: colpi += _spara(pid, c)
			elif az == "R":
				if wn:
					if nel_campo: colpi += _spara(pid, c)
				elif nel_campo:
					rifornimento(pid)
					colpi += _spara(pid, c)
				else:
					reimpiego(pid)
			elif az == "M":
				if nel_campo: colpi += _spara(pid, c)
				else: mortai(pid, c)
			elif az == "P":
				if wn:
					if nel_campo: colpi += _spara(pid, c)
				else:
					pattuglia_ted(pid, c)
			elif az == "A":
				if wn:
					if nel_campo: colpi += _spara(pid, c)
					else: artiglieria_wn(pid, c)
				else:
					avanzate.append(pid)
		else:
			if not in_comunicazione(pid): continue
			if wn:
				if az == "R": rioccupa(pid)
				continue
			if _dist_us(pid) > 2: continue
			if az == "R": rinforzo_posizione(pid)
			elif az == "A": imboscata(pid, c)
	for pid in avanzate:
		if occupata(pid) and not s["de"][pid]["conf"]:
			avanzata(pid, c)
	if colpi == 0:
		dlog("Nessun colpo diretto dalle posizioni tedesche del settore %s." % _nome_sett(sett), "info")

func _spara(pid: String, c: Dictionary) -> int:
	var parti = gruppo(pid)
	var limite = 0
	var nascosta = false
	for x in parti:
		var de: Dictionary = s["de"][x]
		if de["u"].is_empty() or de["conf"]: continue
		limite += 1 + (0 if de["dm"].is_empty() else 1)
		if mappa.posizioni[x]["tipo"] == "R" and not de["u"]["riv"]: nascosta = true
	if limite == 0: return 0
	var f = {"pid": pid, "parti": parti, "limite": limite * 2, "nascosta": nascosta, "q": _quadrato(c, colore(pid))}
	return fuoco_pos(f, c, {})

func rioccupa(pid: String) -> void:
	var parti = gruppo(pid)
	var occ_us = parti.any(func(x): return not unita_in(mappa.posizioni[x]["hex"][0]).filter(func(u): return tipo(u) != "generale").is_empty())
	if occ_us: return
	if parti.any(func(x): return s["guarnigioni"].has(x)): return
	for x in parti:
		if s["wn_elim"].is_empty():
			dlog("Nessuna unità WN disponibile per rioccupare %s." % nome_pos(pid), "info")
			return
		s["wn_elim"] = _mescola(s["wn_elim"])
		var i: int = s["wn_elim"].pop_back()
		s["de"][x] = {"u": {"k": "wn", "i": i, "riv": true}, "dm": {}, "conf": false}
		dlog("I tedeschi rioccupano la %s." % nome_pos(x), "tedesco")

func rifornimento(pid: String) -> void:
	if not s["de"][pid]["dm"].is_empty() or not in_comunicazione(pid): return
	var dm = _dm_per(pid)
	if dm.is_empty(): return
	s["de"][pid]["dm"] = dm
	dlog("La %s si rifornisce: arriva un segnalino Incognita." % nome_pos(pid), "tedesco")

func _passi_campo(pid: String) -> int:
	var t = 0
	for u in us_nel_campo(pid): t += passi_rimasti(u)
	return t

func reimpiego(pid: String) -> void:
	if not in_comunicazione(pid): return
	var vp: bool = mappa.posizioni[pid].get("vp", 0) == 1
	var sett = settore_pos(pid)
	var cand: Array = []
	for x in mappa.posizioni:
		var p: Dictionary = mappa.posizioni[x]
		if p["tipo"] != "R" or occupata(x) or s["guarnigioni"].has(x): continue
		if mappa.settore(p["hex"][0]) != sett: continue
		if vp and p.get("vp", 0) != 1: continue
		if us_nel_campo(x).is_empty() or not in_comunicazione(x): continue
		if not unita_in(p["hex"][0]).filter(func(u): return tipo(u) != "generale").is_empty(): continue
		cand.append(x)
	if cand.is_empty(): return
	cand.sort_custom(func(a, b):
		var va = mappa.posizioni[a].get("vp", 0); var vb = mappa.posizioni[b].get("vp", 0)
		if va != vb: return va > vb
		var pa = mappa.posizioni[a]["prio"]; var pb = mappa.posizioni[b]["prio"]
		if pa != pb: return pa < pb
		return _passi_campo(a) > _passi_campo(b))
	_sposta_tedesco(pid, cand[0])
	dlog("L'unità tedesca della %s si reimpiega nella %s." % [nome_pos(pid), nome_pos(cand[0])], "tedesco")

func _sposta_tedesco(da: String, a: String) -> void:
	var de: Dictionary = s["de"][da]
	s["de"][a] = {"u": de["u"], "dm": de["dm"], "conf": de["conf"]}
	s["de"][da] = {"u": {}, "dm": {}, "conf": false}
	s["guarnigioni"].erase(a)
	var dm: Dictionary = s["de"][a]["dm"]
	if not dm.is_empty() and dm["p"] in ["mobile", "edificio"]:
		var serve = "edificio" if mappa.posizioni[a].get("ed", 0) == 1 else "mobile"
		if dm["p"] != serve and not s["pool"][serve].is_empty():
			s["pool"][dm["p"]].append(dm["i"])
			s["de"][a]["dm"] = {"p": serve, "i": s["pool"][serve].pop_back(), "riv": false}
	for u in unita_in(mappa.posizioni[a]["hex"][0]):
		if tipo(u) == "generale": elimina(u, "catturato dai tedeschi")

func rinforzo_posizione(pid: String) -> void:
	if s["guarnigioni"].has(pid): return
	var h: String = mappa.posizioni[pid]["hex"][0]
	if not unita_in(h).filter(func(u): return tipo(u) != "generale").is_empty(): return
	var vp: bool = mappa.posizioni[pid].get("vp", 0) == 1
	if not vp and us_nel_campo(pid, [2, 3]).is_empty(): return
	var r = _pesca_rinforzo()
	if r.is_empty(): return
	piazza_rinforzo(pid, r, true, false)

func mortai(pid: String, c: Dictionary) -> void:
	var base: String = mappa.posizioni[pid]["hex"][0]
	var wn: bool = mappa.posizioni[pid]["tipo"] == "WN"
	var cand: Array = []
	for u in sulla_mappa():
		if leader(u) or simbolo(u) != c["bersaglio"]: continue
		var d = Mappa.distanza(u["hex"], base)
		var ok = false
		if wn:
			var vicino_sp = mappa.spiaggia(u["hex"]) or (mappa.terreno(u["hex"]) == "pianoro" and mappa.vicini(u["hex"]).any(func(x): return mappa.spiaggia(x)))
			ok = (vicino_sp and d <= 5) or (d <= 2 and mappa.terreno(u["hex"]) in ["pianoro", "altura", "bocage", "bosco"])
		else:
			ok = d <= 3
		if ok: cand.append(u)
	if cand.is_empty(): return
	cand.sort_custom(func(a, b): return passi_rimasti(a) > passi_rimasti(b))
	var n = 2 if not s["de"][pid]["dm"].is_empty() else 1
	for u in cand.slice(0, n):
		perdi_passo(u, "mortai da %s" % nome_pos(pid))

func pattuglia_ted(pid: String, c: Dictionary) -> void:
	var colpite = us_nel_campo(pid, [2, 3])
	if colpite.is_empty():
		var base: String = mappa.posizioni[pid]["hex"][0]
		var cand = sulla_mappa().filter(func(u): return not leader(u) and Mappa.distanza(u["hex"], base) <= 3)
		if cand.is_empty(): return
		cand.sort_custom(func(a, b):
			var da = Mappa.distanza(a["hex"], base); var db = Mappa.distanza(b["hex"], base)
			if da != db: return da < db
			var sa = simbolo(a) == c["bersaglio"]; var sb = simbolo(b) == c["bersaglio"]
			if sa != sb: return sa
			return attacco(a) > attacco(b))
		colpite = [cand[0]]
	var nomi: Array = []
	for u in colpite:
		if u["conf"] == 0:
			u["conf"] = 1
			nomi.append(u["id"])
	if not nomi.is_empty():
		dlog("Pattuglia tedesca dalla %s: in confusione %s." % [nome_pos(pid), ", ".join(nomi)], "danno")

func artiglieria_wn(pid: String, c: Dictionary) -> void:
	var u0: Dictionary = s["de"][pid]["u"]
	if u0["k"] != "wn" or not def_tedeschi["wn"][u0["i"]]["cal"] in ["75", "88"]: return
	var sett = settore_pos(pid)
	var gruppi = [[], [], [], []]
	for u in s["us"]:
		if leader(u) or simbolo(u) != c["bersaglio"]: continue
		var sp: bool = u["dove"] == "mappa" and mappa.spiaggia(u["hex"])
		var bx: bool = u["dove"] == "box"
		if sp and fanteria(u): gruppi[0].append(u)
		elif sp: gruppi[1].append(u)
		elif bx and not fanteria(u): gruppi[2].append(u)
		elif bx: gruppi[3].append(u)
	for g in gruppi:
		if g.is_empty(): continue
		g.sort_custom(func(a, b):
			var sa = (mappa.settore(a["hex"]) if a["dove"] == "mappa" else mappa.box[a["box"]]["s"]) == sett
			var sb = (mappa.settore(b["hex"]) if b["dove"] == "mappa" else mappa.box[b["box"]]["s"]) == sett
			if sa != sb: return sa
			return passi_rimasti(a) > passi_rimasti(b))
		dlog("L'artiglieria della %s colpisce." % nome_pos(pid), "danno")
		s["art_settore"][sett] = true
		perdi_passo(g[0], "artiglieria da %s" % nome_pos(pid))
		return

func imboscata(pid: String, c: Dictionary) -> void:
	var campo = mappa.campo(pid)
	var base: String = mappa.posizioni[pid]["hex"][0]
	var cand: Array = []
	for h in campo:
		for u in combattenti_in(h):
			if simbolo(u) == c["bersaglio"]:
				cand.append({"u": u, "liv": int(campo[h]), "d": Mappa.distanza(h, base)})
	if cand.is_empty(): return
	cand.sort_custom(func(a, b):
		var ia = a["liv"] == 3; var ib = b["liv"] == 3
		if ia != ib: return ia
		if a["d"] != b["d"]: return a["d"] < b["d"]
		return passi_rimasti(a["u"]) > passi_rimasti(b["u"]))
	var k = cand[0]
	if k["liv"] == 3:
		dlog("Imboscata dalla %s!" % nome_pos(pid), "danno")
		perdi_passo(k["u"], "imboscata")
	elif k["u"]["conf"] == 0:
		k["u"]["conf"] = 1
		dlog("Imboscata dalla %s: %s in confusione." % [nome_pos(pid), k["u"]["id"]], "danno")

## Percorso di avanzata (16.82, i tre diagrammi del regolamento).
## Distanza 1 o linea retta di due esagoni: tutti gli esagoni con distanza(partenza) + distanza(arrivo) <= d + 1.
## Due esagoni «a cavallo di un vertice» (due vicini in comune): i due vicini comuni, l'arrivo e i suoi due vicini laterali.
func percorso_avanzata(da: String, a: String) -> Array:
	var ha: String = mappa.posizioni[da]["hex"][0]
	var hb: String = mappa.posizioni[a]["hex"][0]
	var d = Mappa.distanza(ha, hb)
	var vicini_a = Mappa.vicini_raw(ha)
	var vicini_b = Mappa.vicini_raw(hb)
	var comuni = vicini_a.filter(func(x): return x in vicini_b)
	var o: Array = []
	if d == 2 and comuni.size() == 2:
		o = comuni.duplicate()
		for v in vicini_b:
			if Mappa.distanza(v, ha) == 2: o.append(v)
	else:
		var cand = {}
		for v in vicini_a + vicini_b: cand[v] = true
		for v in vicini_b:
			for w in Mappa.vicini_raw(v): cand[w] = true
		for h in cand:
			if h == ha or h == hb: continue
			if Mappa.distanza(h, ha) + Mappa.distanza(h, hb) <= d + 1: o.append(h)
	o.append(hb)
	return o.filter(func(x): return mappa.esagoni.has(x))

func avanzata(pid: String, c: Dictionary) -> void:
	var dests: Array = mappa.posizioni[pid].get("avanza", [])
	var dest = ""
	for d in dests:
		if not occupata(d):
			dest = d
			break
	var de: Dictionary = s["de"][pid]
	var nel_campo = not us_nel_campo(pid).is_empty()
	var div: int = int(def_tedesca(pid).get("div", 716))
	var con_dm = not de["dm"].is_empty()
	if dest == "":
		if nel_campo: _spara(pid, c)
		return
	var tenta = (not nel_campo) or (de["u"]["riv"] and div == 352 and con_dm) or (not de["u"]["riv"] and con_dm)
	if not tenta:
		if nel_campo and (div == 716 or not con_dm): _spara(pid, c)
		return
	var perc = percorso_avanzata(pid, dest)
	var difensori: Array = []
	for h in perc:
		for u in combattenti_in(h):
			if (not fanteria(u) and tipo(u) != "carro") or simbolo(u) == c["bersaglio"]:
				if u["conf"] == 0: u["conf"] = 1
			if u["conf"] == 0: difensori.append(u)
	var forza = 0
	for u in difensori:
		var f = attacco(u)
		if mappa.edifici(u["hex"]) or mappa.terreno(u["hex"]) == "bocage": f *= 2
		if u["eroe"] >= 0 and not u["ispirato"]: f += 1
		forza += f
	if forza >= 7:
		dlog("L'avanzata tedesca dalla %s verso la %s è respinta (difesa US %d)." % [nome_pos(pid), nome_pos(dest), forza], "tedesco")
		return
	if not difensori.is_empty():
		difensori.sort_custom(func(a, b): return passi_rimasti(a) > passi_rimasti(b))
		perdi_passo(difensori[0], "avanzata tedesca")
	var hb: String = mappa.posizioni[dest]["hex"][0]
	for u in unita_in(hb):
		var fuga = mappa.vicini(hb).filter(func(v): return not v in perc and not tedesco_in(v) and v != mappa.posizioni[pid]["hex"][0])
		if fuga.is_empty(): elimina(u, "travolta dall'avanzata tedesca")
		else: u["hex"] = fuga[0]
	_sposta_tedesco(pid, dest)
	dlog("I tedeschi avanzano dalla %s alla %s." % [nome_pos(pid), nome_pos(dest)], "tedesco")

# ---------------------------------------------------------------- eventi della modalità estesa
func navale_inatteso(par: Dictionary) -> void:
	var c = carta(pesca())
	var pid: String = par[c["bersaglio"]]
	if not mappa.posizioni.has(pid):
		for x in mappa.posizioni:
			if mappa.posizioni[x].get("gruppo", "") == pid or x.begins_with(pid):
				pid = x
				break
	dlog("Il fuoco navale cade sulla %s." % nome_pos(pid), "evento")
	if occupata(pid):
		s["de"][pid]["conf"] = true
		s["de"][pid]["dm"] = {}
		return
	var h: String = mappa.posizioni[pid]["hex"][0]
	var us = combattenti_in(h)
	if us.is_empty(): return
	var c2 = carta(pesca())
	for u in us:
		if simbolo(u) == c2["bersaglio"]:
			perdi_passo(u, "fuoco navale amico")
			return

func tedeschi_nascosti(par: Array) -> void:
	var nascosti = {}
	for pid in pos_attive():
		if mappa.posizioni[pid]["tipo"] == "R" and not s["de"][pid]["u"]["riv"]:
			nascosti[mappa.posizioni[pid]["hex"][0]] = true
	for u in sulla_mappa():
		if leader(u) or not simbolo(u) in par: continue
		if mappa.vicini(u["hex"]).any(func(v): return nascosti.has(v)):
			if u["conf"] == 0:
				u["conf"] = 1
				dlog("%s in confusione: tedeschi nascosti." % u["id"], "danno")

# ---------------------------------------------------------------- scenario «Oltre la spiaggia» (21)
func prepara_oltre() -> void:
	s["turno"] = 17
	s["razzi_sparati"] = true
	# tedeschi
	for id in s["de"]: s["de"][id] = {"u": {}, "dm": {}, "conf": false}
	var art88: Array = []; var art75: Array = []; var altre: Array = []; var razzi = -1
	for i in def_tedeschi["wn"].size():
		var c: String = def_tedeschi["wn"][i]["cal"]
		if c == "88": art88.append(i)
		elif c == "75": art75.append(i)
		elif c == "razzi": razzi = i
		else: altre.append(i)
	art88 = _mescola(art88); art75 = _mescola(art75); altre = _mescola(altre)
	var piazza = {"WN72S": art88[0], "WN69": razzi}
	var a3 = ["WN62S", "WN65S", "WN68S"]
	for k in 3: piazza[a3[k]] = art75[k]
	var n8 = ["WN62N", "WN65N", "WN67", "WN66N", "WN66S", "WN68N", "WN71", "WN72N"]
	for k in 8: piazza[n8[k]] = altre[k]
	for id in piazza: s["de"][id]["u"] = {"k": "wn", "i": piazza[id], "riv": false}
	s["wn_elim"] = altre.slice(8)
	var wn_dm = _mescola(range(def_tedeschi["dm"]["wn"].size()))
	var k2 = 0
	for id in ["WN62S", "WN65S", "WN66S", "WN67", "WN68S", "WN69", "WN72N", "WN72S"]:
		s["de"][id]["dm"] = {"p": "wn", "i": wn_dm[k2], "riv": false}
		k2 += 1
	s["pool"]["wn"] = [wn_dm[k2]]
	var div = _mescola(range(def_tedeschi["rinforzi"]["D"].size()))
	var tat = _mescola(range(def_tedeschi["rinforzi"]["T"].size()))
	var unita_r: Array = []
	for i in 6: unita_r.append(["D", div[i]])
	for i in 6: unita_r.append(["T", tat[i]])
	unita_r = _mescola(unita_r)
	s["pool"]["D"] = div.slice(6).map(func(x): return ["D", x])
	s["pool"]["T"] = []
	var mob = _mescola(range(def_tedeschi["dm"]["mobile"].size()))
	s["pool"]["meyer_dm"] = mob.slice(0, 4)
	s["pool"]["mobile"] = mob.slice(4)
	s["pool"]["edificio"] = _mescola(range(def_tedeschi["dm"]["edificio"].size()))
	var posti = ["A3D", "A4D", "A7", "C2D", "C4D", "C6", "D1D", "E5", "F1D", "G1", "G2D", "G6"]
	for k in posti.size():
		var pid: String = posti[k].trim_suffix("D")
		s["de"][pid]["u"] = {"k": unita_r[k][0], "i": unita_r[k][1], "riv": false}
		if posti[k].ends_with("D"):
			s["de"][pid]["dm"] = _dm_per(pid)
	# unità US
	var pos_us = {"A/1/16": ["1115", 0, -1], "B/1/16": ["1114", 0, -1], "C/1/16": ["0916", 1, -1], "D/1/16": ["0814", 1, -1],
		"E/2/16": ["1213", 2, 1], "F/2/16": ["1110", 2, 1], "G/2/16": ["1313", 2, -1], "H/2/16": ["0813", 2, -1],
		"I/3/16": ["1008", 0, -1], "K/3/16": ["0807", 1, -1], "L/3/16": ["0908", 1, 1], "M/3/16": ["0809", 1, -1],
		"16 HQ": ["1014", 0, -1], "Gen. Wyman": ["0814", 0, -1],
		"B/1/116": ["1028", 2, -1], "C/1/116": ["0830", 0, -1], "D/1/116": ["0726", 1, -1], "E/2/116": ["1113", 2, -1],
		"F/2/116": ["1119", 2, 29], "G/2/116": ["0926", 2, -1], "H/2/116": ["0819", 1, -1], "I/3/116": ["1020", 0, -1],
		"K/3/116": ["0920", 0, -1], "L/3/116": ["1119", 0, -1], "M/3/116": ["0919", 0, 29], "116 HQ": ["0926", 0, -1],
		"Gen. Cota": ["0830", 0, -1], "C/2R": ["0533", 1, -1], "A-B/2R": ["0728", 1, -1]}
	var veicoli = {"1/B/741": 1, "2/A/741": 1, "1/A/741": 1, "1-2/397": 1, "7FA": 2, "A-B/197": 1,
		"1/A/743": 1, "1/B/743": 0, "2/B/743": 1, "2/C/743": 0, "5-6/397": 1, "58AFA": 1, "C-D/467": 1}
	var media_e: Array = []
	var media_w: Array = []
	for h in mappa.media_set:
		if mappa.settore(h) == "E": media_e.append(h)
		else: media_w.append(h)
	var espo = func(h: String) -> int:
		var t = 0
		for pid in pos_attive():
			t += int(mappa.campo(pid).get(h, 0))
		return t
	media_e.sort_custom(func(a, b): return espo.call(a) < espo.call(b))
	media_w.sort_custom(func(a, b): return espo.call(a) < espo.call(b))
	var eroi_usati = {"1": 0, "29": 0}
	for u in s["us"]:
		var d = defu(u)
		if pos_us.has(u["id"]):
			var v: Array = pos_us[u["id"]]
			u["dove"] = "mappa"; u["hex"] = v[0]; u["passo"] = v[1]
			if v[2] > 0:
				var kd = str(u["div"])
				u["eroe"] = s["eroi"][kd].pop_front()
			if u["id"] == "E/2/116": u["cmd"] = 1
			if regolare(u) and passi_rimasti(u) == 1: _conta_perdita(u)
		elif veicoli.has(u["id"]):
			var lista: Array = media_e if u["div"] == 1 else media_w
			u["dove"] = "mappa"; u["passo"] = veicoli[u["id"]]
			u["hex"] = lista[0]
			if combattenti_in(lista[0]).size() >= 1: lista.pop_front()
		elif int(d["turno"]) == 16:
			u["dove"] = "traccia"; u["arrivo"] = 16
		elif int(d["turno"]) >= 17:
			pass
		else:
			u["dove"] = "rimossa"
	var a116 = unita("A/1/116")
	if not a116.is_empty():
		a116["dove"] = "eliminata"
		_conta_perdita(a116)
	for u in s["us"]:
		if u["dove"] == "traccia" and u["arrivo"] == 16:
			u["arrivo"] = 17
			metti_in_box(u)
	for h in ["0612", "0613", "0614", "0615", "0616", "0523", "0524", "0525", "0426"]:
		s["bonificati"][h] = true
