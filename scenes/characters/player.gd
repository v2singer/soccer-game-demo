class_name Player
extends CharacterBody2D

const BALL_CONTROL_HEIGHT_MAX := 10.0
const CONTROL_SPRITE_MAP : Dictionary = {
	ControlSchema.CPU : preload("res://assets/art/props/cpu.png"),
	ControlSchema.P1 : preload("res://assets/art/props/1p.png"),
	ControlSchema.P2 : preload("res://assets/art/props/2p.png")
}

const GRAVITY := 8.0

enum ControlSchema{CPU, P1, P2}
enum State {CHEST_CONTROL, MOVING, TACKLING, RECOVERING, PREP_SHOOT, SHOOTING, PASSING, HEADER, VOLLEY_KICK, BICYCLE_KICK}

@export var ball : Ball
@export var control_schema : ControlSchema
@export var own_goal : Goal
@export var power : float
@export var speed : float
@export var target_goal : Goal

@onready var animation_player : AnimationPlayer = %AnimationPlayer
@onready var control_sprite : Sprite2D = %ControlSprite
@onready var player_sprite : Sprite2D = $PlayerSprite
@onready var teammate_detection_area : Area2D = %TeammateDetectionArea2D
@onready var ball_detection_area : Area2D = %BallDetectionArea

var current_state : PlayerState = null
var heading := Vector2.RIGHT
var height := 0.0
var height_velocity := 0.0
var state := State.MOVING
var time_start_tackle := Time.get_ticks_msec()
var state_factory := PlayerStateFactory.new()


func _ready() -> void:
	set_control_texture()
	switch_state(State.MOVING)


func _process(delta: float) -> void:
	flip_sprites()
	set_sprite_visibility()
	process_gravity(delta)
	move_and_slide()


func switch_state(set_state: State, state_data: PlayerStateData = PlayerStateData.new()) -> void:
	if current_state != null:
		current_state.queue_free()

	current_state = state_factory.get_fresh_state(set_state)
	current_state.setup(self, state_data, animation_player, ball,
		teammate_detection_area, ball_detection_area, own_goal, target_goal)
	current_state.state_transition_requested.connect(switch_state.bind())
	current_state.name = "PlayerStateMachine: " + str(set_state)
	call_deferred("add_child", current_state)


func set_movement_animation() -> void:
	if velocity.length() > 0:
		animation_player.play("run")
	else:
		animation_player.play("idle")

func process_gravity(delta: float) -> void:
	if height > 0:
		height_velocity -= GRAVITY * delta
		height += height_velocity
		if height <= 0:
			height = 0
	player_sprite.position = Vector2.UP * height


func set_heading() -> void:
	if velocity.x > 0:
		heading = Vector2.RIGHT
	elif velocity.x < 0:
		heading = Vector2.LEFT

func flip_sprites() -> void:
	if heading == Vector2.RIGHT:
		player_sprite.flip_h = false
	elif heading == Vector2.LEFT:
		player_sprite.flip_h = true

func has_ball() -> bool:
	return ball.carrier == self

func set_control_texture() -> void:
	control_sprite.texture = CONTROL_SPRITE_MAP[control_schema]

func set_sprite_visibility() -> void:
	control_sprite.visible = has_ball() or not control_schema == ControlSchema.CPU

func on_animation_complete() -> void:
	if current_state != null:
		current_state.on_animation_complete()

func control_ball() -> void:
	if ball.height > BALL_CONTROL_HEIGHT_MAX:
		switch_state(Player.State.CHEST_CONTROL)


