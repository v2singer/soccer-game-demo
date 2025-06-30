class_name Ball
extends AnimatableBody2D

const BOUNCINESS := 0.8
const DISTANCE_HIGH_PASS := 130.0

enum State {CARRIED, FREEFORM, SHOOT}

@export var frction_air : float = 35.0
@export var frction_ground : float = 250.0

@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var ball_sprite : Sprite2D = $BallSprinte
@onready var player_detection_area : Area2D = %PlayerDetectionArea

var carrier : Player = null
var current_state : BallState = null
var height : float = 0.0
var height_velocity : float = 0.0
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

func pass_to(destination: Vector2) -> void:
	var direction := position.direction_to(destination)
	var distance := position.distance_to(destination)
	var intensity := sqrt(2 * distance * frction_ground)
	velocity = intensity * direction
	if distance > DISTANCE_HIGH_PASS:
		height_velocity = BallState.GRAVITY * distance / (2 * intensity) * 1.1
	carrier = null
	switch_state(Ball.State.FREEFORM)

func stop() -> void:
	velocity = Vector2.ZERO


func can_air_interact() -> bool:
	return current_state != null and current_state.can_air_interact()

func can_air_connect(air_connect_min_height: float, air_connect_max_height: float) -> bool:
	return height >= air_connect_min_height and height <= air_connect_max_height
