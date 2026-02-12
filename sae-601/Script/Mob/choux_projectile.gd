extends CharacterBody2D

@export var speed := 200.0
@export var gravity := 900.0
@export var bounce_force := -350.0
@export var max_bounces := 3

var direction := 1
var bounce_count := 0

@export var bounce_heights := [-400.0, -300.0, -180.0, -80.0]
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	sprite.play("idle")
	print("Projectile spawned")


func _physics_process(delta):

	velocity.y += gravity * delta
	velocity.x = direction * speed

	move_and_slide()

	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var body = collision.get_collider()

		if body is Player and not body.invincible:
			body.die()
			queue_free()
			return

	if is_on_floor():
		bounce()

	if is_on_wall():
		direction *= -1


func bounce():

	if bounce_count >= bounce_heights.size():
		queue_free()
		return

	velocity.y = bounce_heights[bounce_count]
	bounce_count += 1
