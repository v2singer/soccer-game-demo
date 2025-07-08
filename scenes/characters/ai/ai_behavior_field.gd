class_name AIBehaviorField
extends AIBehavior


const SHOOT_DISTANCE := 150
const SHOOT_PROBABILITY := 0.3
const SPRED_ASSIST_FACTOR := 0.8
const TACKLE_DISTANCE := 15
const TACKLE_PROBABLITY := 0.3
const PASS_PROBABILITY := 0.5


func perform_ai_movement():
	var total_steering_force := Vector2.ZERO
	if player.has_ball():
		total_steering_force += get_carrier_steering_force()
	else:
		total_steering_force += get_onduty_streering_force()
		if is_ball_carried_by_teammate():
			total_steering_force += get_assist_formation_steering_force()
	total_steering_force = total_steering_force.limit_length(1.0)
	player.velocity = total_steering_force * player.speed


func perform_ai_decisions():
	if (is_ball_possessed_by_opponent() and player.position.distance_to(ball.position) < TACKLE_DISTANCE and 
			randi_range(0, 1) > TACKLE_PROBABLITY):
		player.switch_state(Player.State.TACKLING)

	if ball.carrier == player:
		var target := player.target_goal.get_center_target_position()
		if player.position.distance_to(target) < SHOOT_DISTANCE and randf() < SHOOT_PROBABILITY:
			face_towards_target_all()
			var shot_direction := player.position.direction_to(player.target_goal.get_random_target_position())
			var data := PlayerStateData.build().set_shot_power(player.power).set_shot_direction(shot_direction)
			player.switch_state(Player.State.SHOOTING, data)
		elif has_opponents_nearby() and randf() < PASS_PROBABILITY:
			player.switch_state(Player.State.PASSING)


func get_onduty_streering_force() -> Vector2:
	return player.weight_on_duty_steering * player.position.direction_to(ball.position)


func get_carrier_steering_force() -> Vector2:
	var target := player.target_goal.get_center_target_position()
	var direction := player.position.direction_to(target)
	var weight := get_bicircular_weight(player.position, target, 100, 0, 150, 1)
	return weight * direction


func get_assist_formation_steering_force() -> Vector2:
	var spawn_difference := ball.carrier.spawn_position - player.spawn_position
	var assist_destination := ball.carrier.position - spawn_difference * SPRED_ASSIST_FACTOR
	var direction := player.position.direction_to(assist_destination)
	var weight := get_bicircular_weight(player.position, assist_destination, 30, 0.2, 60, 1)
	return weight * direction
