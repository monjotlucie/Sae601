extends Area2D

@export var speed = 2
var direction := -1
var is_night := false

@onready var left_limit =$"../Leftlimit"
@onready var right_limit =$"../Rightlimit"
@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	GameState.day_night_changed.connect(switch_mode)
	switch_mode(GameState.is_night)

func _physics_process(delta):
	global_position.x += speed
	if global_position.x >= right_limit.global_position.x:
		speed = -speed
		animated_sprite.flip_h = true
	elif global_position.x <= left_limit.global_position.x:
		speed = -speed
		animated_sprite.flip_h = false


func switch_mode(night: bool) -> void:
	is_night = night
	print("Guerrier night =", is_night)

	if is_night:
		animated_sprite.play("fixe_night")
		animated_sprite.scale = Vector2(0.49, 0.49)
	else:
		animated_sprite.play("fixe_day")
		

func _on_body_entered(body):
	if body is Player:
		if is_night:
			return 
		body.die()
