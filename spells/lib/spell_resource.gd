extends Resource
class_name Spell

enum Element {
	NONE,
	FIRE,
	WATER,
	WIND,
	LIGHTNING,
	EARTH
}

@export var name: String
@export var icon: Texture2D
@export var active: bool = true
@export var cooldown: float = 0
@export var continuous: bool = false
@export var element: Element = Element.NONE
@export_multiline var description: String



func _cast():
	pass

func _pickup():
	pass

func _replace():
	pass
