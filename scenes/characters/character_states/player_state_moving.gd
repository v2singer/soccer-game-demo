class_name PlayerStateMoving
extends PlayerState


func _process(_delta: float) -> void:
	if player.control_schema == Player.ControlSchema.CPU:
		pass
	else:
		handle_human_movement()

	player.set_movement_animation()
	player.set_heading()


func handle_human_movement() -> void:
	var direction := KeyUtils.get_input_vector(player.control_schema)
	player.velocity = direction * player.speed

	if player.velocity != Vector2.ZERO:
		teammate_detection_area.rotation = player.velocity.angle()

	if player.has_ball():
		if KeyUtils.is_action_just_pressed(player.control_schema, KeyUtils.Action.PASST):
			transition_state(Player.State.PASSING)
		elif KeyUtils.is_action_just_pressed(player.control_schema, KeyUtils.Action.SHOOT):
			transition_state(Player.State.PREP_SHOOT)
	elif ball.can_air_interact() and KeyUtils.is_action_just_pressed(player.control_schema, KeyUtils.Action.SHOOT):
		if player.velocity == Vector2.ZERO:
			pass
		else:
			transition_state(Player.State.HEADER)

	#if player.velocity != Vector2.ZERO and KeyUtils.is_action_just_pressed(player.control_schema, KeyUtils.Action.SHOOT):
	#   transition_state(Player.State.TACKLING)
