class_name Ball
extends AnimatableBody2D

enum State {CARRIED, FREEFORM, SHOOT}

@export var dribble_frequency : float = 1.0
@export var dribble_intensity : float = 2.0

@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var ball_sprite : Sprite2D = $BallSprinte
@onready var player_detection_area : Area2D = %PlayerDetectionArea

var carrier : Player = null
var current_state : BallState = null
var height : float = 0.0
var state_factory := BallStateFactory.new()
var velocity : Vector2 = Vector2.ZERO

func _ready() -> void:
	switch_state(State.FREEFORM)

func _process(_delta: float) -> void:
	ball_sprite.position = Vector2.UP * height

func switch_state(state: Ball.State) -> void:
	if current_state != null:
		current_state.queue_free()

	current_state = state_factory.get_fresh_state(state)
	current_state.setup(self, player_detection_area, carrier, animation_player, ball_sprite)
	current_state.state_transition_requested.connect(switch_state.bind())
	current_state.name = "BallStateMachine"
	call_deferred("add_child", current_state)

func shoot(shot_velocity: Vector2) -> void:
	velocity = shot_velocity
	carrier = null
	switch_state(Ball.State.SHOOT)
