class_name PlayerStateFactory


var states : Dictionary

func _init() -> void:
	states = {
		Player.State.CHEST_CONTROL: PlayerStateChestControl,
		Player.State.DIVING: PlayerStateDiving,
		Player.State.MOVING: PlayerStateMoving,
		Player.State.HURT: PlayerStateHurt,
		Player.State.PASSING: PlayerStatePassing,
		Player.State.PREP_SHOOT: PlayerStatePrepShoot,
		Player.State.RECOVERING: PlayerStateRecovering,
		Player.State.SHOOTING: PlayerStateShooting,
		Player.State.TACKLING: PlayerStateTackling,
		Player.State.HEADER: PlayerStateHeader,
		Player.State.VOLLEY_KICK: PlayerStateVolleyKick,
		Player.State.BICYCLE_KICK: PlayerStateBicycleKick,
		Player.State.CELEBRATING: PlayerStateCelebrating,
		Player.State.MOURNING: PlayerStateMourning,
	}

func get_fresh_state(state: Player.State) -> PlayerState:
	assert(states.has(state), "states doesn't exists!")

	return states.get(state).new()
