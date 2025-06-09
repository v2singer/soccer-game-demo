class_name Ball
extends AnimatableBody2D

enum State {CARRIED, FREEFORM, SHOOT}

@onready var player_detection_area : Area2D = $PlayerDectionArea

var current_state : BallState = null
var state_factory := BallStateFactory.new()
var velocity : Vector2 = Vector2.ZERO

func switch_state(state: Ball.State) -> void:
    if current_state != null:
        current_state.queue_free()

    current_state = state_factory.get_fresh_state(state)
    current_state.setup(self, player_detection_area)
    current_state.state_transition_requested.connect(switch_state.bind())
    current_state.name = "BallStateMachine"
    call_deferred("add_child", current_state)

