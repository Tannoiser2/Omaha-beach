## Interfaccia di D-Day at Omaha Beach: mappa originale con le pedine, pannello di comando,
## carte del turno, registro degli eventi, salvataggi locali e su Firebase.
extends Node

const PEDINE := "res://assets/pedine/"
const SALVATAGGIO := "user://partita_omaha.json"
const C_FONDO := Color(0.13, 0.15, 0.11)
const C_PANNELLO := Color(0.17, 0.20, 0.15, 0.97)
const C_CREMA := Color(0.93, 0.91, 0.82)
const C_VERDE := Color(0.10, 0.48, 0.24)
const C_ROSSO := Color(0.80, 0.16, 0.14)
const C_KAKI := Color(0.84, 0.85, 0.69)
const COLORI := {"verde": Color8(1, 160, 85), "arancio": Color8(238, 160, 58), "rosso": Color8(236, 36, 46),
	"viola": Color8(150, 45, 148), "marrone": Color8(140, 100, 42), "blu": Color8(60, 170, 232)}

var g: Partita
var bot: Bot
var net: Node
var f_titoli: Font
var f_testo: Font
var f_macchina: Font
var tex := {}

var mondo: Node2D
var cam: Camera2D
var tavolo: Node2D
var mappa_spr: Sprite2D
var ui: CanvasLayer
var pannello: PanelContainer
var lbl_turno: Label
var lbl_fase: Label
var lbl_azioni: Label
var vista_carte: Control
var lbl_evento: Label
var box_unita: VBoxContainer
var registro_txt: RichTextLabel
var lbl_hover: Label
var btn_fine: Button
var btn_navale: Button
var chk_pila: CheckBox
var chk_campi: CheckBox
var menu: Control
var finestra: Control

var sel := {}
var modo := ""
var hover := ""
var hover_pid := ""
var trascina := false
var trascinato := 0.0
var ultimo_mouse := Vector2.ZERO
var bersagli := {}

# ================================================================ avvio
func _ready() -> void:
	RenderingServer.set_default_clear_color(C_FONDO)
	f_titoli = load("res://assets/font/Titoli.ttf")
	f_testo = load("res://assets/font/Testo.ttf")
	f_macchina = load("res://assets/font/Macchina.ttf")
	net = load("res://scripts/net.gd").new()
	add_child(net)
	g = Partita.new()
	bot = Bot.new(g)
	g.registro.connect(_su_registro)
	_costruisci_mondo()
	_costruisci_ui()
	_mostra_menu()

func _t(nome: String) -> Texture2D:
	if not tex.has(nome):
		var p = PEDINE + nome.replace("/", "_") + ".jpg"
		tex[nome] = load(p) if ResourceLoader.exists(p) else null
	return tex[nome]

func _costruisci_mondo() -> void:
	mondo = Node2D.new()
	add_child(mondo)
	mappa_spr = Sprite2D.new()
	mappa_spr.texture = load("res://assets/mappa.jpg")
	mappa_spr.centered = false
	mondo.add_child(mappa_spr)
	tavolo = Tavolo.new()
	tavolo.main = self
	mondo.add_child(tavolo)
	cam = Camera2D.new()
	mondo.add_child(cam)
	cam.make_current()
	cam.zoom = Vector2(0.55, 0.55)
	cam.position = g.mappa.centro("0712")

class Tavolo extends Node2D:
	var main
	func _draw() -> void:
		main.disegna(self)

# ================================================================ tema e pannello
func _tema() -> Theme:
	var t = Theme.new()
	t.default_font = f_testo
	t.default_font_size = 17
	var sb = StyleBoxFlat.new()
	sb.bg_color = C_PANNELLO
	sb.border_color = Color(0.45, 0.47, 0.33)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(4)
	sb.set_content_margin_all(10)
	t.set_stylebox("panel", "PanelContainer", sb)
	for stato in ["normal", "hover", "pressed", "disabled", "focus"]:
		var b = StyleBoxFlat.new()
		b.bg_color = {"normal": Color(0.26, 0.31, 0.20), "hover": Color(0.33, 0.40, 0.25), "pressed": C_VERDE, "disabled": Color(0.2, 0.21, 0.18), "focus": Color(0.26, 0.31, 0.20)}[stato]
		b.border_color = Color(0.62, 0.64, 0.45) if stato != "disabled" else Color(0.3, 0.3, 0.27)
		b.set_border_width_all(1)
		b.set_corner_radius_all(3)
		b.content_margin_left = 10; b.content_margin_right = 10
		b.content_margin_top = 4; b.content_margin_bottom = 4
		t.set_stylebox(stato, "Button", b)
	t.set_color("font_color", "Button", C_CREMA)
	t.set_color("font_disabled_color", "Button", Color(0.55, 0.55, 0.5))
	t.set_color("font_color", "Label", C_CREMA)
	t.set_color("font_color", "CheckBox", C_CREMA)
	t.set_color("default_color", "RichTextLabel", C_CREMA)
	var le = StyleBoxFlat.new()
	le.bg_color = Color(0.93, 0.91, 0.82)
	le.set_content_margin_all(6)
	t.set_stylebox("normal", "LineEdit", le)
	t.set_color("font_color", "LineEdit", Color(0.1, 0.1, 0.1))
	return t

func _label(testo: String, dim := 17, font: Font = null, col := C_CREMA) -> Label:
	var l = Label.new()
	l.text = testo
	l.add_theme_font_size_override("font_size", dim)
	if font != null: l.add_theme_font_override("font", font)
	l.add_theme_color_override("font_color", col)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l

func _bottone(testo: String, cb: Callable) -> Button:
	var b = Button.new()
	b.text = testo
	b.pressed.connect(cb)
	return b

