class_name PlayerStateShooting
extends PlayerState

func _enter_tree() -> void:
    animation_player.play('kick')

func on_animation_complete() -> void:
    print("animation is completed")
    if player.control_schema == Player.ControlSchema.CPU:
        transition_state(Player.State.RECOVERING)
    else:
        transition_state(Player.State.MOVING)
    shoot_ball()

func shoot_ball():
    ball.shoot(state_data.shot_direction * state_data.shot_power)

