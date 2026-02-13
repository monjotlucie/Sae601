extends Area2D

@export var speed := 120.0

var direction := 1

@onready var left_limit: Node2D = $"../Leftlimit"
@onready var right_limit: Node2D = $"../Rightlimit"
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready():
	body_entered.connect(_on_body_entered)


func _process(delta: float):

	global_position.x += speed * direction * delta

	if global_position.x >= right_limit.global_position.x:
		direction = 1
		animated_sprite.flip_h = true
	elif global_position.x <= left_limit.global_position.x:
		direction = -1
		animated_sprite.flip_h = false


func _on_body_entered(body: Node2D):
	if body.is_in_group("player"):
		if not body.invincible:
			body.die()
