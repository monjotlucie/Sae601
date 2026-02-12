extends Area2D

@export var speed := 200.0
@export var bounce_force := -350.0
@export var max_bounces := 4
@export var lifetime := 15.0

var direction := 1
var bounce_count := 0
var is_night := false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready():
	sprite.play("idle")
	
	
	
	# 🔥 Connexion au GameState
	GameState.day_night_changed.connect(_on_day_night_changed)
	is_night = GameState.is_night
	
	body_entered.connect(_on_body_entered)
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _on_day_night_changed(night: bool):
	is_night = night


func bounce():
	bounce_count += 1

	if bounce_count >= max_bounces:
		queue_free()
		return

	var strength_factor = 1.0 - (bounce_count * 0.2)


func _on_body_entered(body: Node2D):
	if body is Player:
		# 🔥 Tue seulement la nuit
		if is_night and not body.invincible:
			body.die()
