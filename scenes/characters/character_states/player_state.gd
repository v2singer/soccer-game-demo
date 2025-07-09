class_name PlayerState
extends Node

signal state_transition_requested(new_state: Player.State, state_data: PlayerStateData)

var ai_behavior : AIBehavior = null
var animation_player : AnimationPlayer = null
var ball : Ball = null
var own_goal : Goal = null
var player : Player = null
var state_data : PlayerStateData = PlayerStateData.new()
var tackle_damege_emitter_area : Area2D = null
var teammate_detection_area : Area2D = null
var opponent_detection_area : Area2D = null
var target_goal : Goal = null
var ball_detection_area : Area2D = null


func setup(context_player: Player, context_state_data: PlayerStateData, 
		context_animation_player: AnimationPlayer, context_ball: Ball, 
		context_team_detec_area: Area2D, context_ball_detection_area: Area2D, 
		context_own_goal: Goal, context_target_goal: Goal, context_ai_behavior: AIBehavior, 
		context_tackle_damege_emitter_area: Area2D, context_opponent_detection_area: Area2D) -> void:
	animation_player = context_animation_player
	ai_behavior = context_ai_behavior
	ball = context_ball
	ball_detection_area = context_ball_detection_area
	own_goal = context_own_goal
	opponent_detection_area = context_opponent_detection_area
	player = context_player
	state_data = context_state_data
	teammate_detection_area = context_team_detec_area
	target_goal = context_target_goal
	tackle_damege_emitter_area = context_tackle_damege_emitter_area


func transition_state(new_state: Player.State, 
		new_state_data: PlayerStateData = PlayerStateData.new()) -> void:
	state_transition_requested.emit(new_state, new_state_data)


func on_animation_complete() -> void:
	pass # override me!

func can_carry_ball() -> bool:
	return false

func can_pass() -> bool:
	return false
