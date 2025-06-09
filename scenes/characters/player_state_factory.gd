class_name PlayerStateFactory


var states : Dictionary

func _init() -> void:
    states = {
        Player.State.MOVING: PlayerStateMoving,
        Player.State.PREP_SHOOT: PlyerStatePrepShoot,
        Player.State.RECOVERING: PlayerStateRecovering,
        Player.State.SHOOTING: PlayerStateShooting,
        Player.State.TACKLING: PlayerStateTackling,
    }

func get_fresh_state(state: Player.State) -> PlayerState:
    assert(states.has(state), "states doesn't exists!")

    return states.get(state).new()