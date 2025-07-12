class_name BallStateFreeForm
extends BallState


const MAX_CAPTURE_HEIGHT := 25


var time_since_freeform := Time.get_ticks_msec()


func _enter_tree() -> void:
	player_detection_area.body_entered.connect(on_player_enter.bind())
	time_since_freeform = Time.get_ticks_msec()

func on_player_enter(body) -> void:
	if body is Player and body.can_carry_ball() and ball.height < MAX_CAPTURE_HEIGHT:
		ball.carrier = body
		body.control_ball()
		transition_state(Ball.State.CARRIED)

func _process(delta: float) -> void:
	player_detection_area.monitoring = (Time.get_ticks_msec() - time_since_freeform > state_data.lock_duration)
	set_ball_animation_from_velocity()
	var friction = ball.frction_air if ball.height > 0 else ball.frction_ground
	ball.velocity = ball.velocity.move_toward(Vector2.ZERO, friction * delta)
	process_gravity(delta, ball.BOUNCINESS)
	move_and_bounce(delta)

func can_air_interact() -> bool:
	return true
