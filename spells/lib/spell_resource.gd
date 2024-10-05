extends Resource
class_name Spell

@export var name: String
@export var icon: Texture2D
@export var active: bool = true
@export var cooldown: float = 0
@export var continuous: bool = false
@export_multiline var description: String

func _cast():
	pass

func _pickup():
	pass

func _replace():
	pass