func _costruisci_ui() -> void:
	ui = CanvasLayer.new()
	add_child(ui)
	var radice = Control.new()
	radice.set_anchors_preset(Control.PRESET_FULL_RECT)
	radice.mouse_filter = Control.MOUSE_FILTER_IGNORE
	radice.theme = _tema()
	ui.add_child(radice)
	pannello = PanelContainer.new()
	pannello.anchor_left = 1.0; pannello.anchor_right = 1.0; pannello.anchor_bottom = 1.0
	pannello.offset_left = -430
	radice.add_child(pannello)
	var sc = ScrollContainer.new()
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	pannello.add_child(sc)
	var v = VBoxContainer.new()
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.add_theme_constant_override("separation", 6)
	sc.add_child(v)
	var tit = _label("OMAHA BEACH", 34, f_titoli, Color(0.15, 0.62, 0.32))
	tit.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(tit)
	lbl_turno = _label("", 20, f_titoli, C_KAKI)
	lbl_turno.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(lbl_turno)
	lbl_fase = _label("", 16)
	v.add_child(lbl_fase)
	lbl_azioni = _label("", 16, null, C_KAKI)
	v.add_child(lbl_azioni)
	var riga = HBoxContainer.new()
	btn_fine = _bottone("Fine fase azioni", _fine_azioni)
	btn_fine.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	riga.add_child(btn_fine)
	riga.add_child(_bottone("Gioca il turno per me", _turno_automatico))
	v.add_child(riga)
	var riga2 = HBoxContainer.new()
	btn_navale = _bottone("Fuoco navale", func(): _modo("navale"))
	riga2.add_child(btn_navale)
	chk_pila = CheckBox.new()
	chk_pila.text = "Muovi in coppia"
	chk_pila.tooltip_text = "Due unità dello stesso esagono che si muovono insieme spendono una sola azione."
	riga2.add_child(chk_pila)
	chk_campi = CheckBox.new()
	chk_campi.text = "Campi di fuoco"
	chk_campi.button_pressed = true
	chk_campi.toggled.connect(func(_x): tavolo.queue_redraw())
	riga2.add_child(chk_campi)
	v.add_child(riga2)
	v.add_child(HSeparator.new())
	vista_carte = VistaCarte.new()
	vista_carte.main = self
	vista_carte.custom_minimum_size = Vector2(400, 150)
	v.add_child(vista_carte)
	lbl_evento = _label("", 15, null, C_KAKI)
	v.add_child(lbl_evento)
	v.add_child(HSeparator.new())
	box_unita = VBoxContainer.new()
	v.add_child(box_unita)
	v.add_child(HSeparator.new())
	registro_txt = RichTextLabel.new()
	registro_txt.custom_minimum_size = Vector2(400, 300)
	registro_txt.bbcode_enabled = true
	registro_txt.scroll_following = true
	registro_txt.add_theme_font_override("normal_font", f_macchina)
	registro_txt.add_theme_font_size_override("normal_font_size", 14)
	v.add_child(registro_txt)
	var riga3 = HBoxContainer.new()
	riga3.add_child(_bottone("Salva online", _salva_online))
	riga3.add_child(_bottone("Menu", _mostra_menu))
	riga3.add_child(_bottone("Regole in breve", _regole))
	v.add_child(riga3)
	# barra in basso a sinistra
	var barra = PanelContainer.new()
	barra.anchor_top = 1.0; barra.anchor_bottom = 1.0
	barra.offset_top = -46; barra.offset_left = 8; barra.offset_bottom = -8; barra.offset_right = 700
	radice.add_child(barra)
	var hb = HBoxContainer.new()
	barra.add_child(hb)
	hb.add_child(_bottone("+", func(): _zoom(1.2, get_viewport().get_visible_rect().size / 2)))
	hb.add_child(_bottone("-", func(): _zoom(1 / 1.2, get_viewport().get_visible_rect().size / 2)))
	hb.add_child(_bottone("Spiaggia", func(): cam.position = g.mappa.centro("0716"); cam.zoom = Vector2(0.7, 0.7)))
	lbl_hover = _label("", 15)
	lbl_hover.autowrap_mode = TextServer.AUTOWRAP_OFF
	hb.add_child(lbl_hover)
	finestra = Control.new()
	finestra.set_anchors_preset(Control.PRESET_FULL_RECT)
	finestra.mouse_filter = Control.MOUSE_FILTER_IGNORE
	radice.add_child(finestra)
	menu = Control.new()
	menu.set_anchors_preset(Control.PRESET_FULL_RECT)
	radice.add_child(menu)

# ================================================================ carte del turno
class VistaCarte extends Control:
	var main
	func _draw() -> void:
		main.disegna_carte(self)

func disegna_carte(c: Control) -> void:
	if g.s.is_empty(): return
	var ct: Dictionary = g.s["carte_turno"]
	var x = 0.0
	for k in ["fuoco_E", "fuoco_W"]:
		if not ct.has(k): continue
		_mini_carta(c, Vector2(x, 0), ct[k], "Fuoco " + ("Est" if k == "fuoco_E" else "Ovest"))
		x += 200
	if x == 0:
		c.draw_string(f_testo, Vector2(4, 24), "Le carte del turno compariranno qui.", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, C_KAKI)

func _mini_carta(c: CanvasItem, p: Vector2, n: int, titolo: String) -> void:
	var d = g.carta(n)
	c.draw_rect(Rect2(p, Vector2(192, 146)), Color(0.86, 0.84, 0.76))
	c.draw_rect(Rect2(p, Vector2(192, 24)), Color(0.12, 0.42, 0.22))
	c.draw_string(f_testo, p + Vector2(6, 18), "%s - carta %d" % [titolo, n], HORIZONTAL_ALIGNMENT_LEFT, -1, 15, C_CREMA)
	var sb: Dictionary = d["sbarco"]
	var xx = 6.0
	c.draw_string(f_testo, p + Vector2(xx, 44), "Sbarco", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0.2, 0.2, 0.2))
	xx += 46
	for sim in ["D", "T", "C"]:
		draw_simbolo(c, p + Vector2(xx + 6, 39), 6.0, sim, Color(0.1, 0.1, 0.1))
		c.draw_string(f_testo, p + Vector2(xx + 14, 44), sb[sim], HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(0.1, 0.1, 0.1))
		xx += 32
	if d["mina"]:
		c.draw_string(f_testo, p + Vector2(xx + 2, 44), "MINE", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, C_ROSSO)
	var qx = 10.0
	for q in d["fuoco"]:
		var col: Color = COLORI[q["col"]]
		if q["doppio"]:
			c.draw_rect(Rect2(p + Vector2(qx + 5, 58), Vector2(30, 30)), col.darkened(0.15))
			c.draw_rect(Rect2(p + Vector2(qx + 5, 58), Vector2(30, 30)), Color(1, 1, 1, 0.8), false, 1.5)
		c.draw_rect(Rect2(p + Vector2(qx, 63), Vector2(30, 30)), col)
		c.draw_rect(Rect2(p + Vector2(qx, 63), Vector2(30, 30)), Color(1, 1, 1, 0.9), false, 1.5)
		var cc = p + Vector2(qx + 15, 78)
		if q["stella"]:
			draw_stella(c, cc, 9.0, Color.WHITE)
		elif q["carri"]:
			c.draw_rect(Rect2(cc - Vector2(9, 4), Vector2(18, 8)), Color.WHITE, false, 2.0)
		qx += 44
	draw_simbolo(c, p + Vector2(qx + 16, 78), 12.0, d["bersaglio"], Color(0.08, 0.08, 0.1))
	if d["art"] != null:
		var a: Dictionary = d["art"]
		c.draw_rect(Rect2(p + Vector2(6, 104), Vector2(180, 22)), Color(0.1, 0.1, 0.1))
		c.draw_string(f_testo, p + Vector2(12, 121), "Artiglieria %d pezzi: %s" % [a["n"], " ".join(a["cal"])], HORIZONTAL_ALIGNMENT_LEFT, -1, 14, C_CREMA)
	elif g.s["turno"] < 4:
		pass

