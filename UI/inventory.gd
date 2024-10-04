extends Control

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
	if event.button_index == MOUSE_BUTTON_WHEEL_UP:
		select_next(-1)
		while not selection.active: select_next(-1)

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
