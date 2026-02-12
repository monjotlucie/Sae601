extends CharacterBody2D

@export var speed := 200.0
@export var gravity := 900.0
@export var bounce_force := -350.0
@export var max_bounces := 3

var direction := 1
var bounce_count := 0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	sprite.play("idle")

func _physics_process(delta):

	# Gravité
	velocity.y += gravity * delta

	# Mouvement horizontal constant
	velocity.x = direction * speed

	move_and_slide()

	# Gestion des collisions
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var normal = collision.get_normal()
		var body = collision.get_collider()

		# Si touche le joueur
		if body is Player and not body.invincible:
			body.die()
			queue_free()
			return

		# Rebond sur le sol
		if normal.y < -0.7:
			bounce()

		# Rebond mur
		if abs(normal.x) > 0.7:
			direction *= -1

func bounce():
	bounce_count += 1

	if bounce_count >= max_bounces:
		queue_free()
		return

	# Rebond de plus en plus faible
	velocity.y = bounce_force * (1.0 - (bounce_count * 0.25))
