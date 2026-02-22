extends Area2D

@export var projectile_scene: PackedScene
@export var speed := 120.0
@export var burst_count := 2
@export var burst_interval := 0.25
@export var burst_pause := 1.5

@export var respawn_time := 30.0  # <-- temps avant respawn

var direction := -1
var is_night := false
var dead := false
var spawn_position: Vector2
var sprite_start_scale: Vector2
var sprite_start_pos: Vector2


@onready var shoot_point: Marker2D = $ShootPoint
@onready var left_limit: Node2D = $"../Leftlimit"
@onready var right_limit: Node2D = $"../Rightlimit"
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var death_particles: GPUParticles2D = get_node_or_null("DeathParticles")


func _ready() -> void:
	add_to_group("enemies")
	spawn_position = global_position

	GameState.day_night_changed.connect(switch_mode)
	switch_mode(GameState.is_night)

	sprite_start_scale = animated_sprite.scale
	sprite_start_pos = animated_sprite.position

	shoot_loop()

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
	t.tween_property(animated_sprite, "scale", Vector2(1.0, 0.0), 0.25)
	t.tween_property(animated_sprite, "position", animated_sprite.position + Vector2(0, 12), 0.25)
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


func shoot_loop() -> void:
	while true:
		if dead:
			await get_tree().create_timer(0.2).timeout
			continue

		if is_night:
			for i in range(burst_count):
				if dead:
					break
				shoot()
				await get_tree().create_timer(burst_interval).timeout

		await get_tree().create_timer(burst_pause).timeout

func shoot() -> void:
	if dead:
		return
	if projectile_scene == null or not is_night:
		return

	var projectile = projectile_scene.instantiate()
	projectile.global_position = shoot_point.global_position
	projectile.direction = direction
	get_tree().current_scene.add_child(projectile)


func _process(delta: float) -> void:
	if dead:
		return

	global_position.x += speed * direction * delta

	if global_position.x >= right_limit.global_position.x:
		set_direction(-1)
	elif global_position.x <= left_limit.global_position.x:
		set_direction(1)

func set_direction(new_direction: int) -> void:
	direction = new_direction
	animated_sprite.flip_h = direction < 0
	shoot_point.position.x = abs(shoot_point.position.x) * direction



func switch_mode(night: bool) -> void:
	is_night = night
	animated_sprite.play("fixe")


func _on_body_entered(body) -> void:
	if dead:
		return

	if body is Player:
		if not is_night:
			return
		body.die()
