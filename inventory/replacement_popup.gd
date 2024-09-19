extends PanelContainer


signal chosen

func choose(spell:Spell):
	chosen.emit(spell)
	close_popup()

func open_popup():
	visible = true
	Engine.time_scale = 0

func close_popup():
	visible = false
	Engine.time_scale = 1
