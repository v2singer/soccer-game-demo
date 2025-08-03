class_name ScreenFactory

var screens : Dictionary


func _init() -> void:
	screens = {
		ScreenGame.ScreenType.IN_GAME : preload("res://scenes/screens/world/world_screen.tscn"),
		ScreenGame.ScreenType.MAIN_MENU : preload("res://scenes/screens/main_menu/main_menu_screen.tscn"),
		ScreenGame.ScreenType.TEAM_SELECTION : preload("res://scenes/screens/team_selection/team_selection_screen.tscn"),
	}


func get_fresh_screen(screen: ScreenGame.ScreenType) -> Screen:
	assert(screens.has(screen), "screen does not exist")
	return screens.get(screen).instantiate()
