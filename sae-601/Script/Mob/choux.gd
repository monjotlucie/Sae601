extends Area2D

@export var projectile_scene: PackedScene
@export var speed := 120.0
@export var burst_count := 2       
@export var burst_interval := 0.25 
@export var burst_pause := 1.5      

var direction := -1
var is_night := false

@onready var shoot_point: Marker2D = $ShootPoint
@onready var left_limit: Node2D = $"../Leftlimit"
@onready var right_limit: Node2D = $"../Rightlimit"
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	GameState.day_night_changed.connect(switch_mode)
	switch_mode(GameState.is_night)
	shoot_loop()


func shoot_loop():
	while true:
		if is_night:
			for i in burst_count:
				shoot()
				await get_tree().create_timer(burst_interval).timeout
		
		await get_tree().create_timer(burst_pause).timeout


func shoot():
	if projectile_scene == null or not is_night:
		return

	var projectile = projectile_scene.instantiate()

	# IMPORTANT : position mondiale
	projectile.global_position = shoot_point.global_position
	projectile.direction = direction

	get_tree().current_scene.add_child(projectile)


func _process(delta: float) -> void:
	global_position.x += speed * direction * delta

	if global_position.x >= right_limit.global_position.x:
		set_direction(-1)

	elif global_position.x <= left_limit.global_position.x:
		set_direction(1)


func set_direction(new_direction: int):
	direction = new_direction
	
	
	animated_sprite.flip_h = direction < 0
	
	
	shoot_point.position.x = abs(shoot_point.position.x) * direction


func switch_mode(night: bool) -> void:
	is_night = night
	
	if is_night:
		animated_sprite.play("fixe")
	else:
		animated_sprite.play("fixe")


func _on_body_entered(body):
	if body is Player:
		if not is_night:
			return 
		body.die()
