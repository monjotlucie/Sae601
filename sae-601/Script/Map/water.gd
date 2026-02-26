extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player"):
		print("Player dans l'eau")

		if GameState.is_night:
			print("Mort eau")
			body.die()
s
