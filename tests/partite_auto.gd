## Partite automatiche complete: godot --headless --script res://tests/partite_auto.gd
extends SceneTree

func _init() -> void:
	var risultati := []
	for scen in ["easy_fox", "prima_ondata"]:
		for seme in [11, 22, 33, 44, 55]:
			var p := Partita.new()
			p.nuova(scen, seme)
			var bot := Bot.new(p)
			var giri := 0
			while p.s["fine"] == "" and giri < 40:
				bot.gioca_turno()
				p.fine_azioni()
				giri += 1
			# salvataggio e ricarica
			var js := JSON.stringify(p.esporta())
			var q := Partita.new()
			q.importa(JSON.parse_string(js))
			assert(q.s["turno"] == p.s["turno"])
			var vivi: int = p.s["us"].filter(func(u): return u["dove"] == "mappa").size()
			var ted: int = p.pos_attive().size()
			risultati.append("%s seme %d: %s al turno %d, VP %d, unita' US in mappa %d, posizioni tedesche %d, perdite %d/%d" % [scen, seme, p.s["fine"], p.s["turno"], p.s["vp"], vivi, ted, p.s["perdite"]["1"].size(), p.s["perdite"]["29"].size()])
	for r in risultati: print(r)
	quit()
