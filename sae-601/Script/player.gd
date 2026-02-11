extends CharacterBody2D
class_name Player

signal respawn_requested

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

const SPEED := 300.0
const JUMP_VELOCITY := -500.0

var is_night := false
var is_dead := false   
var invincible := false
@export var invincible_time := 2.0


func _ready():
	GameState.day_night_changed.connect(_on_day_night_changed)
	is_night = GameState.is_night
	add_to_group("player")
	print("PLAYER READY")

func die():
	if is_dead or invincible:
		return

	is_dead = true
	velocity = Vector2.ZERO
	respawn_requested.emit()



func revive():
	is_dead = false
	start_invincibility()

func start_invincibility():
	invincible = true

	# Petit effet clignotement
	var tween = create_tween()
	tween.set_loops(10)
	tween.tween_property(animated_sprite_2d, "modulate:a", 0.3, 0.1)
	tween.tween_property(animated_sprite_2d, "modulate:a", 1.0, 0.1)

	await get_tree().create_timer(invincible_time).timeout

	invincible = false
	animated_sprite_2d.modulate.a = 1.0


func _input(event):
	if event.is_action_pressed("toggle_mode"):
		GameState.toggle_day_night()


func _on_day_night_changed(night: bool):
	is_night = night


func _physics_process(delta: float) -> void:
	if is_dead:
		return   # le joueur ne bouge pas pendant la mort

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
