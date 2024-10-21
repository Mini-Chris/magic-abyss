extends Area2D

enum Element {
	NONE,
	FIRE,
	WATER,
	WIND,
	LIGHTNING,
	EARTH
}

@export var damage_multiplier: float = .65

var animated_sprite: AnimatedSprite2D
var lightning_bolt: Line2D
var reaction_damage = 0


func _ready():
	monitoring = true
	animated_sprite = $AnimatedSprite2D 
	animated_sprite.connect("animation_finished", Callable(self, "_on_animation_finished"))
	#animated_sprite.play("default")
	
	lightning_bolt = $Line2D


func _on_animation_finished():
	lightning_bolt.clear_points()
	queue_free() 

# Trigger the Vaporize reaction
func trigger_electrocute(origin: Vector2, base_damage: int, element: Element):
	animated_sprite = $AnimatedSprite2D 
	animated_sprite.connect("animation_finished", Callable(self, "_on_animation_finished"))
	
	global_position = origin

	
	
	
	if (element == Element.LIGHTNING):
		reaction_damage = base_damage * damage_multiplier + base_damage
		animated_sprite.visible = true
	else:
		reaction_damage = base_damage * damage_multiplier
		animated_sprite.visible = false
	animated_sprite.play("default")
	


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		if (body.inflicted_element == Element.WATER):
			body.take_damage(reaction_damage, Element.LIGHTNING)
			lightning_bolt.add_point(body.global_position - global_position)
		else:
		#elif (body.inflicted_element == Element.LIGHTNING):
			body.take_damage(reaction_damage, Element.NONE)
			
