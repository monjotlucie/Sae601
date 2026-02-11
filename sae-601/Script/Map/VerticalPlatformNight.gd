extends AnimatableBody2D

@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var visual: Node = $ColorRect   # ou Sprite2D

func _ready():
	GameState.day_night_changed.connect(_on_day_night_changed)
	_on_day_night_changed(GameState.is_night)

func _on_day_night_changed(night: bool):
	if night:
		collision.set_deferred("disabled", false)
	else:
		collision.set_deferred("disabled", true)
	
