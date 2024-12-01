extends "res://enemies/lib/enemy.gd"

@export var skeleton_damage := 10
@export var arrow_life_time := 0.5
@export var arrow_speed := 200.0
@export var attack_cool_down_time_sec := 1.0

@onready var _sprite: AnimatedSprite2D = %AnimatedSprite2D
@onready var _timer := Timer.new()


var _arrow: Area2D
var _shot_target_pos := Vector2()

func _ready() -> void:
	super()
	_sprite.animation_finished.connect(_on_animation_finished)
	_sprite.frame_changed.connect(_on_sprite_frame_changed)
	_timer.one_shot = true
	damage = skeleton_damage
	add_child(_timer)


func _physics_process(delta: float) -> void:
	super(delta)

	if is_instance_valid(_arrow):
		_arrow.move_local_x(delta * arrow_speed)

	if not player_chase:
		velocity = Vector2()

	if _process_movement_animation():
		return

	# Attack
	if not is_instance_valid(player):
		return
	if not is_zero_approx(_timer.time_left) or _timer.time_left > 0.0:
		# Cooldown
		return

	if is_instance_valid(_arrow):
		return

	_shot_target_pos = player.global_position
	_play_anima(&"attack")
	_timer.start(attack_cool_down_time_sec)
	player_chase = false


func _process_movement_animation() -> bool:
	if _sprite.animation in [&"hurt", &"death", &"attack"]:
		return true

	if velocity.is_zero_approx():
		_play_anima(&"default")
	else:
		_play_anima(&"walk")
	return false


func die():
	player_chase = false
	$Damage.set_deferred(&"disabled", true)
	$Detection.set_deferred(&"monitoring", false)
	_play_anima(&"death")


func take_damage(p_damage: int, spell_element: Element) -> void:
	super(p_damage, spell_element)
	if _sprite.animation == &"attack":
		return
	_play_anima(&"hurt")

func get_navigation_agent() -> Node:
	return $NavigationAgent2D

func _play_anima(anim: StringName) -> void:
	if _sprite.is_playing() and _sprite.animation == anim:
		return
	_sprite.play(anim)


func _on_animation_finished() -> void:
	if _sprite.animation == &"death":
		queue_free()
		return

	if _sprite.animation == &"attack":
		player_chase = is_instance_valid(player) and $Detection.overlaps_body(player)

	if not _sprite.animation in [&"hurt", &"attack"]:
		return

	_play_anima(&"default")


func _on_sprite_frame_changed() -> void:
	if _sprite.animation != &"attack":
		return
	if _sprite.frame == 6:
		_arrow = preload("arrow.tscn").instantiate() as Area2D
		get_parent().add_child(_arrow)
		_arrow.global_position = self.global_position
		_arrow.look_at(player.global_position if is_instance_valid(player) else _shot_target_pos)
		
		_arrow.body_entered.connect(_on_arrow_body_entered)

		get_tree().create_timer(arrow_life_time).timeout.connect(func(): if _arrow != null: _arrow.queue_free(); _arrow = null)


func _on_arrow_body_entered(body: Node) -> void:
	if _arrow != null:
		_arrow.queue_free()
		_arrow = null