func draw_simbolo(c: CanvasItem, cen: Vector2, r: float, sim: String, col: Color, pieno := true) -> void:
	var pts = PackedVector2Array()
	match sim:
		"D":
			pts = PackedVector2Array([cen + Vector2(0, -r * 1.25), cen + Vector2(r * 1.05, 0), cen + Vector2(0, r * 1.25), cen + Vector2(-r * 1.05, 0)])
		"T":
			pts = PackedVector2Array([cen + Vector2(0, -r * 1.2), cen + Vector2(r * 1.15, r * 0.9), cen + Vector2(-r * 1.15, r * 0.9)])
		_:
			if pieno: c.draw_circle(cen, r, col)
			else: c.draw_arc(cen, r, 0, TAU, 24, col, 2.0)
			return
	if pieno:
		c.draw_colored_polygon(pts, col)
	else:
		pts.append(pts[0])
		c.draw_polyline(pts, col, 2.0)

func draw_stella(c: CanvasItem, cen: Vector2, r: float, col: Color) -> void:
	var pts = PackedVector2Array()
	for i in 10:
		var rr = r if i % 2 == 0 else r * 0.45
		var a = -PI / 2 + i * PI / 5
		pts.append(cen + Vector2(cos(a), sin(a)) * rr)
	c.draw_colored_polygon(pts, col)

# ================================================================ disegno della mappa
func _poligono(h: String, rid := 1.0) -> PackedVector2Array:
	var c = g.mappa.centro(h)
	var r = g.mappa.raggio() * rid
	var ry: float = g.mappa.griglia["sy"] * g.mappa.griglia["scala"] * rid
	var p = PackedVector2Array()
	for i in 6:
		var a = deg_to_rad(60 * i - 30)
		p.append(c + Vector2(cos(a) * r, sin(a) * ry))
	return p

func _riempi(c: CanvasItem, h: String, col: Color) -> void:
	c.draw_colored_polygon(_poligono(h, 0.96), col)

func _bordo(c: CanvasItem, h: String, col: Color, w := 3.0) -> void:
	var p = _poligono(h, 0.95)
	p.append(p[0])
	c.draw_polyline(p, col, w)

func disegna(c: CanvasItem) -> void:
	if g.s.is_empty(): return
	var m = g.mappa
	# campo di fuoco della posizione sotto il mouse
	if chk_campi.button_pressed and hover_pid != "":
		var campo = m.campo(hover_pid)
		var col: Color = COLORI[g.colore(hover_pid)]
		for h in campo:
			var a: float = [0.0, 0.18, 0.32, 0.5][int(campo[h])]
			_riempi(c, h, Color(col.r, col.g, col.b, a))
		for h in m.posizioni[hover_pid]["hex"]:
			_bordo(c, h, col, 5.0)
	# ostacoli bonificati
	for h in g.s["bonificati"]:
		var t = _t("bonificato")
		if t: c.draw_texture_rect(t, Rect2(m.centro(h) + Vector2(-14, 26), Vector2(28, 28)), false)
	# bersagli dell'azione in corso
	for h in bersagli:
		_riempi(c, h, Color(0.9, 0.1, 0.1, 0.30))
		_bordo(c, h, Color(1, 0.2, 0.2), 4.0)
	# movimenti possibili
	if not sel.is_empty() and sel["dove"] == "mappa" and modo == "":
		var mm = g.mosse(sel)
		for h in mm:
			var col2 = {"muovi": Color(0.2, 0.9, 0.3, 0.35), "autocons": Color(0.2, 0.75, 0.95, 0.4), "duna": Color(1.0, 0.65, 0.1, 0.4), "scogliera": Color(1.0, 0.3, 0.1, 0.4), "fine_scogliera": Color(1.0, 0.3, 0.1, 0.4)}[mm[h]]
			_riempi(c, h, col2)
	if hover != "" and m.esagoni.has(hover):
		_bordo(c, hover, Color(1, 1, 0.6, 0.8), 2.0)
	# posizioni tedesche
	var lato = 46.0
	for pid in g.s["de"]:
		var de: Dictionary = g.s["de"][pid]
		var h: String = m.posizioni[pid]["hex"][0]
		var cen = m.centro(h)
		if g._fumo(pid):
			var tf = _t("fumo")
			if tf: c.draw_texture_rect(tf, Rect2(cen - Vector2(34, 34), Vector2(68, 68)), false, Color(1, 1, 1, 0.85))
		if de["u"].is_empty(): continue
		var p = cen - Vector2(lato / 2, lato / 2) + Vector2(-4, -2)
		if not de["dm"].is_empty():
			var dm: Dictionary = de["dm"]
			var tdm = _t(g.def_tedeschi["dm"][dm["p"]][dm["i"]]["img"] if dm["riv"] else "dm_%s_retro" % ("edificio" if dm["p"] == "edificio" else dm["p"]))
			if tdm: c.draw_texture_rect(tdm, Rect2(p + Vector2(9, 9), Vector2(lato, lato)), false)
			c.draw_rect(Rect2(p + Vector2(9, 9), Vector2(lato, lato)), Color(0, 0, 0, 0.7), false, 1.5)
		var nome_t = "wn_retro"
		var u: Dictionary = de["u"]
		if u["riv"]:
			nome_t = g.def_tedesca(pid)["img"]
		elif u["k"] != "wn":
			nome_t = "r_retro"
		var tt = _t(nome_t)
		if tt: c.draw_texture_rect(tt, Rect2(p, Vector2(lato, lato)), false)
		c.draw_rect(Rect2(p, Vector2(lato, lato)), Color(0, 0, 0, 0.8), false, 1.5)
		if de["conf"]:
			var tc = _t("confusione_de")
			if tc: c.draw_texture_rect(tc, Rect2(p + Vector2(lato - 14, -10), Vector2(26, 26)), false)
	# unità US sulla mappa e nei riquadri
	var gruppi = {}
	for u in g.s["us"]:
		var h = ""
		if u["dove"] == "mappa": h = u["hex"]
		elif u["dove"] == "box": h = m.box[u["box"]]["box"]
		else: continue
		if not gruppi.has(h): gruppi[h] = []
		gruppi[h].append(u)
	for h in gruppi:
		var lista: Array = gruppi[h]
		var cen = m.centro(h)
		var comb = lista.filter(func(x): return not g.leader(x))
		var lead = lista.filter(func(x): return g.leader(x))
		var n = comb.size()
		var dim = 54.0 if n <= 2 else 40.0
		for i in n:
			var u: Dictionary = comb[i]
			var p = cen + Vector2(-n * (dim + 2) / 2.0 + i * (dim + 2), -dim / 2 - 6)
			_pedina(c, u, Rect2(p, Vector2(dim, dim)))
		for i in lead.size():
			var u: Dictionary = lead[i]
			var p = cen + Vector2(-lead.size() * 16 + i * 32, dim / 2 - 4)
			_pedina(c, u, Rect2(p, Vector2(30, 30)))

