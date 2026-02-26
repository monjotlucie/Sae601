extends Node2D

@onready var bg_day = get_node_or_null("Background_Day")
@onready var bg_night = get_node_or_null("Background_Night")

func _ready():
	GameState.day_night_changed.connect(_on_day_night_changed)
	_on_day_night_changed(GameState.is_night)
	print("MAP READY")

func _on_day_night_changed(is_night: bool):
	if bg_day != null:
		bg_day.visible = not is_night
	if bg_night != null:
		bg_night.visible = is_night
	print("MAP → mode nuit :", is_night)
