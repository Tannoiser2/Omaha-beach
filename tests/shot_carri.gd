extends SceneTree
var main
var n := 0
func _initialize() -> void:
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	root.size = Vector2i(1600, 950)
func _process(_d: float) -> bool:
	n += 1
	if n == 4: root.get_texture().get_image().save_png("/tmp/shot_menu.png")
	if n == 5:
		main.varianti_scelte = {"corazzati": true}
		main._nuova("oltre")
		var g = main.g
		g.s["pool"]["T"] = []
		g.s["turno"] = 17
		g.entra_carro("C6")
		var k = g.s["carri"].keys()[0]
		main.cam.zoom = Vector2(0.8, 0.8)
		main.cam.position = g.mappa.centro("1612")
		main._aggiorna(); main.tavolo.queue_redraw()
	if n == 7:
		main.cam.zoom = Vector2(1.1, 1.1)
		main.cam.position = main.g.mappa.centro("1612")
		main.tavolo.queue_redraw()
	if n == 9: root.get_texture().get_image().save_png("/tmp/shot_carro.png")
	if n == 10:
		main._click_pos("K" + str(main.g.s["carri"].values()[0].get("i", 0))) if main.has_method("_click_pos") else null
	return n >= 11
