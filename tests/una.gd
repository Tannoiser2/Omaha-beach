extends SceneTree
func _init() -> void:
	var p := Partita.new()
	p.nuova(OS.get_environment("SCEN") if OS.get_environment("SCEN") != "" else "prima_ondata", int(OS.get_environment("SEME")) if OS.get_environment("SEME") != "" else 11)
	var bot := Bot.new(p)
	var n := int(OS.get_environment("TURNI")) if OS.get_environment("TURNI") != "" else 16
	for i in n:
		if p.s["fine"] != "": break
		bot.gioca_turno()
		p.fine_azioni()
	for r in p.log_righe: print(r[0])
	quit()
