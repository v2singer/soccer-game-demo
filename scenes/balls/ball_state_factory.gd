class_name BallStateFactory


var states : Dictionary

func _init() -> void:
	states = {
		Ball.State.CARRIED: BallStateCarried,
		Ball.State.FREEFORM: BallStateFreeForm,
		Ball.State.SHOOT: BallStateShoot,
	}


func get_fresh_state(state: Ball.State) -> BallState:
	assert(states.has(state), "states doesn't exists!")

	return states.get(state).new()
