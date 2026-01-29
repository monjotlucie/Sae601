extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

const SPEED := 250.0
const JUMP_VELOCITY := -500.0
const GRAVITY := 1200.0


func _physics_process(delta: float) -> void:
	# Gravité
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		velocity.y = 0

	# Saut
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Déplacement horizontal
	var direction := Input.get_axis("ui_left", "ui_right")
	velocity.x = direction * SPEED

	# Flip du sprite
	if direction > 0:
		sprite.flip_h = false
	elif direction < 0:
		sprite.flip_h = true

	# Animations
	if not is_on_floor():
		sprite.play("Saut")
	elif direction == 0:
		sprite.play("Fixe")
	else:
		sprite.play("Marche")

	move_and_slide()
