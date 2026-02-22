extends Area2D

@export var speed := 120.0
@export var projectile_scene: PackedScene
@export var shoot_range := 500.0
@export var shoot_delay := 0.8

@export var respawn_time := 30.0

var direction := -1
var is_night := false

var dead := false
var spawn_position: Vector2
var sprite_start_scale: Vector2
var sprite_start_pos: Vector2

@onready var left_limit: Node2D = $"../Leftlimit"
@onready var right_limit: Node2D = $"../Rightlimit"
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var shoot_point: Marker2D = $ShootPoint
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

@onready var death_particles: GPUParticles2D = get_node_or_null("DeathParticles")

var player: Player = null

func _ready():
	add_to_group("enemies")

	spawn_position = global_position
	sprite_start_scale = animated_sprite.scale
	sprite_start_pos = animated_sprite.position

	GameState.day_night_changed.connect(switch_mode)
	switch_mode(GameState.is_night)

	player = get_tree().get_first_node_in_group("player")

	body_entered.connect(_on_body_entered)

	shoot_loop()

func _process(delta: float):
	if dead:
		return

	global_position.x += speed * direction * delta

	if global_position.x >= right_limit.global_position.x:
		direction = -1
		animated_sprite.flip_h = true
	elif global_position.x <= left_limit.global_position.x:
		direction = 1
		animated_sprite.flip_h = false

func switch_mode(night: bool) -> void:
	is_night = night
	animated_sprite.play("fixe")

func _on_body_entered(body: Node2D):
	if dead:
		return

	if body is Player:
		if is_night and not body.invincible:
			body.die()

func shoot_loop():
	while true:
		await get_tree().create_timer(shoot_delay).timeout

		if dead:
			continue

		if is_night and player != null:
			var distance = global_position.distance_to(player.global_position)
			if distance <= shoot_range:
				shoot()

func shoot():
	if dead:
		return
	if projectile_scene == null:
		return

	var projectile = projectile_scene.instantiate()
	projectile.global_position = shoot_point.global_position
	projectile.direction = direction
	get_tree().current_scene.add_child(projectile)


func die() -> void:
	if dead:
		return
	dead = true

	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	if collision_shape:
		collision_shape.set_deferred("disabled", true)

	if death_particles:
		death_particles.emitting = true

	var t := create_tween()
	t.set_parallel(true)
	t.tween_property(animated_sprite, "modulate:a", 0.0, 0.25)
	t.tween_property(animated_sprite, "scale", Vector2(sprite_start_scale.x, 0.0), 0.25)
	t.tween_property(animated_sprite, "position", sprite_start_pos + Vector2(0, 12), 0.25)
	await t.finished

	visible = false

	await get_tree().create_timer(respawn_time).timeout
	_respawn()

func _respawn() -> void:
	global_position = spawn_position

	visible = true
	animated_sprite.modulate.a = 1.0
	animated_sprite.scale = sprite_start_scale
	animated_sprite.position = sprite_start_pos

	dead = false

	set_deferred("monitoring", true)
	set_deferred("monitorable", true)
	if collision_shape:
		collision_shape.set_deferred("disabled", false)
