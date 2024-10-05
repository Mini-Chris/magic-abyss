extends Spell

@export var scene: PackedScene
@export var lifetime: float = 10

func _cast():
	var s = scene.instantiate()
	InstanceManager.player.add_sibling(s)
	s.transform = InstanceManager.player.transform
	var death_timer = Timer.new()
	s.add_child(death_timer)
	death_timer.start(lifetime)
	death_timer.timeout.connect(s.queue_free)