func _pedina(c: CanvasItem, u: Dictionary, r: Rect2) -> void:
	var nome: String = g.passo(u)["img"]
	if g.tipo(u) == "generale" and u["ferito"]:
		nome = nome + "_ferito"
	var t = _t(nome)
	if t: c.draw_texture_rect(t, r, false)
	else: c.draw_rect(r, Color(0.3, 0.5, 0.2))
	var bordo = Color(0, 0, 0, 0.85)
	var w = 1.5
	if not sel.is_empty() and sel["id"] == u["id"]:
		bordo = Color(1, 0.95, 0.2); w = 3.5
	c.draw_rect(r, bordo, false, w)
	if u["agito"] and g.s["fase"] == "azioni":
		c.draw_rect(r, Color(0, 0, 0, 0.35))
	var s = r.size.x * 0.42
	if u["conf"] > 0:
		var tc = _t("confusione_us")
		if tc: c.draw_texture_rect(tc, Rect2(r.position + Vector2(r.size.x - s * 0.7, -s * 0.3), Vector2(s, s)), false)
	if u["scalata"] != "":
		var ts = _t("scalata_scogliera" if u["scalata"].begins_with("scogliera") else "scalata")
		if ts: c.draw_texture_rect(ts, Rect2(r.position + Vector2(-s * 0.3, r.size.y - s * 0.7), Vector2(s, s)), false)
	if u["eroe"] >= 0:
		var te = _t(("ispirato_%d_%d" if u["ispirato"] else "eroe_%d_%d") % [u["div"], u["eroe"]])
		if te: c.draw_texture_rect(te, Rect2(r.position + Vector2(r.size.x - s * 0.7, r.size.y - s * 0.7), Vector2(s, s)), false)
	if u["cmd"] != u["div"]:
		c.draw_circle(r.position + Vector2(4, 4), 4.0, Color(0.1, 0.4, 0.9))

# ================================================================ input sulla mappa
func _unhandled_input(ev: InputEvent) -> void:
	if g.s.is_empty() or menu.visible: return
	if ev is InputEventMouseButton:
		var mb = ev as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_WHEEL_UP and mb.pressed:
			_zoom(1.12, mb.position)
		elif mb.button_index == MOUSE_BUTTON_WHEEL_DOWN and mb.pressed:
			_zoom(1 / 1.12, mb.position)
		elif mb.button_index in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT, MOUSE_BUTTON_MIDDLE]:
			if mb.pressed:
				trascina = true
				trascinato = 0.0
				ultimo_mouse = mb.position
			else:
				trascina = false
				if mb.button_index == MOUSE_BUTTON_LEFT and trascinato < 8.0:
					_click(_al_mondo(mb.position))
				elif mb.button_index == MOUSE_BUTTON_RIGHT and trascinato < 8.0:
					_annulla()
	elif ev is InputEventMouseMotion:
		var mm = ev as InputEventMouseMotion
		if trascina:
			var d = mm.position - ultimo_mouse
			trascinato += d.length()
			cam.position -= d / cam.zoom.x
			ultimo_mouse = mm.position
		_aggiorna_hover(_al_mondo(mm.position))
	elif ev is InputEventMagnifyGesture:
		_zoom((ev as InputEventMagnifyGesture).factor, (ev as InputEventMagnifyGesture).position)
	elif ev is InputEventPanGesture:
		cam.position += (ev as InputEventPanGesture).delta * 12.0 / cam.zoom.x

func _al_mondo(p: Vector2) -> Vector2:
	return get_viewport().get_canvas_transform().affine_inverse() * p

func _zoom(f: float, schermo: Vector2) -> void:
	var prima = _al_mondo(schermo)
	var z: float = clamp(cam.zoom.x * f, 0.2, 2.5)
	cam.zoom = Vector2(z, z)
	var dopo = _al_mondo(schermo)
	cam.position += prima - dopo

func _aggiorna_hover(p: Vector2) -> void:
	var h = g.mappa.da_pixel(p)
	if h == hover: return
	hover = h
	hover_pid = g.pos_di(h) if g.tedesco_in(h) else ""
	var m = g.mappa
	var t = ""
	if m.esagoni.has(h):
		t = "Esagono %s - %s" % [h, _nome_terreno(h)]
		var extra: Array = []
		if m.edifici(h): extra.append("edifici")
		if m.esagoni[h].get("ost", 0) == 1: extra.append("ostacoli" + (" bonificati" if g.s["bonificati"].has(h) else ""))
		if m.bassa_set.has(h): extra.append("linea di bassa marea")
		if m.media_set.has(h): extra.append("linea di marea media")
		if m.alta_set.has(h): extra.append("linea di alta marea")
		if m.protezione.has(h): extra.append("riparo")
		if m.hex_pos.has(h): extra.append("posizione " + g.nome_pos(m.hex_pos[h]))
		if not extra.is_empty(): t += " (" + ", ".join(extra) + ")"
	lbl_hover.text = t
	tavolo.queue_redraw()

func _nome_terreno(h: String) -> String:
	return {"spiaggia": "spiaggia", "pianoro": "pianoro/valle", "altura": "altura", "bocage": "bocage", "bosco": "bosco", "accidentato": "terreno accidentato"}.get(g.mappa.terreno(h), "")

func _annulla() -> void:
	modo = ""
	bersagli = {}
	tavolo.queue_redraw()
	_aggiorna()

