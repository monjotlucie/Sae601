extends Area2D

@export var speed = 2

@onready var left_limit =$"../Leftlimit"
@onready var right_limit =$"../Rightlimit"
@onready var animated_sprite = $AnimatedSprite2D


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		print("outch")
		body.die()
	

func _physics_process(delta):
	global_position.x += speed
	if global_position.x >= right_limit.global_position.x:
		speed = -speed
		animated_sprite.flip_h = true
	elif global_position.x <= left_limit.global_position.x:
		speed = -speed
		animated_sprite.flip_h = false
