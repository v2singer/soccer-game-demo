class_name PlayerStateMoving
extends PlayerState


func _process(_delta: float) -> void:
	if player.control_schema == Player.ControlSchema.CPU:
		ai_behavior.process_ai()
	else:
		handle_human_movement()

	player.set_movement_animation()
	player.set_heading()


func handle_human_movement() -> void:
	var direction := KeyUtils.get_input_vector(player.control_schema)
	player.velocity = direction * player.speed

	if player.velocity != Vector2.ZERO:
		teammate_detection_area.rotation = player.velocity.angle()

	if KeyUtils.is_action_just_pressed(player.control_schema, KeyUtils.Action.PASST):
		if player.has_ball():
			transition_state(Player.State.PASSING)
		elif can_teammate_pass_ball():
			ball.carrier.get_pass_request(player)
		else:
			player.swap_requested.emit(player)
	elif KeyUtils.is_action_just_pressed(player.control_schema, KeyUtils.Action.SHOOT):
		if player.has_ball():
			transition_state(Player.State.PREP_SHOOT)
		elif ball.can_air_interact():
			if player.velocity == Vector2.ZERO:
				if player.is_facing_target_goal():
					transition_state(Player.State.VOLLEY_KICK)
				else:
					transition_state(Player.State.BICYCLE_KICK)
			else:
				transition_state(Player.State.HEADER)
		elif player.velocity != Vector2.ZERO:
			transition_state(Player.State.TACKLING)

func can_carry_ball() -> bool:
	return player.role != Player.Role.GOALTE


func can_teammate_pass_ball() -> bool:
	return ball.carrier != null and ball.carrier.country == player.country and ball.carrier.control_schema == Player.ControlSchema.CPU


func can_pass() -> bool:
	return true
