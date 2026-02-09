extends Node
signal day_night_changed(is_night: bool)

var is_night := false

func toggle_day_night():
	is_night = !is_night
	print("GAMESTATE → Mode nuit :", is_night)
	day_night_changed.emit(is_night)
