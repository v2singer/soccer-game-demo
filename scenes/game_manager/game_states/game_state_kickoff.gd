class_name GameStateKickoff
extends GameState

var valid_control_schemes := []

func _exit_tree() -> void:
	var country_starting := state_data.country_scored_on
	if country_starting.is_empty():
		country_starting = manager.countries[0]
	if country_starting == manager.player_setup[0]:
		valid_control_schemes.append(Player.ControlSchema.P1)
	if country_starting == manager.player_setup[1]:
		valid_control_schemes.append(Player.ControlSchema.P2)
	if valid_control_schemes.size() == 0:
		valid_control_schemes.append(Player.ControlSchema.P1)

func _process(_delta: float) -> void:
	for control_scheme : Player.ControlSchema in valid_control_schemes:
		if KeyUtils.is_action_just_pressed(control_scheme, KeyUtils.Action.PASST):
			GameEvents.kickoff_started.emit()
			transition_state(GameManager.State.IN_PLAY)


