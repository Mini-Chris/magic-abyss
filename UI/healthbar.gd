extends TextureProgressBar


func _process(delta: float) -> void:
	value = InstanceManager.player.health