func _modo(m: String) -> void:
	if g.s["fase"] != "azioni": return
	modo = m
	bersagli = {}
	for pid in g.pos_attive():
		for h in g.mappa.posizioni[pid]["hex"]:
			if not g.tedesco_in(h): continue
			if m == "attacco" and g.attaccabile(h) and g.candidati_attacco(h).any(func(x): return g.fanteria(x) and Mappa.distanza(x["hex"], h) == 1): bersagli[h] = true
			if m == "sbarramento" and not sel.is_empty() and g.puo_sbarrare(sel, h) == "": bersagli[h] = true
			if m == "navale" and g.puo_navale(h) == "": bersagli[h] = true
	if bersagli.is_empty():
		_avviso({"attacco": "Nessuna posizione tedesca può essere attaccata ora: serve una fanteria adiacente che non abbia ancora agito.", "sbarramento": "Questo carro non ha bersagli per il fuoco di sbarramento.", "navale": "Nessun bersaglio per il fuoco navale: serve una fanteria con radio nel campo di fuoco della posizione."}[m])
		modo = ""
	tavolo.queue_redraw()
	_aggiorna()

func _click(p: Vector2) -> void:
	var h = g.mappa.da_pixel(p)
	if modo != "":
		if bersagli.has(h):
			var m = modo
			modo = ""
			bersagli = {}
			if m == "attacco": _finestra_attacco(h)
			elif m == "sbarramento": _referto(g.sbarramento(sel, h))
			elif m == "navale": _referto(g.navale(h))
		else:
			_annulla()
		_dopo_azione()
		return
	if not sel.is_empty() and g.s["fase"] == "azioni":
		var mm = g.mosse(sel)
		if mm.has(h):
			var comp = {}
			if chk_pila.button_pressed:
				for u in g.unita_in(sel["hex"]):
					if u != sel and not u["agito"] and not g.leader(u): comp = u
			var e = g.muovi(sel, h, comp)
			if e != "": _avviso(e)
			_dopo_azione()
			return
	# selezione: unità della mappa o del riquadro di sbarco
	var qui: Array = g.unita_in(h)
	for b in g.mappa.box:
		if g.mappa.box[b]["box"] == h:
			qui = g.in_box(b)
	if qui.is_empty():
		sel = {}
		if g.tedesco_in(h): _info_tedesco(g.pos_di(h))
		else: _aggiorna()
		tavolo.queue_redraw()
		return
	var i = -1
	for k in qui.size():
		if not sel.is_empty() and qui[k]["id"] == sel["id"]: i = k
	sel = qui[(i + 1) % qui.size()]
	_aggiorna()
	tavolo.queue_redraw()

func _dopo_azione() -> void:
	if not sel.is_empty() and sel["dove"] != "mappa" and sel["dove"] != "box":
		sel = {}
	_aggiorna()
	tavolo.queue_redraw()

# ================================================================ pannello unità
func _pulisci(c: Node) -> void:
	for x in c.get_children():
		x.queue_free()

func _aggiorna() -> void:
	if g.s.is_empty(): return
	var t: int = g.s["turno"]
	lbl_turno.text = "Turno %d  -  ore %s" % [t, Gioco.ORARI[t] if t < Gioco.ORARI.size() else ""]
	var fasi = {"azioni": "Fase delle azioni US", "fine_partita": "Partita conclusa"}
	lbl_fase.text = "%s - %s - %s.  Fuoco navale: %d." % [g.nome_scenario(), g.nome_marea(), fasi.get(g.s["fase"], g.s["fase"]), g.s["navali"]]
	var perd: Dictionary = g.s["perdite"]
	if g.easy():
		lbl_azioni.text = "Azioni 1ª Divisione: %d   |   Perdite fanteria: %d/8" % [g.s["azioni"]["1"], perd["1"].size()]
	else:
		lbl_azioni.text = "Azioni: 1ª Div %d, 29ª Div %d   |   Perdite fanteria: 1ª %d/8, 29ª %d/8" % [g.s["azioni"]["1"], g.s["azioni"]["29"], perd["1"].size(), perd["29"].size()]
	btn_fine.disabled = g.s["fase"] != "azioni"
	btn_navale.disabled = g.s["fase"] != "azioni" or g.s["navali"] <= 0
	btn_navale.text = "Fuoco navale (%d)" % g.s["navali"]
	var ev = ""
	if g.s["carte_turno"].has("evento"):
		var n: int = g.s["carte_turno"]["evento"]
		for e in g.carta(n)["eventi"]:
			if t >= e["da"] and t <= e["a"]: ev = "Evento (carta %d): %s" % [n, e["testo"]]
	lbl_evento.text = ev
	vista_carte.queue_redraw()
	_pulisci(box_unita)
	if modo != "":
		box_unita.add_child(_label({"attacco": "Scegli la posizione tedesca da attaccare (in rosso). Clic destro per annullare.", "sbarramento": "Scegli la posizione su cui sparare (in rosso).", "navale": "Scegli la posizione da colpire con il fuoco navale (in rosso)."}[modo], 16, null, Color(1, 0.75, 0.6)))
		return
	if sel.is_empty():
		box_unita.add_child(_label("Clicca un'unità per selezionarla (clic ripetuti sullo stesso esagono passano all'unità successiva). Trascina per spostare la mappa, rotellina per lo zoom.", 15, null, C_KAKI))
		_arrivi()
		return
	var u = sel
	var d = g.defu(u)
	var hb = HBoxContainer.new()
	var img = TextureRect.new()
	img.texture = _t(g.passo(u)["img"])
	img.custom_minimum_size = Vector2(96, 96)
	img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	hb.add_child(img)
	var vv = VBoxContainer.new()
	vv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vv.add_child(_label(u["id"], 22, f_titoli, C_KAKI))
	var tipi = {"fanteria": "Compagnia di fanteria", "pesante": "Fanteria pesante (gittata 2)", "ranger": "Ranger", "carro": "Carri (mezza compagnia)", "antiaerea": "Contraerea", "antiaerea_sp": "Contraerea semovente", "anticarro": "Anticarro", "artiglieria": "Artiglieria", "artiglieria_sp": "Artiglieria semovente", "hq": "Quartier generale", "generale": "Generale"}
	vv.add_child(_label("%s - %s Divisione" % [tipi.get(d["tipo"], d["tipo"]), "1ª" if u["div"] == 1 else "29ª"], 15))
	if not g.leader(u):
		var p = g.passo(u)
		vv.add_child(_label("Punti forza %d - attacco %d - gittata %s - simbolo %s" % [g.passi_rimasti(u), p["a"], "illimitata" if p["g"] >= 99 else str(int(p["g"])), Gioco.SIMBOLI.get(p["s"], "")], 15))
	hb.add_child(vv)
	box_unita.add_child(hb)
	var stato: Array = []
	if u["dove"] == "box": stato.append("nel riquadro di sbarco %s: sbarca il prossimo turno" % u["box"])
	if u["conf"] > 0: stato.append("in confusione")
	if u["scalata"] == "duna": stato.append("segnalino Scalata")
	if u["scalata"].begins_with("scogliera"): stato.append("sta scalando la scogliera")
	if u["eroe"] >= 0: stato.append("Ispirata" if u["ispirato"] else "con un Eroe")
	if u["dove"] == "mappa" and g.s["fase"] == "azioni":
		if u["agito"]: stato.append("ha già agito")
		elif g.gratuita(u): stato.append("azione gratuita")
		if g.in_comando(u): stato.append("sotto comando")
	if not stato.is_empty():
		box_unita.add_child(_label("Stato: " + ", ".join(stato) + ".", 15, null, C_KAKI))
	if fanteria_o_altro(u):
		var armi: Array = []
		if g.fanteria(u) and u["passo"] == 0:
			armi = Gioco.ARMI_PIENE.duplicate()
			if d["tipo"] == "pesante": armi.append("MG")
		elif g.fanteria(u):
			armi = g.passo(u)["armi"]
		else:
			armi = {"carro": ["AR", "BZ", "MG", "BR"], "antiaerea": ["MG", "BR"], "antiaerea_sp": ["MG", "BR"], "artiglieria": ["AR", "MO", "DE"], "artiglieria_sp": ["AR", "MO", "DE"], "anticarro": ["AR", "BZ"]}.get(d["tipo"], [])
		box_unita.add_child(_label("Armi: " + ", ".join(armi.map(func(a): return Gioco.NOMI_ARMI.get(a, a))), 15))
	if u["dove"] == "mappa" and g.s["fase"] == "azioni" and not u["agito"]:
		var r = VBoxContainer.new()
		if u["conf"] > 0:
			r.add_child(_bottone("Togli confusione", func(): g.togli_confusione(u); _dopo_azione()))
		elif u["scalata"] == "duna":
			r.add_child(_bottone("Completa la scalata", func(): g.togli_scalata(u); _dopo_azione()))
		elif u["scalata"].begins_with("scogliera"):
			r.add_child(_label("Clicca l'esagono arancio per superare la scogliera, oppure:", 14))
			r.add_child(_bottone("Rinuncia", func(): g.togli_scalata(u); _dopo_azione()))
		else:
			var rb = HBoxContainer.new()
			if not g.leader(u):
				rb.add_child(_bottone("Attacca", func(): _modo("attacco")))
			if g.tipo(u) == "carro":
				rb.add_child(_bottone("Fuoco di sbarramento", func(): _modo("sbarramento")))
			r.add_child(rb)
			if g.mosse(u).is_empty():
				r.add_child(_label("Nessun movimento possibile" + ("" if g.puo_agire(u) else ": la Divisione ha finito le azioni") + ".", 14))
			else:
				r.add_child(_label("Esagoni colorati: verde movimento, azzurro riparo gratuito, arancio scalata.", 14, null, C_KAKI))
		box_unita.add_child(r)

