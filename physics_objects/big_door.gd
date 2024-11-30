extends Node2D


@export var next_floor:PackedScene

func consume_key():
	$Sprite2D.region_rect = Rect2($Sprite2D.region_rect.position+Vector2(328-264,0),$Sprite2D.region_rect.size)
	$CollisionShape2D.set_deferred("disabled",true)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player: 
		get_tree().change_scene_to_packed(next_floor)
