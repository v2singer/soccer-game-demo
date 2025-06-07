class_name BallState
extends Node

signal state_transition_requested(new_state: BallState)

var ball : Ball = null

func setup(context_ball: Ball) -> void:
	ball = context_ball