func fanteria_o_altro(u: Dictionary) -> bool:
	return not g.leader(u)

func _arrivi() -> void:
	var t: int = g.s["turno"]
	var prossimi = g.s["us"].filter(func(u): return u["dove"] == "traccia")
	if prossimi.is_empty(): return
	var per = {}
	for u in prossimi:
		var a: int = u["arrivo"]
		if not per.has(a): per[a] = []
		per[a].append(u["id"])
	var ks = per.keys()
	ks.sort()
	var righe: Array = []
	for k in ks.slice(0, 3):
		righe.append("Turno %d: %s" % [k, ", ".join(per[k])])
	box_unita.add_child(_label("In arrivo - " + " | ".join(righe), 14, null, C_KAKI))

func _info_tedesco(pid: String) -> void:
	_pulisci(box_unita)
	var de: Dictionary = g.s["de"][pid]
	box_unita.add_child(_label(g.nome_pos(pid), 22, f_titoli, COLORI[g.colore(pid)]))
	var righe: Array = []
	var tipo = "Widerstandsnest" if g.mappa.posizioni[pid]["tipo"] == "WN" else "posizione di rinforzo"
	righe.append("%s, colore %s." % [tipo, g.colore(pid)])
	if de["u"]["riv"]:
		righe.append("Unità rivelata: " + g.descrivi_tedesco(pid) + ".")
		var dd = g.def_tedesca(pid)
		if dd.get("cal", "") in ["75", "88"]: righe.append("Artiglieria calibro %s." % dd["cal"])
	else:
		righe.append("Unità non rivelata.")
	if not de["dm"].is_empty():
		if de["dm"]["riv"]:
			var dm = g.def_dm(pid)
			righe.append("Segnalino Incognita rivelato: forza %d, armi %s." % [dm["forza"], ", ".join(dm["armi"]) if not dm["armi"].is_empty() else "nessuna"])
		else:
			righe.append("Con un segnalino Incognita nascosto.")
	if de["conf"]: righe.append("In confusione: non spara finché il suo colore non esce su una carta fuoco.")
	if g.s["attaccati"].has(pid): righe.append("Già attaccata in questo turno.")
	righe.append("Passa il mouse sulla posizione per vederne il campo di fuoco.")
	box_unita.add_child(_label("\n".join(righe), 15))

# ================================================================ finestre
func _pannello_finestra(titolo: String, larg := 560.0) -> VBoxContainer:
	_pulisci(finestra)
	finestra.mouse_filter = Control.MOUSE_FILTER_STOP
	var velo = ColorRect.new()
	velo.color = Color(0, 0, 0, 0.45)
	velo.set_anchors_preset(Control.PRESET_FULL_RECT)
	finestra.add_child(velo)
	var p = PanelContainer.new()
	p.anchor_left = 0.5; p.anchor_top = 0.5; p.anchor_right = 0.5; p.anchor_bottom = 0.5
	p.offset_left = -larg / 2; p.offset_right = larg / 2
	p.offset_top = -300; p.offset_bottom = 300
	finestra.add_child(p)
	var sc = ScrollContainer.new()
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	p.add_child(sc)
	var v = VBoxContainer.new()
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.add_theme_constant_override("separation", 8)
	sc.add_child(v)
	v.add_child(_label(titolo, 24, f_titoli, C_KAKI))
	return v

func _chiudi() -> void:
	_pulisci(finestra)
	finestra.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _referto(testo: String) -> void:
	var v = _pannello_finestra("Resoconto")
	var l = _label(testo, 16, f_macchina)
	v.add_child(l)
	v.add_child(_bottone("Continua", _chiudi))
	_dopo_azione()

func _avviso(testo: String) -> void:
	var v = _pannello_finestra("Attenzione", 480)
	v.add_child(_label(testo, 17))
	v.add_child(_bottone("Ho capito", _chiudi))

