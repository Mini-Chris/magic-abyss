extends Area2D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$CollisionShape2D.disabled = not $CollisionShape2D.disabled
