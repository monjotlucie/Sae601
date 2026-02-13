extends CharacterBody2D
class_name Player

signal respawn_requested

@export var invincible_time := 2.0
@export var head_projectile: PackedScene

const SPEED := 300.0
const JUMP_VELOCITY := -500.0

var is_night := false
var is_dead := false
var invincible := false
var attacking := false
var current_head = null
var facing_direction := 1

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func _ready():
	GameState.day_night_changed.connect(_on_day_night_changed)
	is_night = GameState.is_night
	add_to_group("player")


# ======================
#       ATTAQUE
# ======================

func launch_head():

	if head_projectile == null:
		return

	if current_head != null:
		return

	attacking = true
	play_anim("Attack")

	var projectile = head_projectile.instantiate()

	var offset_x = 100  # distance devant le joueur

	# Position devant le joueur
	projectile.global_position = global_position + Vector2(facing_direction * offset_x, -20)

	projectile.direction = facing_direction

	# Orientation visuelle correcte
	projectile.get_node("AnimatedSprite2D").flip_h = (facing_direction == -1)

	get_tree().current_scene.add_child(projectile)

	current_head = projectile

	await get_tree().create_timer(2.0).timeout

	attacking = false

	if current_head != null:
		current_head.queue_free()
		current_head = null



func finish_attack():
	attacking = false
	current_head = null


# ======================
#       MORT
# ======================

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

	var tween = create_tween()
	tween.set_loops(10)
	tween.tween_property(animated_sprite_2d, "modulate:a", 0.3, 0.1)
	tween.tween_property(animated_sprite_2d, "modulate:a", 1.0, 0.1)

	await get_tree().create_timer(invincible_time).timeout

	invincible = false
	animated_sprite_2d.modulate.a = 1.0


# ======================
#       JOUR / NUIT
# ======================

func _on_day_night_changed(night: bool):
	is_night = night


# ======================
#       PHYSICS
# ======================

func _physics_process(delta):

	# Toggle jour/nuit
	if Input.is_action_just_pressed("toggle_mode"):
		GameState.toggle_day_night()

	# Attaque (seulement la nuit)
	if Input.is_action_just_pressed("attack") and is_night and not attacking:
		launch_head()

	if is_dead:
		return

	# Gravité
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Saut
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Mouvement horizontal
	var direction := Input.get_axis("ui_left", "ui_right")
	velocity.x = direction * SPEED

	if direction > 0:
		animated_sprite_2d.flip_h = false
		facing_direction = 1
	elif direction < 0:
		animated_sprite_2d.flip_h = true
		facing_direction = -1


	# Animations
	if not attacking:
		if not is_on_floor():
			play_anim("Saut")
		elif direction == 0:
			play_anim("Fixe")
		else:
			play_anim("Marche")

	move_and_slide()


# ======================
#       ANIMATIONS
# ======================

func play_anim(base_name: String):
	var suffix := "_night" if is_night else "_day"
	var anim := base_name + suffix

	if animated_sprite_2d.sprite_frames.has_animation(anim):
		if animated_sprite_2d.animation != anim:
			animated_sprite_2d.play(anim)
