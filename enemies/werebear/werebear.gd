extends "res://enemies/lib/enemy.gd"

@export var damage := 10
@export var attack_cool_down_time_sec := 0.35

@onready var _sprite: AnimatedSprite2D = %AnimatedSprite2D
@onready var _hitbox: Area2D = %HitBox
@onready var _hitdetect: Area2D = %AttackDetectBox
@onready var _timer := Timer.new()


func _ready() -> void:
	super()
	_sprite.animation_finished.connect(_on_animation_finished)
	_sprite.frame_changed.connect(_on_sprite_frame_changed)
	_hitbox.body_entered.connect(_on_hitbox_body_entered)
	_timer.one_shot = true
	add_child(_timer)


func _physics_process(delta: float) -> void:
	super(delta)

	if not player_chase:
		velocity = Vector2()

	_hitbox.get_child(0).position.x = abs(_hitbox.get_child(0).position.x) * (-1 if _sprite.flip_h else 1)
	_hitdetect.get_child(0).position.x = abs(_hitdetect.get_child(0).position.x) * (-1 if _sprite.flip_h else 1)

	if _process_movement_animation():
		return

	# Attack
	if not is_instance_valid(player) or not _hitdetect.overlaps_body(player):
		return
	if not is_zero_approx(_timer.time_left) or _timer.time_left > 0.0:
		# Cooldown
		return

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
	if _sprite.frame == 5:
		_hitbox.monitoring = true
	if _sprite.frame == 7:
		_hitbox.monitoring = false


func _on_hitbox_body_entered(body: Node) -> void:
	if body != player:
		return
	player.take_damage(damage)
