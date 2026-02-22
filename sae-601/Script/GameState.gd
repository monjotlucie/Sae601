extends Node

signal day_night_changed(is_night: bool)

var is_night := false
var respawn_position: Vector2 = Vector2.ZERO
var active_checkpoint: Area2D = null
var open_pause_menu_on_load: bool = false

func toggle_day_night():
	is_night = !is_night
	day_night_changed.emit(is_night)
