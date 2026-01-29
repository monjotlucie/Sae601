extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

const SPEED := 300.0
const JUMP_VELOCITY := -500.0

var is_night := false


func _physics_process(delta: float) -> void:
	# Switch jour / nuit
	if Input.is_action_just_pressed("toggle_mode"):
		is_night = !is_night
		print("Mode nuit :", is_night)

	# Gravité
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Saut
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Saut variable
	if Input.is_action_just_released("ui_accept") and velocity.y < 0:
		velocity.y *= 0.5

	# Déplacement horizontal
	var direction := Input.get_axis("ui_left", "ui_right")
	velocity.x = direction * SPEED

	# Flip du sprite
	if direction > 0:
		animated_sprite_2d.flip_h = false
	elif direction < 0:
		animated_sprite_2d.flip_h = true

	# Animations
	if not is_on_floor():
		play_anim("Saut")
	elif direction == 0:
		play_anim("Fixe")
	else:
		play_anim("Marche")

	move_and_slide()


func play_anim(base_name: String) -> void:
	var suffix := "_night" if is_night else "_day"
	var anim_name := base_name + suffix

	# Vérifie que l'animation existe dans les SpriteFrames
	var frames: SpriteFrames = animated_sprite_2d.sprite_frames
	if frames != null and frames.has_animation(anim_name):
		if animated_sprite_2d.animation != anim_name:
			animated_sprite_2d.play(anim_name)
	else:
		print("Animation manquante :", anim_name)
