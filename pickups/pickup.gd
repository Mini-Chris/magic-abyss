@tool
extends Node2D

@export var spell: Spell:
	set(new):
		if not new: return
		spell = new
		if not is_node_ready(): return
		$Icon.texture = new.icon
		name = spell.name

func _ready() -> void:
	if not spell and not Engine.is_editor_hint(): queue_free()
	$Icon.texture = spell.icon
	name = spell.name

func interact():
	if UI.inventory.spells.has(spell): return
	UI.pickup_popup(self)

func _process(delta: float) -> void:
	$Icon.offset.y = 2.0*sin(Time.get_ticks_msec()/1000.0)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if UI.inventory.spells.has(spell):
		$Status.text = "already held!"
	else:
		$Status.text = "press E to pick up"
		$Icon.modulate = Color(1,1,1)

func _on_area_2d_body_exited(body: Node2D) -> void:
	$Icon.modulate = Color(0.5,0.5,0.5)
	$Status.text = ""
