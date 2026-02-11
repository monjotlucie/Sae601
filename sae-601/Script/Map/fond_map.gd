extends Node2D

@onready var bg_day = $Background_Day
@onready var bg_night = $Background_Night

func _ready():
	GameState.day_night_changed.connect(_on_day_night_changed)
	_on_day_night_changed(GameState.is_night)
	print("MAP READY")

func _on_day_night_changed(is_night: bool):
	bg_day.visible = not is_night
	bg_night.visible = is_night
	print("MAP → mode nuit :", is_night)
