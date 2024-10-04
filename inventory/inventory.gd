extends CanvasLayer

@export var max_actives = 6
@export var max_passives = 6

@export var spells: Array[Spell]

var selection: Spell
var lockInput: bool = false

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
	if event.button_index == MOUSE_BUTTON_WHEEL_UP:
		select_next(-1)
		while not selection.active: select_next(-1)

func replacement_popup(new_spell:Spell) -> Spell:
	for child in %ReplaceableSpells.get_children(): child.queue_free()
	
	for existing_spell in spells:
		if existing_spell.active != new_spell.active: continue
		var spell_button: TextureButton = TextureButton.new()
		spell_button.texture_normal = existing_spell.icon
		spell_button.pressed.connect($ReplacementPopup.choose.bind(existing_spell))
		%ReplaceableSpells.add_child(spell_button)
	
	$ReplacementPopup/PanelContainer/MarginContainer/Content/ReplacementIcon.texture = new_spell.icon
	$ReplacementPopup/PanelContainer/MarginContainer/Content/ReplacementName.text = new_spell.name
	$ReplacementPopup/PanelContainer/MarginContainer/Content/ReplacementDesc.text = new_spell.description
	
	$ReplacementPopup.open_popup()
	lockInput = true
	var result = await $ReplacementPopup.chosen
	lockInput = false
	print("replacing spell")
	spells[spells.find(result)] = new_spell
	selection = new_spell
	update_graphics()
	return result

func select_next(direction:int = 1):
	var index = posmod(spells.find(selection)+direction,spells.size())
	selection = spells[index]
	%ActiveIndicator.position.x = index * 16

func update_graphics() -> void:
	for child in %ActiveSpells.get_children(): child.queue_free()
	for child in %PassiveSpells.get_children(): child.queue_free()
	%ActiveSpells.custom_minimum_size.x = max_actives*16
	
	for spell in spells:
		var spell_icon = TextureRect.new()
		spell_icon.texture = spell.icon
		if spell.active:
			%ActiveSpells.add_child(spell_icon)
		else:
			%PassiveSpells.add_child(spell_icon)
