extends Control

@export var max_actives = 6
@export var max_passives = 6

@export var spells: Array[Spell]

var selection: Spell:
	set(new):
		selection = new
		%ActiveIndicator.position.x = spells.find(selection) * 16

func _ready() -> void:
	select_next()
	call_deferred("update_graphics")

func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint(): return
	if event.is_action_pressed("select_next"):
		select_next()
		while not selection.active: select_next()
	if Input.is_action_pressed("select_prev"):
		select_next(-1)
		while not selection.active: select_next(-1)

func select_next(direction:int = 1):
	var index = posmod(spells.find(selection)+direction,spells.size())
	selection = spells[index]

func update_graphics() -> void:
	for child in %ActiveSpells.get_children(): child.queue_free()
	for child in %PassiveSpells.get_children(): child.queue_free()
	%ActiveSpells.custom_minimum_size.x = max_actives*16
	
	for spell in spells:
		var spell_icon: TextureButton = TextureButton.new()
		#since we never implmented any, I don't feel the need to support the passive spells here
		#if spell.active:
			#%ActiveSpells.add_child(spell_icon)
		#else:
			#%PassiveSpells.add_child(spell_icon)
		%ActiveSpells.add_child(spell_icon)
		spell_icon.texture_normal = spell.icon
		spell_icon.pressed.connect(func(): selection = spell)
		var shortcut := Shortcut.new()
		var event := InputEventKey.new()
		event.keycode = 48+spells.find(selection)
		event.unicode = 48+spells.find(selection)
		event.device = -1
		shortcut.events = [event]
		spell_icon.shortcut = shortcut
