extends Area2D


func _on_body_entered(body):
	if body is Player:
		if GameState.is_night:
			body.die()
