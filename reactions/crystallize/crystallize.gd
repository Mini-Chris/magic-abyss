extends Area2D

enum Element {
	NONE,
	FIRE,
	WATER,
	WIND,
	LIGHTNING,
	EARTH
}

@export var damage_multiplier: float = 0.5

var animated_sprite: AnimatedSprite2D
var reaction_damage = 0

func _ready():
	monitoring = true
	animated_sprite = $AnimatedSprite2D 
	animated_sprite.connect("animation_finished", Callable(self, "_on_animation_finished"))
	animated_sprite.play("default")

func _on_animation_finished():
	queue_free() 

# Trigger the Vaporize reaction
func trigger_crystallize(origin: Vector2, base_damage: int, element: Element):
	animated_sprite = $AnimatedSprite2D 
	animated_sprite.connect("animation_finished", Callable(self, "_on_animation_finished"))

	global_position = origin
	
	reaction_damage = base_damage * damage_multiplier + base_damage
	
	animated_sprite.play("default")


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(reaction_damage, Element.NONE)
