extends CharacterBody2D

@export var projectile_speed: float = 300
@export var accel: float = 0
@export var inaccuracy: float = 5
@export var variance: float = 0.1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	velocity = InstanceManager.player.aim_direction * projectile_speed
	velocity = velocity.rotated(randfn(0,inaccuracy/180))
	velocity *= randfn(1,variance)
	velocity += InstanceManager.player.velocity


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	move_and_slide()
	velocity += velocity.normalized()*accel*delta
	if(get_slide_collision_count()>0): queue_free()
