extends "res://enemies/lib/enemy.gd"

func get_navigation_agent() -> Node:
	return $NavigationAgent2D


func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
