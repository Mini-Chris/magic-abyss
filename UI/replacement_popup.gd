extends PanelContainer

signal chosen

func choose(spell:Spell):
	chosen.emit(spell)
	close_popup()

func close_popup():
	visible = false
	Engine.time_scale = 1

func open_popup(new_spell:Spell) -> Spell:
	for child in %ReplaceableSpells.get_children(): child.queue_free()
	
	for existing_spell in UI.inventory.spells:
		if existing_spell.active != new_spell.active: continue
		var spell_button: TextureButton = TextureButton.new()
		spell_button.texture_normal = existing_spell.icon
		spell_button.pressed.connect(choose.bind(existing_spell))
		%ReplaceableSpells.add_child(spell_button)
	
	$PanelContainer/MarginContainer/Content/ReplacementIcon.texture = new_spell.icon
	$PanelContainer/MarginContainer/Content/ReplacementName.text = new_spell.name
	$PanelContainer/MarginContainer/Content/ReplacementDesc.text = new_spell.description
	
	visible = true
	Engine.time_scale = 0
	UI.lockInput = true
	var result = await chosen
	UI.lockInput = false
	print("replacing spell")
	UI.inventory.spells[UI.inventory.spells.find(result)] = new_spell
	UI.inventory.selection = new_spell
	UI.inventory.update_graphics()
	return result
