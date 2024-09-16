extends CharacterBody2D

@export var move_speed : float = 100

func _physics_process(delta: float) -> void:

	var input_direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up"),
	)
	
	if input_direction.length_squared() > 1:
		input_direction = input_direction.normalized()
	
	velocity = input_direction * move_speed

	move_and_slide()
