extends Spell

@export var scene: PackedScene
@export var lifetime: float = 10
@export var damage: int = 20  #
#@export var element: Spell.Element  

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _cast():
	var s = scene.instantiate()
	InstanceManager.player.add_sibling(s)
	s.transform = InstanceManager.player.transform
	var death_timer = Timer.new()
	s.add_child(death_timer)
	death_timer.start(lifetime)
	death_timer.timeout.connect(s.queue_free)


func _on_body_entered(body: Node):
	if body.has_method("take_damage"):
		body.take_damage(damage, element)
		#queue_free() 
	else:
		print("Hit something else that isn't an enemy.")
