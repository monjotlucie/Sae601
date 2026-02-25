extends CharacterBody2D
class_name Player

signal respawn_requested

@export var invincible_time := 2.0
@export var head_projectile: PackedScene

const SPEED := 300.0
const JUMP_VELOCITY := -600.0

var is_night := false
var is_dead := false
var invincible := false
var attacking := false
var current_head: Node = null
var control_locked := false
var teleporting := false
var facing_direction: int = 1 

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var head_spawn: Marker2D = $AnimatedSprite2D/HeadSpawn
@onready var head_target: Marker2D = $AnimatedSprite2D/HeadTarget


func _ready():
	GameState.day_night_changed.connect(_on_day_night_changed)
	is_night = GameState.is_night
	add_to_group("player")


func launch_head():
	if head_projectile == null:
		return
	if current_head != null:
		return
	if head_spawn == null or head_target == null:
		push_error("HeadSpawn/HeadTarget introuvables : vérifie $AnimatedSprite2D/HeadSpawn et HeadTarget.")
		return

	attacking = true
	control_locked = true
	play_anim("Attack")

	var projectile = head_projectile.instantiate()
	var dir: int = facing_direction

	var spawn_local := head_spawn.position
	spawn_local.x = abs(spawn_local.x) * dir
	projectile.global_position = global_position + spawn_local

	var target_local := head_target.position
	target_local.x = abs(target_local.x) * dir
	projectile.target_position = global_position + target_local

	var head_sprite := projectile.get_node_or_null("AnimatedSprite2D")
	if head_sprite != null and head_sprite is AnimatedSprite2D:
		(head_sprite as AnimatedSprite2D).flip_h = (dir == -1)

	get_tree().current_scene.add_child(projectile)
	current_head = projectile

	projectile.tree_exited.connect(func():
		if current_head == projectile:
			current_head = null
			attacking = false
			control_locked = false
	)
	
	get_tree().create_timer(2.5).timeout.connect(func():
		if current_head == projectile and is_instance_valid(projectile):
			projectile.queue_free()
	)


func finish_attack():
	attacking = false
	current_head = null
	control_locked = false


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


func _on_day_night_changed(night: bool):
	is_night = night


func _physics_process(delta):
	if Input.is_action_just_pressed("toggle_mode"):
		GameState.toggle_day_night()

	if is_dead:
		return

	if control_locked:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction := Input.get_axis("ui_left", "ui_right")
	velocity.x = direction * SPEED

	if direction > 0:
		facing_direction = 1
		animated_sprite_2d.flip_h = false
	elif direction < 0:
		facing_direction = -1
		animated_sprite_2d.flip_h = true

	if Input.is_action_just_pressed("attack") and is_night and not attacking:
		launch_head()
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# Animations
	if not attacking:
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

	if animated_sprite_2d.sprite_frames.has_animation(anim):
		if animated_sprite_2d.animation != anim:
			animated_sprite_2d.play(anim)


func return_to_start_with_respawn(target_pos: Vector2) -> void:
	if teleporting:
		return
	teleporting = true
	control_locked = true
	attacking = false

	play_anim("Respawn")

	var up_height := 180.0
	var up_time := 0.35
	var down_time := 0.35

	velocity = Vector2.ZERO

	var tween := create_tween()
	tween.tween_property(self, "global_position:y", global_position.y - up_height, up_time)
	await tween.finished

	global_position = target_pos + Vector2(0, -up_height)

	var tween2 := create_tween()
	tween2.tween_property(self, "global_position:y", target_pos.y, down_time)
	await tween2.finished

	control_locked = false
	teleporting = false

	start_invincibility()
