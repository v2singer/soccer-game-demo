class_name BallStateShoot
extends BallState

const DURATION_SHOOT := 1000
const SHOOT_HEIGHT := 5.0
const SHOOT_SPRITE_SCALE := 0.8

var time_since_shot := Time.get_ticks_msec()

func _enter_tree() -> void:
    if ball.velocity.x >= 0:
        animation_player.play("roll")
        animation_player.advance(0)
    else:
        animation_player.play_backwards("roll")
        animation_player.advance(0)

    sprite.scale.y = SHOOT_SPRITE_SCALE
    ball.height = SHOOT_HEIGHT
    time_since_shot = Time.get_ticks_msec()

func _process(delta: float) -> void:
    if Time.get_ticks_msec() - time_since_shot > DURATION_SHOOT:
        state_transition_requested.emit(Ball.State.FREEFORM)
    else:
        ball.move_and_collide(ball.velocity * delta)

func _exit_tree() -> void:
    sprite.scale.y = 1.0
