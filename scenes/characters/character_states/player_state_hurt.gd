class_name PlayerStateHurt
extends PlayerState

const AIR_FRICTION := 35.0
const BALL_TUMBLE_SPEED := 100.0
const DURATION_HURT := 1000
const HURT_HEIGHT_VELOCITY := 3.0
const HURT_JUMP_HEIGH := 0.1

var time_start_hurt := Time.get_ticks_msec()


func _enter_tree() -> void:
	animation_player.play("hurt")
	time_start_hurt = Time.get_ticks_msec()
	player.height_velocity = HURT_HEIGHT_VELOCITY
	player.height = HURT_JUMP_HEIGH
	if ball.carrier == player:
		ball.tumble(state_data.hurt_direction * BALL_TUMBLE_SPEED)
		GameEvents.impact_received.emit(player.position, false)

func _process(delta: float) -> void:
	if Time.get_ticks_msec() - time_start_hurt > DURATION_HURT:
		transition_state(Player.State.RECOVERING)

	player.velocity = player.velocity.move_toward(Vector2.ZERO, delta * AIR_FRICTION)
