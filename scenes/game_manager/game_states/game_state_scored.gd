class_name GameStateScored
extends GameState

const DURATIN_CELEBRATIONG := 3000

var time_since_celebration := Time.get_ticks_msec()


func _exit_tree() -> void:
	manager.increase_score(state_data.country_scored_on)
	time_since_celebration = Time.get_ticks_msec()
	print("%s scored" % [state_data.country_scored_on])


func _process(_delta: float) -> void:
	if Time.get_ticks_msec() - time_since_celebration > DURATIN_CELEBRATIONG:
		transition_state(GameManager.State.RESET)
