extends SceneTree
func _init() -> void:
	var tutte := {"bombardamento": true, "carri_sicuri": true, "ranger": true, "reazione": true, "corazzati": true}
	for scen in ["easy_fox", "prima_ondata", "dday", "oltre"]:
		for seme in [3, 7, 21]:
			var p := Partita.new()
			p.nuova(scen, seme, tutte)
			if scen in ["dday", "oltre"]:
				p.s["pool"]["T"] = []
			var bot := Bot.new(p)
			var entrati := 0
			var max_carri := 0
			for i in 40:
				if p.s["fine"] != "": break
				bot.gioca_turno()
				p.fine_azioni()
				max_carri = max(max_carri, p.s.get("carri", []).size())
				# salva/carica a metà
				if i == 5:
					var d = p.esporta()
					var q := Partita.new()
					q.importa(JSON.parse_string(JSON.stringify(d)))
					p = q
					bot = Bot.new(p)
			var righe_carro := 0
			for r in p.log_righe:
				if "carro" in str(r[0]).to_lower(): righe_carro += 1
			print("%s seme %d: turno %d fine '%s' carri max %d righe carro %d PV %s" % [scen, seme, p.s["turno"], p.s["fine"], max_carri, righe_carro, str(p.punti_vittoria())])
	quit()
