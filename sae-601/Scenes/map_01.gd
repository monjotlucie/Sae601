extends Node2D

@onready var bg_day = $Background_Day
@onready var bg_night = $Background_Night

var is_night := false

func switch_mode(night: bool) -> void:
	is_night = night
	bg_day.visible = not is_night
	bg_night.visible = is_night
