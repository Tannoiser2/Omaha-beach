## Prova dei flussi dell'interfaccia (senza grafica): attacchi, sbarramenti, fuoco navale, scalate, salvataggi.
extends SceneTree
var main
var n := 0
func _initialize() -> void:
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
func _process(_d: float) -> bool:
	n += 1
	if n == 3:
		main._nuova(OS.get_environment("SCEN") if OS.get_environment("SCEN") != "" else "prima_ondata")
		var g = main.g
		g.s["navali"] = 3
		for t in 12:
			if g.s["fine"] != "": break
			# prova tutte le azioni possibili per ogni unità
			for u in g.sulla_mappa():
				main.sel = u
				main._aggiorna()
				var mm = g.mosse(u)
				for pid in g.pos_attive():
					var T: String = g.mappa.posizioni[pid]["hex"][0]
					if g.tipo(u) == "carro" and g.puo_sbarrare(u, T) == "":
						main._modo("sbarramento"); main._click(g.mappa.centro(T)); main._chiudi()
					if g.puo_navale(T) == "":
						main._modo("navale"); main._click(g.mappa.centro(T)); main._chiudi()
				if not u["agito"] and not mm.is_empty():
					var k = mm.keys()
					main._click(g.mappa.centro(k[randi() % k.size()]))
			for pid in g.pos_attive():
				var T: String = g.mappa.posizioni[pid]["hex"][0]
				if g.attaccabile(T):
					var c = g.candidati_attacco(T)
					if g.verifica_attacco(T, c) == "":
						main._finestra_attacco(T)
						main._chiudi()
						main._referto(g.attacca(T, c, g.s["navali"] > 0, true))
						main._chiudi()
			main._info_tedesco(g.pos_attive()[0])
			main._avanza()
		print("turno finale ", g.s["turno"], " esito ", g.s["fine"])
		main._salva_locale()
		main._carica_locale()
		print("ricaricata al turno ", main.g.s["turno"])
		main._aiuto(-1); main._chiudi(); main._mostra_menu()
	return n >= 5
