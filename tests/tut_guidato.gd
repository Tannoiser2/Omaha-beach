extends SceneTree
var main
var n := 0
func _initialize() -> void:
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	root.size = Vector2i(1600, 950)

func _clicca(h: String) -> void:
	main._click(main.g.mappa.centro(h))

func _trova_bottone(nodo: Node, testo: String) -> Button:
	for c in nodo.get_children():
		if c is Button and c.text == testo and c.is_visible_in_tree(): return c
		var r = _trova_bottone(c, testo)
		if r != null: return r
	return null

func _esegui(tipo: String) -> void:
	var r: Dictionary = main.tut_guida
	if not r.get("ok", false):
		print("   GUIDA NON DISPONIBILE")
		return
	if r["unita"] != "":
		# seleziona finché l'unità selezionata può fare l'azione
		for i in 6:
			_clicca(r["unita"])
			var s = main.sel
			if s.is_empty(): continue
			if tipo in ["riparo", "muovi", "duna", "due_esagoni"] and main.g.mosse(s).has(r["mete"][0]): break
			if tipo == "attacco" and main.g.fanteria(s): break
			if tipo == "sbarramento" and main.g.tipo(s) == "carro": break
			if tipo == "cp" and main.g.tipo(s) == "hq": break
	match tipo:
		"riparo", "muovi", "duna", "due_esagoni": _clicca(r["mete"][0])
		"attacco":
			main._modo("attacco"); _clicca(r["mete"][0])
			await process_frame
			var b = _trova_bottone(main, "Attacca!")
			if b: b.pressed.emit()
			else: print("   bottone Attacca! non trovato")
		"sbarramento":
			main._modo("sbarramento"); _clicca(r["mete"][0])
		"cp":
			var b2 = _trova_bottone(main, "Posto di Comando")
			if b2: b2.pressed.emit()
			else: print("   bottone Posto di Comando non trovato")
		"base":
			main._modo("base1" if "1ª" in r["testo"] else "base29"); _clicca(r["mete"][0])

func _initialize_done() -> void:
	pass

func _process(_d: float) -> bool:
	n += 1
	if n == 5:
		_giro()
	return n >= 400

func _giro() -> void:
	for parte in ["parte1", "parte2"]:
		main._avvia_tutorial(parte)
		var shot = 0
		while not main.tut.is_empty():
			var p = main.tut["passi"][main.tut_i]
			await process_frame
			if p.has("guida"):
				print("%s %d %s -> %s" % [parte, main.tut_i, p["guida"], main.tut_compito.text])
				await process_frame
				await process_frame
				if shot < 3:
					root.get_texture().get_image().save_png("/tmp/tg_%s_%d.png" % [parte, main.tut_i]); shot += 1
				await _esegui(p["guida"])
				main._process(0.1)
				print("   fatto: ", main._compito_fatto())
			elif p.has("compito") and p["compito"]["tipo"] == "turno":
				main.btn_fine.pressed.emit()
				for k in 30:
					await process_frame
					var b = _trova_bottone(main, "Conferma")
					if b: b.pressed.emit()
					if main.g.s["turno"] > 1: break
				print("%s %d turno ora %d" % [parte, main.tut_i, main.g.s["turno"]])
			main._vai_passo(1)
	print("FINE")
	quit()
