extends SceneTree
var main
var n := 0
func _initialize() -> void:
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	root.size = Vector2i(1600, 950)
func _process(_d: float) -> bool:
	n += 1
	if n == 5: main._nuova("oltre")
	if n == 7:
		main.bot.gioca_turno(); main._avanza()
		main.cam.zoom = Vector2(0.6, 0.6)
		main.cam.position = main.g.mappa.centro("0920")
		for u in main.g.sulla_mappa():
			if main.g.fanteria(u) and not u["agito"] and not main.g.mosse(u).is_empty():
				main.sel = u; break
		main._aggiorna(); main.tavolo.queue_redraw()
	if n == 12: root.get_texture().get_image().save_png("/tmp/shot_oltre.png")
	return n >= 13
