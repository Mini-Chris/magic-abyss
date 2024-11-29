extends "res://enemies/lib/enemy.gd"

@export var damage := 10
@export var attack_cool_down_time_sec := 1.0
@export var dash_speed := 160.0

@onready var _sprite: AnimatedSprite2D = %AnimatedSprite2D
@onready var _hitbox: Area2D = %HitBox
@onready var _timer := Timer.new()

var _dash_velocity := Vector2()

func _ready() -> void:
	super()
	_sprite.animation_finished.connect(_on_animation_finished)
	_sprite.frame_changed.connect(_on_sprite_frame_changed)
	_hitbox.body_entered.connect(_on_hitbox_body_entered)
	_timer.one_shot = true
	add_child(_timer)


func _physics_process(delta: float) -> void:
	super(delta)

	if not _dash_velocity.is_zero_approx():
		velocity = _dash_velocity
		move_and_slide()
	elif not player_chase:
		velocity = Vector2()

	_hitbox.get_child(0).position.x = abs(_hitbox.get_child(0).position.x) * (-1 if _sprite.flip_h else 1)
	_hitbox.get_child(1).position.x = abs(_hitbox.get_child(1).position.x) * (-1 if _sprite.flip_h else 1)

	if _process_movement_animation():
		return

	# Attack
	if not is_zero_approx(_timer.time_left) or _timer.time_left > 0.0:
		# Cooldown
		return

	if not is_instance_valid(player):
		return

	_attack()


func _attack() -> void:
	assert(is_instance_valid(player))
	_play_anima(&"attack")
	_timer.start(attack_cool_down_time_sec)
	player_chase = false

	var tween := create_tween()
	var target_vel = (player.global_position - global_position).normalized() * dash_speed
	tween.tween_property(self, ^"_dash_velocity", target_vel, 0.02).set_ease(Tween.EASE_IN).from(Vector2())
	tween.tween_callback(func(): _hitbox.monitoring = true)
	tween.tween_interval(0.5)
	tween.tween_property(self, ^"_dash_velocity", Vector2(), 0.05).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	tween.tween_callback(_attack_finished)


func _attack_finished() -> void:
	player_chase = is_instance_valid(player) and $Detection.overlaps_body(player)
	_play_anima(&"default")
	_hitbox.monitoring = false


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


func _play_anima(anim: StringName) -> void:
	if _sprite.is_playing() and _sprite.animation == anim:
		return
	_sprite.play(anim)


func _on_animation_finished() -> void:
	if _sprite.animation == &"death":
		queue_free()
		return

	if not _sprite.animation in [&"hurt"]:
		return

	_play_anima(&"default")


func _on_sprite_frame_changed() -> void:
	if _sprite.animation != &"attack":
		return
	if _sprite.frame == 4:
		%HitShape2.disabled = false
	if _sprite.frame == 7:
		%HitShape2.disabled = true


func _on_hitbox_body_entered(body: Node) -> void:
	if body != player:
		return
	if _sprite.animation != &"attack":
		return
	#player.take_damage(damage,Element.NONE)
