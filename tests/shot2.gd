extends SceneTree
var main
var n := 0
func _initialize() -> void:
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	root.size = Vector2i(1600, 950)
func _process(_d: float) -> bool:
	n += 1
	if n == 5: main._nuova("prima_ondata")
	if n == 7:
		for i in 3:
			main.bot.gioca_turno(); main._avanza()
		main.cam.zoom = Vector2(0.62, 0.62)
		main.cam.position = main.g.mappa.centro("0626")
		main.hover_pid = "WN70"
		main.tavolo.queue_redraw()
	if n == 12:
		root.get_texture().get_image().save_png("/tmp/shot_ovest.png")
	if n == 13:
		main._finale()
	if n == 16:
		root.get_texture().get_image().save_png("/tmp/shot_fine.png")
	return n >= 17