func _finestra_attacco(T: String) -> void:
	var pid = g.pos_di(T)
	var v = _pannello_finestra("Attacco contro %s (%s)" % [g.nome_pos(pid), T], 640)
	var de: Dictionary = g.s["de"][pid]
	var info = "Difensore: " + (g.descrivi_tedesco(pid) if de["u"]["riv"] else "unità non ancora rivelata")
	if not de["dm"].is_empty():
		info += "; segnalino Incognita " + (("rivelato (forza %d, armi %s)" % [g.def_dm(pid)["forza"], ", ".join(g.def_dm(pid)["armi"])]) if de["dm"]["riv"] else "nascosto")
	v.add_child(_label(info + ".", 15, null, C_KAKI))
	v.add_child(_label("Scegli le unità che partecipano (ognuna usa un'azione, gratuita se ne ha diritto):", 15))
	var cand = g.candidati_attacco(T)
	var checks: Array = []
	for u in cand:
		var cb = CheckBox.new()
		var d = Mappa.distanza(u["hex"], T)
		cb.text = "%s - attacco %d - %s - armi %s%s" % [u["id"], g.attacco(u), "adiacente" if d == 1 else "a distanza %d" % d, ",".join(g.armi_unita(u, T)), " - gratuita" if g.gratuita(u) else ""]
		cb.button_pressed = g.fanteria(u) and d == 1
		v.add_child(cb)
		checks.append([cb, u])
	var chk_nav = CheckBox.new()
	chk_nav.text = "Aggiungi il fuoco navale (+9, armi AR, DE, NA) - ne hai %d" % g.s["navali"]
	chk_nav.disabled = g.s["navali"] <= 0
	v.add_child(chk_nav)
	var chk_log = CheckBox.new()
	chk_log.text = "Accetta il logoramento se il risultato lo permette (perdi un punto forza per eliminare il segnalino Incognita)"
	chk_log.button_pressed = true
	v.add_child(chk_log)
	var anteprima = _label("", 15, null, Color(1, 0.9, 0.6))
	v.add_child(anteprima)
	var aggiorna_ant = func():
		var lista: Array = []
		for c in checks:
			if c[0].button_pressed: lista.append(c[1])
		var e = g.verifica_attacco(T, lista)
		if e != "":
			anteprima.text = e
			return
		var val = g.valuta(T, lista, chk_nav.button_pressed)
		var arm: Array = val["armi"].keys()
		anteprima.text = "Forza d'attacco %d. Armi disponibili: %s.%s" % [val["forza"], ", ".join(arm), " Eroe presente." if val["eroe"] else ""]
	for c in checks:
		c[0].toggled.connect(func(_x): aggiorna_ant.call())
	chk_nav.toggled.connect(func(_x): aggiorna_ant.call())
	aggiorna_ant.call()
	var r = HBoxContainer.new()
	r.add_child(_bottone("Attacca!", func():
		var lista: Array = []
		for c in checks:
			if c[0].button_pressed: lista.append(c[1])
		var e = g.verifica_attacco(T, lista)
		if e != "":
			anteprima.text = e
			return
		_chiudi()
		_referto(g.attacca(T, lista, chk_nav.button_pressed, chk_log.button_pressed))))
	r.add_child(_bottone("Annulla", _chiudi))
	v.add_child(r)

# ================================================================ flusso del turno
func _fine_azioni() -> void:
	if g.s["fase"] != "azioni": return
	var fermi = g.sulla_mappa().filter(func(u): return g.combattenti_in(u["hex"]).size() > 2)
	if not fermi.is_empty():
		var v = _pannello_finestra("Troppe unità", 520)
		v.add_child(_label("In alcuni esagoni ci sono più di due unità: a fine fase quelle in eccesso verranno eliminate (7.63). Vuoi davvero chiudere la fase?", 16))
		var r = HBoxContainer.new()
		r.add_child(_bottone("Chiudi comunque", func(): _chiudi(); _avanza()))
		r.add_child(_bottone("Torna alle azioni", _chiudi))
		v.add_child(r)
		return
	_avanza()

func _avanza() -> void:
	sel = {}
	modo = ""
	bersagli = {}
	registro_txt.append_text("\n")
	g.fine_azioni()
	_salva_locale()
	_aggiorna()
	tavolo.queue_redraw()
	if g.s["fine"] != "":
		_finale()

func _turno_automatico() -> void:
	if g.s["fase"] != "azioni": return
	bot.gioca_turno()
	_aggiorna()
	tavolo.queue_redraw()

func _finale() -> void:
	var v = _pannello_finestra("Vittoria!" if g.s["fine"] == "vittoria" else "Sconfitta", 560)
	var testo: Array = []
	for r in g.s["log"].slice(max(0, g.s["log"].size() - 3)):
		if r[2] == "finale": testo.append(r[1])
	v.add_child(_label("\n\n".join(testo), 17))
	v.add_child(_bottone("Guarda la mappa", _chiudi))
	v.add_child(_bottone("Nuova partita", func(): _chiudi(); _mostra_menu()))

func _su_registro(t: String, tipo: String) -> void:
	var col = {"turno": "#e8d48a", "titolo": "#e8d48a", "danno": "#ff9a8a", "evento": "#a8d8ff", "carta": "#c8c8b0", "tedesco": "#ffc070", "attacco": "#ffffff", "sbarco": "#b8e0b0", "eroe": "#ffe066", "finale": "#7dff9a", "azione": "#d8e8c8"}.get(tipo, "#d8d4c0")
	if tipo == "turno":
		registro_txt.append_text("\n[b][color=%s]%s[/color][/b]\n" % [col, t])
	else:
		registro_txt.append_text("[color=%s]%s[/color]\n" % [col, t])

