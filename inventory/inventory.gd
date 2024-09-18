extends CanvasLayer

@export var actives: Array[Spell]
@export var passives: Array[Spell]
var selection: int

func _ready() -> void:
	update_graphics()

func _input(event: InputEvent) -> void:
	if not event is InputEventMouseButton: return
	if not event.is_pressed(): return
	if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		selection = posmod(selection+1,6)
		update_graphics()
		print(selection)
	if event.button_index == MOUSE_BUTTON_WHEEL_UP:
		selection = posmod(selection-1,6)
		update_graphics()
		print(selection)


func update_graphics() -> void:
	for child in $HotbarContainer/Hotbars.get_children():
		child.queue_free()
	
	for i in range(0,6):
		var spell = actives[i]
		var spell_icon = TextureRect.new()
		
		if spell:
			spell_icon.texture = spell.icon
		else:
			spell_icon.texture = preload("res://inventory/empty_slot.tres")
		
		spell_icon.self_modulate = Color(1,1,1) if selection == i else Color(0.5,0.5,0.5)
		$HotbarContainer/Hotbars.add_child(spell_icon)
