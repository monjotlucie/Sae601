extends Area2D

@export var speed := 120.0
@export var projectile_scene: PackedScene
@export var shoot_range := 500.0
@export var shoot_delay := 0.8


var direction := -1
var is_night := false

@onready var left_limit: Node2D = $"../Leftlimit"
@onready var right_limit: Node2D = $"../Rightlimit"
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var shoot_point: Marker2D = $ShootPoint

var player: Player = null


func _ready():
	GameState.day_night_changed.connect(switch_mode)
	switch_mode(GameState.is_night)

	player = get_tree().get_first_node_in_group("player")

	# 🔥 IMPORTANT
	body_entered.connect(_on_body_entered)

	shoot_loop()


func _process(delta: float):

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


# ===============================
#        CONTACT JOUEUR
# ===============================

func _on_body_entered(body: Node2D):
	if body is Player:
		if is_night and not body.invincible:
			body.die()
# ===============================
#        SYSTÈME DE TIR
# ===============================

func shoot_loop():
	while true:
		await get_tree().create_timer(shoot_delay).timeout
		
		if is_night and player != null:
			var distance = global_position.distance_to(player.global_position)
			
			if distance <= shoot_range:
				shoot()


func shoot():
	if projectile_scene == null:
		return

	var projectile = projectile_scene.instantiate()
	projectile.global_position = shoot_point.global_position
	projectile.direction = direction

	get_tree().current_scene.add_child(projectile)
