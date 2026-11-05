extends SceneTree
var main
var n := 0
func _initialize() -> void:
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	root.size = Vector2i(1600, 950)
func _process(_d: float) -> bool:
	n += 1
	if n == 4: root.get_texture().get_image().save_png("/tmp/t_menu.png")
	if n == 5: main._avvia_tutorial("parte1")
	if n == 8:
		for i in 4: main._vai_passo(1)
	if n == 12: root.get_texture().get_image().save_png("/tmp/t_passo5.png")
	if n == 13: main._aiuto(16)
	if n == 17: root.get_texture().get_image().save_png("/tmp/t_aiuto.png")
	if n == 18:
		main._chiudi()
		# percorre tutti i passi delle due parti
		for parte in ["parte1", "parte2"]:
			main._avvia_tutorial(parte)
			for i in 40:
				main._process(0.5)
				main._vai_passo(1)
				if main.tut.is_empty(): break
			print(parte, " completata")
	return n >= 19
