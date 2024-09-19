@tool
extends Node2D

@export var spell: Spell:
	set(new):
		if not new: return
		spell = new
		if not is_node_ready(): return
		$Sprite2D.texture = new.icon

func _ready() -> void:
	if spell:
		$Sprite2D.texture = spell.icon

func interact():
	if Inventory.spells.has(spell): return
	if Inventory.spells.size() < Inventory.max_actives:
		Inventory.spells.append(spell)
		Inventory.update_graphics()
		queue_free()
	else:
		spell = await Inventory.replacement_popup(spell)

func _process(delta: float) -> void:
	$Sprite2D.offset.y = 2.0*sin(Time.get_ticks_msec()/1000.0)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if Inventory.spells.has(spell):
		$Status.text = "already held!"
	else:
		$Status.text = "press E to pick up"
		modulate = Color(1,1,1)

func _on_area_2d_body_exited(body: Node2D) -> void:
	modulate = Color(0.5,0.5,0.5)
	$Status.text = ""
