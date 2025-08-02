class_name BallStateShoot
extends BallState

const DURATION_SHOOT := 1000
const SHOOT_HEIGHT := 5.0
const SHOOT_SPRITE_SCALE := 0.8

var time_since_shot := Time.get_ticks_msec()

func _enter_tree() -> void:
	set_ball_animation_from_velocity()
	sprite.scale.y = SHOOT_SPRITE_SCALE
	ball.height = SHOOT_HEIGHT
	time_since_shot = Time.get_ticks_msec()
	shot_particles.emitting = true
	GameEvents.impact_received.emit(ball.position, true)

func _process(delta: float) -> void:
	if Time.get_ticks_msec() - time_since_shot > DURATION_SHOOT:
		transition_state(Ball.State.FREEFORM)
	else:
		move_and_bounce(delta)

func _exit_tree() -> void:
	sprite.scale.y = 1.0
	shot_particles.emitting = false
