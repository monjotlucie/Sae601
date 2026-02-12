extends CharacterBody2D

@export var speed := 60.0          # plus lent
@export var gravity := 900.0
@export var bounce_force := -180.0 # rebond plus faible
@export var lifetime := 20.0       # reste 20 secondes
@export var max_distance := 200.0  # distance max parcourue

var direction := 1
var start_position := Vector2.ZERO

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

func _process(delta):
	global_position.x += direction * speed * delta

func _physics_process(delta):
	set_collision_mask_value(1, true) 
	set_collision_mask_value(2, GameState.is_night)

	velocity.y += gravity * delta
	velocity.x = direction * speed 
	move_and_slide()

	if global_position.distance_to(start_position) > max_distance:
		direction *= -1

	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var body = collision.get_collider()
		var normal = collision.get_normal()

		if body is Player:
			if GameState.is_night and not body.invincible:
				body.die()

		if normal.y < -0.7:
			velocity.y = bounce_force
