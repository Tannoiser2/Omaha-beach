## Partita D-Day completa fino al turno 32 (le perdite vengono azzerate per arrivare in fondo).
extends SceneTree
func _init() -> void:
	var p := Partita.new()
	p.nuova("dday", 7)
	var bot := Bot.new(p)
	var giri := 0
	while p.s["fine"] == "" and giri < 40:
		bot.gioca_turno()
		p.s["perdite"] = {"1": [], "29": []}
		if p.s["turno"] == 16:
			# il bot non passa il primo controllo: per provare i turni 17-32 salto la fine anticipata
			p.s["scenario"] = "oltre"
		p.fine_azioni()
		if p.s["turno"] == 20:
			var js := JSON.stringify(p.esporta())
			var q := Partita.new()
			q.importa(JSON.parse_string(js))
			p = q
			bot = Bot.new(p)
			print("ricaricata al turno ", p.s["turno"])
		giri += 1
	print("fine: ", p.s["fine"], " turno ", p.s["turno"], " vp ", p.s["vp"])
	print("basi ", p.s["basi"], " cp ", p.s["cp"], " guarnigioni ", p.s["guarnigioni"].size(), " usciti ", p.s["usciti"].size())
	var cont := {}
	for r in p.log_righe:
		for k in ["rioccupano", "rifornisce", "reimpiega", "mortai", "Pattuglia", "avanzano", "respinta", "Imboscata", "artiglieria della", "percorre la strada", "gestione del traffico", "Rinforzo tedesco", "guarnigione"]:
			if r[0].find(k) >= 0: cont[k] = cont.get(k, 0) + 1
	print(cont)
	for r in p.log_righe.slice(p.log_righe.size() - 6): print(r[0])
	quit()
