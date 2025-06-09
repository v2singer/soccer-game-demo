class_name PlayerStatePrepShoot
extends PlayerState

const DURATION_MAX_BOUNS := 1000.0

var time_start_shot := Time.get_ticks_msec()

func _enter_tree() -> void:
	animation_player.play("prep_kick")
	player.velocity = Vector2.ZERO

func _process(delta: float) -> void:
	if KeyUtils.is_action_just_pressed(player.control_schema, KeyUtils.Action.SHOOT):
		var duration_press = clampf(Time.get_ticks_msec() - time_start_shot, 0.0, DURATION_MAX_BOUNS)
