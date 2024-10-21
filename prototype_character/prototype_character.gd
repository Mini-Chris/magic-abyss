extends CharacterBody2D
class_name Player

enum State {
	IDLE,
	RUN,
	ROLE,
	HIT,
	CHARGE,
	DIE
}

@export var move_speed : float = 100

var current_state: State = State.IDLE
var animated_sprite: AnimatedSprite2D

var y_offset : float
var cast_speed: float

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
	animated_sprite = $AnimatedSprite2D  
	set_animation(current_state)  
	y_offset = animated_sprite.position.y
	cast_speed = move_speed

# Function to set the current state
func set_state(state: State):
	if current_state != state:
		current_state = state

# Function to switch the animation based on the current state
func set_animation(state: State):
	match state:
		State.IDLE:
			animated_sprite.play("idle") 
		State.RUN:
			animated_sprite.play("run")  
		State.ROLE:
			animated_sprite.play("role")  
		State.CHARGE:
			animated_sprite.play("charge")  
		State.HIT:
			animated_sprite.play("hit")  
		State.DIE:
			animated_sprite.play("die") 



func _physics_process(delta: float) -> void:
	
	var input_direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up"),
	)
	
	if input_direction == Vector2.ZERO:
		set_state(State.IDLE)
	else:
		set_state(State.RUN)
	
	#print(input_direction)
	aim_direction = Vector2(
		Input.get_action_strength("aim_right") - Input.get_action_strength("aim_left"),
		Input.get_action_strength("aim_down") - Input.get_action_strength("aim_up"),
	)
	if aim_direction.length_squared() == 0:
		aim_direction = get_local_mouse_position()
	aim_direction = aim_direction.normalized()
	
	if input_direction.length_squared() > 1:
		input_direction = input_direction.normalized()
	
	animated_sprite.flip_h = aim_direction.x < 0
	velocity = input_direction * move_speed
	if lifted_object: velocity *= lifted_object.speed_mult
	
	
	if Input.is_action_pressed("cast"):
		set_state(State.CHARGE)
		animated_sprite.position.y = y_offset - 8
		move_speed = cast_speed * 0.5
	else:
		animated_sprite.position.y = y_offset
		move_speed = cast_speed
	
	move_and_slide()
	set_animation(current_state)
	
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
