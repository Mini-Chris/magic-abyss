extends CharacterBody2D
class_name Player

@export var move_speed : float = 100

var aim_direction: Vector2
var most_recent_interactable
var cooldowns = {}
var lifted_object: Liftable = null:
	set(new_object):
		if new_object:
			$Lifted.texture=new_object.texture
		else:
			$Lifted.texture=null
		lifted_object = new_object

func _ready() -> void:
	InstanceManager.player = self

func _physics_process(delta: float) -> void:
	
	var input_direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up"),
	)
	
	aim_direction = Vector2(
		Input.get_action_strength("aim_right") - Input.get_action_strength("aim_left"),
		Input.get_action_strength("aim_down") - Input.get_action_strength("aim_up"),
	)
	if aim_direction.length_squared() == 0:
		aim_direction = get_local_mouse_position()
	aim_direction = aim_direction.normalized()
	
	if input_direction.length_squared() > 1:
		input_direction = input_direction.normalized()
	
	velocity = input_direction * move_speed
	if lifted_object: velocity *= lifted_object.speed_mult
	
	move_and_slide()
	
	if not UI.lockInput:
		
		if Input.is_action_just_pressed("interact"):
			if not most_recent_interactable: return
			most_recent_interactable.interact()
		
		if Input.is_action_pressed("cast"):
			var spell = UI.inventory.selection
			if not spell: return
			if cooldowns.has(spell): return
			if spell.continuous or Input.is_action_just_pressed("cast"):
				spell._cast()
				cooldowns[spell] = get_tree().create_timer(spell.cooldown)
				cooldowns[spell].timeout.connect(func():cooldowns.erase(spell))
		
		if Input.is_action_pressed("throw"):
			if not lifted_object: return
			lifted_object.throw(position,aim_direction)

func _on_pickup_collider_area_entered(area: Area2D) -> void:
	most_recent_interactable = area.get_parent()

func _on_pickup_collider_area_exited(area: Area2D) -> void:
	if most_recent_interactable == area.get_parent(): most_recent_interactable = null
