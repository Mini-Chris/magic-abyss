extends CharacterBody2D

enum Element {
	NONE,
	FIRE,
	WATER,
	WIND,
	LIGHTNING,
	EARTH
}

@export var speed: float = 30
@export var max_health: int = 100
@export var invulnerability_duration: float = 0.5

var health: int
var health_bar: TextureProgressBar
var status_effects_container: HBoxContainer
var status_icon: Sprite2D

var is_invulnerable: bool = false  # To track if the enemy is invulnerable
var invulnerability_timer: Timer

var inflicted_element: Element = Element.NONE
var inflicted_element_timer: Timer

var player = null
var player_chase = false

func _ready() -> void:
	$AnimatedSprite2D.play("default")
	
	invulnerability_timer = Timer.new()
	invulnerability_timer.one_shot = true  # Make sure the timer runs once per hit
	invulnerability_timer.wait_time = invulnerability_duration
	invulnerability_timer.connect("timeout", Callable(self, "_on_invulnerability_timeout"))
	add_child(invulnerability_timer)
	
	inflicted_element_timer = Timer.new()
	inflicted_element_timer.one_shot = true
	inflicted_element_timer.wait_time = 5.0  # Element wears off after 5 seconds
	inflicted_element_timer.connect("timeout", Callable(self, "_on_element_timeout"))
	add_child(inflicted_element_timer)
	
	health_bar = $HealthBar
	health = max_health
	update_health_bar()
	
	status_icon = $StatusEffectContainer/StatusIcon

func update_health_bar():
	health_bar.value = health
	health_bar.max_value = max_health

func apply_elemental_status(element: Element):
	inflicted_element = element
	
func update_status_icon():
	if inflicted_element == Element.NONE:
		status_icon.visible = false
	elif inflicted_element == Element.WATER:
		status_icon.visible = true
		status_icon.frame = 1
	elif inflicted_element == Element.FIRE:
		status_icon.visible = true
		status_icon.frame = 3
	elif inflicted_element == Element.LIGHTNING:
		status_icon.visible = true
		status_icon.frame = 37


func print_element(element: Element):
	if (element == Element.NONE):
		print("Element type: NONE")
	if (element == Element.FIRE):
		print("Element type: FIRE")
	if (element == Element.WATER):
		print("Element type: WATER")
	if (element == Element.WIND):
		print("Element type: WIND")
	if (element == Element.LIGHTNING):
		print("Element type: LIGHTNING")
	if (element == Element.EARTH):
		print("Element type: EARTH")

func handle_elemental_reaction(damage: int, new_element: Element):
	
	#print("Current:")
	#print_element(inflicted_element)
	#print("New:")
	#print_element(new_element)
	#inflicted_element = new_element
	if inflicted_element == Element.NONE:
		health -= damage
		if (new_element != Element.WIND and new_element != Element.EARTH):
			inflicted_element = new_element
		#inflicted_element_timer.start()
	else:
		#apply_elemental_status(new_element)
		if (new_element == Element.FIRE and inflicted_element == Element.WATER) || inflicted_element == Element.FIRE and new_element == Element.WATER:
			trigger_vaporize(damage, new_element)
			inflicted_element = Element.NONE
		elif new_element == Element.WIND and (inflicted_element != Element.EARTH || inflicted_element != Element.WIND):
			trigger_swirl(damage, inflicted_element)
			#inflicted_element = Element.NONE
		elif new_element == Element.EARTH and (inflicted_element != Element.EARTH || inflicted_element != Element.WIND):
			trigger_crystallize(damage, inflicted_element)
			inflicted_element = Element.NONE
		elif (new_element == Element.LIGHTNING and inflicted_element == Element.FIRE) || (inflicted_element == Element.LIGHTNING and new_element == Element.FIRE):
			trigger_overcharge(damage)
			inflicted_element = Element.NONE
		elif (new_element == Element.LIGHTNING and inflicted_element == Element.WATER) || (inflicted_element == Element.LIGHTNING and new_element == Element.WATER):
			trigger_electrocute(damage)
			inflicted_element = Element.NONE
		else:
			health -= damage
		

func trigger_vaporize(damage: int, new_element: Element):
	var vaporize_scene = preload("res://reactions/vaporize/vaporize.tscn").instantiate()
	vaporize_scene.trigger_vaporize(global_position, damage)  # Pass origin and base damage
	get_tree().current_scene.add_child(vaporize_scene)

func trigger_swirl(damage: int, inflicted_element: Element):
	var swirl_scene = preload("res://reactions/swirl/swirl.tscn").instantiate()
	swirl_scene.trigger_swirl(global_position, damage, inflicted_element)
	get_tree().current_scene.add_child(swirl_scene)

func trigger_crystallize(damage: int, inflicted_element: Element):
	var crystallize_scene = preload("res://reactions/crystallize/crystallize.tscn").instantiate()
	crystallize_scene.trigger_crystallize(global_position, damage, inflicted_element)
	get_tree().current_scene.add_child(crystallize_scene)

func trigger_overcharge(damage: int):
	var overcharge_scene = preload("res://reactions/overcharge/overcharge.tscn").instantiate()
	overcharge_scene.trigger_overcharge(global_position, damage)  # Example damage
	get_tree().current_scene.add_child(overcharge_scene)

func trigger_electrocute(damage: int):
	var electrocute_scene = preload("res://reactions/electrocute/electrocute.tscn").instantiate()
	electrocute_scene.trigger_electrocute(global_position, damage)  # Example damage
	get_tree().current_scene.add_child(electrocute_scene)

func take_damage(damage: int, spell_element: Element):
	#if not is_invulnerable:  # Only take damage if not invulnerable
	#print("Took damage. Health is now ", health)
	if health <= 0:
		die()
	else:
		handle_elemental_reaction(damage, spell_element)
		enter_invulnerability()
	update_health_bar()

func enter_invulnerability():
	is_invulnerable = true
	invulnerability_timer.start()
	$AnimatedSprite2D.modulate = Color(1, 1, 1, 0.5)
	
func _on_invulnerability_timeout():
	is_invulnerable = false
	$AnimatedSprite2D.modulate = Color(1, 1, 1, 1)

func die():
	print("Enemy has died.")
	queue_free()  # Remove the enemy from the scene

func _physics_process(delta: float) -> void:
	if health <= 0:
		die()
	update_status_icon()
	if player_chase:
		var direction = (player.position - position).normalized()
		velocity = direction * speed
		
		if (player.position.x - position.x) < 0:
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.flip_h = false
		
		move_and_slide()

func _on_detection_body_entered(body: Node2D) -> void:
	player = body
	player_chase = true
	
