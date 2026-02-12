extends Area2D

@export var projectile_scene: PackedScene
@export var shoot_delay := 2.0
@export var speed := 120.0

var direction := -1
var is_night := false
var can_shoot := true

@onready var left_limit: Node2D =$"../Leftlimit"
@onready var right_limit: Node2D = $"../Rightlimit"
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	GameState.day_night_changed.connect(switch_mode)
	switch_mode(GameState.is_night)
	shoot_loop()

func shoot_loop():
	while true:
		await get_tree().create_timer(shoot_delay).timeout
		shoot()

func shoot():
	if projectile_scene == null:
		return

	var projectile = projectile_scene.instantiate()
	projectile.global_position = global_position
	projectile.direction = -1 if animated_sprite.flip_h else 1

	get_tree().current_scene.add_child(projectile)


func _process(delta: float) -> void:
	global_position.x += speed * direction * delta

	if global_position.x >= right_limit.global_position.x:
		direction = -1
		animated_sprite.flip_h = true
	elif global_position.x <= left_limit.global_position.x:
		direction = 1
		animated_sprite.flip_h = false

func switch_mode(night: bool) -> void:
	is_night = night
	print("Choux night =", is_night)

	if is_night:
		animated_sprite.play("fixe")
	else:
		animated_sprite.play("fixe")


func _on_body_entered(body):
	if body is Player:
		if not is_night:
			return 
		body.die()
