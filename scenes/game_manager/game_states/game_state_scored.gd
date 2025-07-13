class_name GameStateScored
extends GameState

const DURATIN_CELEBRATIONG := 3000

var time_since_celebration := Time.get_ticks_msec()


func _exit_tree() -> void:
	var index_country_scoring := 1 if state_data.country_scored_on == manager.countries[0] else 0
	manager.score[index_country_scoring] += 1
	time_since_celebration = Time.get_ticks_msec()


func _process(_delta: float) -> void:
	if Time.get_ticks_msec() - time_since_celebration > DURATIN_CELEBRATIONG:
		transition_state(GameManager.State.RESET)
