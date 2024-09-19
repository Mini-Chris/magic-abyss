extends CharacterBody2D

@export var move_speed : float = 100

var most_recent_interactable

func _physics_process(delta: float) -> void:
	
	var input_direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up"),
	)
	
	if input_direction.length_squared() > 1:
		input_direction = input_direction.normalized()
	
	velocity = input_direction * move_speed
	
	move_and_slide()
	
	if Input.is_action_just_pressed("cast"):
		var spell = Inventory.selection
		if not spell: return
		spell._cast()

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact"):
		if not most_recent_interactable: return
		most_recent_interactable.interact()

func _on_pickup_collider_area_entered(area: Area2D) -> void:
	most_recent_interactable = area.get_parent()

func _on_pickup_collider_area_exited(area: Area2D) -> void:
	if most_recent_interactable == area.get_parent(): most_recent_interactable = null
