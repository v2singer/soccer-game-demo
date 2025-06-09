class_name BallState
extends Node

signal state_transition_requested(new_state: BallState)

var ball : Ball = null

func setup(context_ball: Ball, context_player_detection_area: Area2D) -> void:
	ball = context_ball
	player_detection_area = context_player_detection_area