# ================================================================ menu e salvataggi
func _mostra_menu() -> void:
	_pulisci(menu)
	menu.visible = true
	var sf = ColorRect.new()
	sf.color = Color(0.05, 0.07, 0.08, 0.92)
	sf.set_anchors_preset(Control.PRESET_FULL_RECT)
	menu.add_child(sf)
	var p = PanelContainer.new()
	p.anchor_left = 0.5; p.anchor_top = 0.5; p.anchor_right = 0.5; p.anchor_bottom = 0.5
	p.offset_left = -330; p.offset_right = 330; p.offset_top = -330; p.offset_bottom = 330
	menu.add_child(p)
	var v = VBoxContainer.new()
	v.add_theme_constant_override("separation", 10)
	p.add_child(v)
	var t1 = _label("D-DAY AT", 30, f_titoli, Color(0.15, 0.62, 0.32))
	t1.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(t1)
	var t2 = _label("OMAHA BEACH", 58, f_titoli, Color(0.15, 0.62, 0.32))
	t2.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(t2)
	var t3 = _label("6 giugno 1944 - gioco in solitario di John H. Butterfield (Decision Games). I tedeschi sono gestiti dal gioco: tu guidi la 1ª e la 29ª Divisione US all'assalto della spiaggia.", 16, null, C_KAKI)
	t3.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(t3)
	v.add_child(HSeparator.new())
	v.add_child(_bottone("Easy Fox - scenario introduttivo (solo settore Est, 1ª Divisione)", func(): _nuova("easy_fox")))
	v.add_child(_bottone("La prima ondata - turni 1-16, tutta la spiaggia", func(): _nuova("prima_ondata")))
	if FileAccess.file_exists(SALVATAGGIO):
		v.add_child(_bottone("Continua la partita salvata su questo dispositivo", _carica_locale))
	if not g.s.is_empty() and g.s["fine"] == "":
		v.add_child(_bottone("Torna alla partita in corso", func(): menu.visible = false))
	v.add_child(HSeparator.new())
	var r = HBoxContainer.new()
	var le = LineEdit.new()
	le.placeholder_text = "codice della partita online"
	le.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	r.add_child(le)
	var esito = _label("", 15, null, C_KAKI)
	r.add_child(_bottone("Riprendi online", func(): _carica_online(le.text.strip_edges().to_upper(), esito)))
	v.add_child(r)
	v.add_child(esito)
	v.add_child(_bottone("Regole in breve", _regole))

func _nuova(scen: String) -> void:
	registro_txt.clear()
	g.nuova(scen)
	menu.visible = false
	sel = {}
	cam.position = g.mappa.centro("0712" if scen == "easy_fox" else "0718")
	cam.zoom = Vector2(0.55, 0.55)
	_salva_locale()
	_aggiorna()
	tavolo.queue_redraw()

func _salva_locale() -> void:
	var f = FileAccess.open(SALVATAGGIO, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(g.esporta()))

func _ricostruisci_registro() -> void:
	registro_txt.clear()
	for r in g.s["log"]:
		_su_registro(r[1], r[2])

func _carica_locale() -> void:
	var f = FileAccess.open(SALVATAGGIO, FileAccess.READ)
	if not f: return
	var d = JSON.parse_string(f.get_as_text())
	if not (d is Dictionary): return
	g.importa(d)
	_dopo_caricamento()

func _dopo_caricamento() -> void:
	menu.visible = false
	sel = {}
	_ricostruisci_registro()
	_aggiorna()
	tavolo.queue_redraw()
	if g.s["fine"] != "":
		_finale()

func _codice() -> String:
	var c = ""
	var lettere = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
	for i in 6:
		c += lettere[randi() % lettere.length()]
	return c

func _salva_online() -> void:
	if g.s.is_empty(): return
	if not g.s.has("codice"):
		g.s["codice"] = _codice()
	var v = _pannello_finestra("Salvataggio online", 480)
	var l = _label("Salvataggio in corso...", 17)
	v.add_child(l)
	var ok: bool = await net.salva_partita(g.s["codice"], {"nome": g.nome_scenario(), "turno": g.s["turno"], "aggiornata": int(Time.get_unix_time_from_system())}.merged(g.esporta()))
	if ok:
		l.text = "Partita salvata. Codice: %s\nScrivilo per riprenderla da qualsiasi dispositivo (Menu, Riprendi online)." % g.s["codice"]
	else:
		l.text = "Salvataggio non riuscito: %s" % net.ultimo_errore
	v.add_child(_bottone("Chiudi", _chiudi))

func _carica_online(codice: String, esito: Label) -> void:
	if codice.length() != 6:
		esito.text = "Il codice ha 6 caratteri."
		return
	esito.text = "Caricamento..."
	var d = await net.carica_partita(codice)
	if d == null or not (d is Dictionary) or not d.has("s"):
		esito.text = "Partita non trovata (%s)." % net.ultimo_errore
		return
	g.importa(d)
	_dopo_caricamento()

func _regole() -> void:
	var v = _pannello_finestra("Regole in breve", 700)
	var testo = """Ogni turno (15 minuti) il gioco risolve da solo: controlli sullo sbarco (carta Sbarco per settore: derive, ritardi, perdite, mine), sbarco sulla spiaggia secondo la marea, evento, fuoco tedesco (carta Fuoco per settore: sparano le posizioni dei colori indicati; quadrato doppio = serve il segnalino Incognita; stella = può colpire i leader; carro = colpisce i corazzati), artiglieria tedesca (dal turno 4) e bonifica degli ostacoli del Genio.

Poi tocca a te. Ogni Divisione ha 2 azioni per turno; ogni unità può fare una sola azione. Sono gratuite le azioni dei Ranger, delle unità con Eroe o Ispirate, dei leader, delle unità adiacenti o nello stesso esagono di un HQ o di un Generale (finché il leader non si muove), il riparo della fanteria sulla spiaggia (movimento verso un esagono più vicino al riparo, in azzurro) e la rimozione dei segnalini Confusione e Scalata.

Movimento: un esagono. La fanteria supera le dune con una scalata (arancio) che richiede un turno in più per togliere il segnalino; le scogliere scalabili richiedono tre turni. Carri, artiglieria e contraerea restano sulla spiaggia e sulle valli. Muovere tra due esagoni adiacenti a una posizione e nel suo campo di fuoco è un'infiltrazione: si pesca una carta e si rischia un punto forza.

Attacco: serve almeno una fanteria adiacente; si sommano le forze e le armi. Se hai tutte le armi richieste dall'unità tedesca e dal suo segnalino Incognita usi la parte alta della tabella, altrimenti quella bassa. L'Eroe sostituisce un'arma o aggiunge 1 alla forza. Il fuoco navale aggiunge 9 e le armi AR, DE, NA. Aggiramento (FL): attacca da due esagoni non adiacenti tra loro.

Alla marea media (turno 7) le unità rimaste sulla linea di bassa marea annegano; idem per la linea media all'alta marea. Più di due unità per esagono a fine fase: le eccedenti sono eliminate.

Vittoria: al turno 16 conta 1 punto per ogni esagono WN controllato, 1 per ogni posizione di rinforzo, 5 per ogni valle (draw). Servono 19 punti (9 in Easy Fox). Perdi subito se otto compagnie di fanteria di una Divisione sono ridotte a un punto o eliminate.

Comandi: clic per selezionare, clic su un esagono colorato per muovere, clic destro per annullare, trascina per spostare la mappa, rotellina per lo zoom. Passa il mouse su una posizione tedesca per vederne il campo di fuoco."""
	v.add_child(_label(testo, 15))
	v.add_child(_bottone("Chiudi", _chiudi))
