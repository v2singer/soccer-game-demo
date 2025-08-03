class_name Screen
extends Node


signal screen_transition_requested(new_screen: ScreenGame.ScreenType, data: ScreenData)

var game : ScreenGame = null
var screen_data : ScreenData = null


func setup(c_game: ScreenGame, c_data: ScreenData) -> void:
	game = c_game
	screen_data = c_data


func transition_screen(new_screen: ScreenGame.ScreenType, data: ScreenData = ScreenData.new()):
	screen_transition_requested.emit(new_screen, data)

