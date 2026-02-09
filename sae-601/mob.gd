extends RigidBody2D

@export var speed := 200.0

func _ready() -> void:
	var mob_types = Array($AnimatedSprite2D.sprite_frames.get_animation_names())
	$AnimatedSprite2D.animation = mob_types.pick_random()
	$AnimatedSprite2D.play()

	# Lancer le mob dans une direction aléatoire
	var direction = Vector2.LEFT if randf() < 0.5 else Vector2.RIGHT
	linear_velocity = direction * speed


func _on_visible_on_screen_enabler_2d_screen_exited():
	queue_free()
