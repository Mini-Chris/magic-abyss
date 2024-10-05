@tool
extends Node2D
class_name Liftable

@export var texture: Texture2D:
	set(new_texture):
		if is_node_ready():
			$Sprite.texture = new_texture
		texture = new_texture
@export var speed_mult: float = 0.5

func _ready() -> void:
	$Sprite.texture = texture

func interact() -> void:
	InstanceManager.player.lifted_object = self
	visible = false
	$StaticCollider.disabled = true
	$PickupRange.monitorable = false

func throw(new_position: Vector2, direction: Vector2) -> void:
	position = new_position
	InstanceManager.player.lifted_object = null
	visible = true
	$StaticCollider.disabled = false
	$PickupRange.monitorable = true
