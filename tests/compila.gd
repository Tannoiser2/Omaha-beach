extends SceneTree
func _init() -> void:
	for f in ["res://scripts/mappa.gd", "res://scripts/gioco.gd", "res://scripts/partita.gd", "res://scripts/bot.gd", "res://scripts/main.gd"]:
		var sc = load(f)
	quit()
