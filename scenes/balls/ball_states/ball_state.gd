class_name BallState
extends Node

signal state_transition_requested(new_state: Ball.State)

var ball : Ball = null
var carrier : Player = null
var sprite : Sprite2D = null
var player_detection_area : Area2D = null
var animation_player : AnimationPlayer = null


func setup(context_ball: Ball, context_player_detection_area: Area2D, context_carrier: Player, 
		context_animation_player: AnimationPlayer, context_sprite: Sprite2D) -> void:
	ball = context_ball
	carrier = context_carrier
	sprite = context_sprite
	player_detection_area = context_player_detection_area
	animation_player = context_animation_player
