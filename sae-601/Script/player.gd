extends CharacterBody2D
class_name Player

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

const SPEED := 300.0
const JUMP_VELOCITY := -500.0

var is_night := false

func _ready():
	GameState.day_night_changed.connect(_on_day_night_changed)
	is_night = GameState.is_night
	print("PLAYER READY")
	print(GameState.is_night)


func _input(event):
	if event.is_action_pressed("toggle_mode"):
		GameState.toggle_day_night()

func _on_day_night_changed(night: bool):
	is_night = night
	print("PLAYER → mode nuit :", is_night)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction := Input.get_axis("ui_left", "ui_right")
	velocity.x = direction * SPEED

	if direction > 0:
		animated_sprite_2d.flip_h = false
	elif direction < 0:
		animated_sprite_2d.flip_h = true

	if not is_on_floor():
		play_anim("Saut")
	elif direction == 0:
		play_anim("Fixe")
	else:
		play_anim("Marche")

	move_and_slide()

func play_anim(base_name: String):
	var suffix := "_night" if is_night else "_day"
	var anim := base_name + suffix

	var frames := animated_sprite_2d.sprite_frames
	if frames and frames.has_animation(anim):
		if animated_sprite_2d.animation != anim:
			animated_sprite_2d.play(anim)

func get_is_night() -> bool:
	return is_night


func die():
	queue_free()
