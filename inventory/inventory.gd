extends CanvasLayer

@export var max_actives = 6
@export var max_passives = 6

@export var spells: Array[Spell]

var selection: Spell

func _ready() -> void:
	select_next()
	call_deferred("update_graphics")

func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint(): return
	if not event is InputEventMouseButton: return
	if not event.is_pressed(): return
	if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		select_next()
		while not selection.active: select_next()
		update_graphics()
	if event.button_index == MOUSE_BUTTON_WHEEL_UP:
		select_next(-1)
		while not selection.active: select_next(-1)
		update_graphics()

func replacement_popup(new_spell:Spell) -> Spell:
	for child in $ReplacementPopup/Content/Spells.get_children(): child.queue_free()
	
	for existing_spell in spells:
		if existing_spell.active != new_spell.active: continue
		var spell_button: TextureButton = TextureButton.new()
		spell_button.texture_normal = existing_spell.icon
		spell_button.pressed.connect($ReplacementPopup.choose.bind(existing_spell))
		$ReplacementPopup/Content/Spells.add_child(spell_button)
	
	$ReplacementPopup.open_popup()
	var result = await $ReplacementPopup.chosen
	spells[spells.find(result)] = new_spell
	selection = new_spell
	update_graphics()
	return result

func select_next(direction:int = 1):
	selection = spells[posmod(spells.find(selection)+direction,spells.size())]

func update_graphics() -> void:
	for child in $HotbarContainer/Hotbars/Actives/Spells.get_children(): child.queue_free()
	for child in $HotbarContainer/Hotbars/Passives/Spells.get_children(): child.queue_free()
	
	for spell in spells:
		var spell_icon = TextureRect.new()
		spell_icon.texture = spell.icon
		if spell.active:
			spell_icon.self_modulate = Color(1,1,1) if selection == spell else Color(0.5,0.5,0.5)
			$HotbarContainer/Hotbars/Actives/Spells.add_child(spell_icon)
		else:
			$HotbarContainer/Hotbars/Passives/Spells.add_child(spell_icon)
