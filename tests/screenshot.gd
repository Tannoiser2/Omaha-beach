## Screenshot di prova: xvfb-run godot --path . --script res://tests/screenshot.gd
extends SceneTree

var main
var n := 0
var passi := []

func _initialize() -> void:
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	root.size = Vector2i(1600, 950)

func _scatta(nome: String) -> void:
	var img := root.get_texture().get_image()
	img.save_png("/tmp/shot_%s.png" % nome)
	print("screenshot ", nome)

func _process(_d: float) -> bool:
	n += 1
	var scen := OS.get_environment("SCEN") if OS.get_environment("SCEN") != "" else "easy_fox"
	if n == 5: _scatta("menu")
	if n == 8: main._nuova(scen)
	if n == 14: _scatta("turno1")
	if n == 16:
		for i in 4:
			main.bot.gioca_turno(); main._avanza()
	if n == 22:
		main.cam.zoom = Vector2(0.9, 0.9)
		main.cam.position = main.g.mappa.centro("0711")
		for u in main.g.sulla_mappa():
			if main.g.fanteria(u) and not u["agito"]:
				main.sel = u; break
		main._aggiorna(); main.tavolo.queue_redraw()
	if n == 26: _scatta("turno5")
	if n == 28:
		for u in main.g.sulla_mappa():
			if main.g.fanteria(u):
				for pid in main.g.pos_attive():
					var T: String = main.g.mappa.posizioni[pid]["hex"][0]
					if main.g.attaccabile(T) and not main.g.candidati_attacco(T).is_empty():
						main._finestra_attacco(T); break
				break
	if n == 32: _scatta("attacco")
	if n == 34:
		main._chiudi(); main._regole()
	if n == 37: _scatta("regole")
	if n == 39: return true
	return false
