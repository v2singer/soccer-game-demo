class_name BallState
extends Node

const GRAVITY := 10.0
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

func process_gravity(delta: float, bounciness: float=0.0) -> void:
	if ball.height > 0 or ball.height_velocity > 0:
		ball.height_velocity -= GRAVITY * delta
		ball.height += ball.height_velocity
		if ball.height < 0:
			ball.height = 0
			if bounciness > 0 and ball.height_velocity < 0:
				ball.height_velocity = - ball.height_velocity * bounciness
				ball.velocity *= bounciness

func move_and_bounce(delta: float) -> void:
	var collision := ball.move_and_collide(ball.velocity * delta)
	# fix collision is Player bug, why here found Player
	if collision != null and collision.get_collider() is not Player:
		ball.velocity = ball.velocity.bounce(collision.get_normal()) * ball.BOUNCINESS
		ball.switch_state(Ball.State.FREEFORM)

func can_air_interact() -> bool:
	return false
