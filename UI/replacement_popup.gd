extends PanelContainer

var source: Node2D
signal closing

func open_popup(pickup:Node2D):
	source = pickup
	var new_spell = source.spell
	for child in %CurrentSpells.get_children(): child.queue_free()
	
	$PanelContainer/MarginContainer/Content/NewIcon.texture = new_spell.icon
	$PanelContainer/MarginContainer/Content/NewName.text = new_spell.name
	$PanelContainer/MarginContainer/Content/NewDesc.text = new_spell.description
	if UI.inventory.spells.size() < UI.inventory.max_actives:
		$PanelContainer/MarginContainer/Content/InventoryFull.hide()
		$PanelContainer/MarginContainer/Content/Accept.show()
	else:
		$PanelContainer/MarginContainer/Content/InventoryFull.show()
		$PanelContainer/MarginContainer/Content/Accept.hide()
		for existing_spell in UI.inventory.spells:
			if existing_spell.active != new_spell.active: continue
			var spell_button: TextureButton = TextureButton.new()
			spell_button.texture_normal = existing_spell.icon
			spell_button.pressed.connect(_replace.bind(existing_spell))
			%CurrentSpells.add_child(spell_button)
	
	Engine.time_scale = 0
	UI.lockInput = true
	visible = true

func close_popup():
	closing.emit()
	visible = false
	Engine.time_scale = 1
	UI.lockInput = false
	UI.inventory.update_graphics()


func _replace(old_spell:Spell):
	UI.inventory.spells[UI.inventory.spells.find(old_spell)] = source.spell
	UI.inventory.selection = source.spell
	source.spell = old_spell
	close_popup()

func _cancel() -> void:
	close_popup()

func _accept() -> void:
	UI.inventory.spells.append(source.spell)
	source.queue_free()
	close_popup()
