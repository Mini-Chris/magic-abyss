extends Area2D

enum Element {
	NONE,
	FIRE,
	WATER,
	WIND,
	LIGHTNING,
	EARTH
}

@export var damage_multiplier: float = 50  

var animated_sprite: AnimatedSprite2D

func _ready():
	animated_sprite = $AnimatedSprite2D 
	animated_sprite.connect("animation_finished", Callable(self, "_on_animation_finished"))
	animated_sprite.play("default")

func _on_animation_finished():
	queue_free() 

# Trigger the Vaporize reaction
func trigger_crystallize(origin: Vector2, base_damage: int, element: Element):
	animated_sprite = $AnimatedSprite2D 
	animated_sprite.connect("animation_finished", Callable(self, "_on_animation_finished"))
	animated_sprite.play("default")
	#print("Triggered crystallize")
	global_position = origin
	
	var additional_damage = base_damage * damage_multiplier
	
	print(get_overlapping_bodies())
	for enemy in get_overlapping_bodies():
		print(enemy)
		if enemy.has_method("take_damage"):
			print("doing crystallize damage")
			enemy.take_damage(additional_damage, Element.NONE)
