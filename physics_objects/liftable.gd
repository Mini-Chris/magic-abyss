@tool
extends CharacterBody2D
class_name Liftable

@export var texture: Texture2D:
	set(new_texture):
		if is_node_ready():
			$Sprite.texture = new_texture
		texture = new_texture
@export var speed_mult: float = 0.5
@export var throw_velocity: float = 50
@export var bounciness: float = 0.4 # NYI
@export var speed_floor: float = 20 # NYI
@export var player_height_offset: float = 20
@export var gravity: float = 200
@export var damage: float = 20
@export var damage_element: Spell.Element = Spell.Element.NONE
@export var is_key: bool = false

var vertical_velocity: float = 0

func _ready() -> void:
	$Sprite.texture = texture

func interact() -> void:
	InstanceManager.player.lifted_object = self
	visible = false
	$StaticCollider.disabled = true
	$Projectile/ProjectileCollider.disabled = true
	$PickupRange.monitorable = false

func throw(new_position: Vector2, direction: Vector2) -> void:
	position = new_position
	velocity = InstanceManager.player.aim_direction * throw_velocity
	InstanceManager.player.lifted_object = null
	visible = true
	$Sprite.offset.y = -player_height_offset
	vertical_velocity = -throw_velocity
	$StaticCollider.disabled = true
	$Projectile/ProjectileCollider.disabled = false
	$PickupRange.monitorable = false

func stop():
	velocity = Vector2.ZERO
	$StaticCollider.disabled = false
	$Projectile/ProjectileCollider.disabled = true
	$PickupRange.monitorable = true
	$Sprite.offset.y = 0

func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	move_and_slide()
	if not $Projectile/ProjectileCollider.disabled:
		$Sprite.offset.y += vertical_velocity * delta
		vertical_velocity += gravity * delta
		if $Sprite.offset.y >= 0: stop()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage, damage_element)
	if body.has_method("consume_key") and is_key:
		body.consume_key()
		queue_free()

func get_interact_text():
	return "E: Lift Object"
