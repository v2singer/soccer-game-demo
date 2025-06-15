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

func set_ball_animation_from_velocity() -> void:
	if ball.velocity == Vector2.ZERO:
		animation_player.play("idle")

	if ball.velocity.x > 0:
		animation_player.play("roll")
		animation_player.advance(0)
	else:
		animation_player.play_backwards("roll")
		animation_player.advance(0)
