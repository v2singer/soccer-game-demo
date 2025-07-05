class_name AIBehavior
extends Node

const AI_TICK_FREQUENCY := 200
const SHOOT_DISTANCE := 150
const SHOOT_PROBABILITY := 0.3
const SPRED_ASSIST_FACTOR := 0.8
const TACKLE_DISTANCE := 15
const TACKLE_PROBABLITY := 0.3
const PASS_PROBABILITY := 0.5

var ball : Ball = null
var player : Player = null
var time_since_last_ai_tick := Time.get_ticks_msec()


func _ready() -> void:
	time_since_last_ai_tick = Time.get_ticks_msec() + randi_range(0, AI_TICK_FREQUENCY)


func setup(c_player: Player, c_ball: Ball) -> void:
	ball = c_ball
	player = c_player


func process_ai() -> void:
	if Time.get_ticks_msec() - time_since_last_ai_tick > AI_TICK_FREQUENCY:
		time_since_last_ai_tick = Time.get_ticks_msec()
		perform_ai_movement()
		perform_ai_decisions()


func perform_ai_movement():
	var total_steering_force := Vector2.ZERO
	if player.has_ball():
		total_steering_force += get_carrier_steering_force()
	elif player.role != Player.Role.GOALTE:
		total_steering_force += get_onduty_streering_force()
		if is_ball_carried_by_teammate():
			total_steering_force += get_assist_formation_steering()
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


func get_assist_formation_steering() -> Vector2:
	var spawn_difference := ball.carrier.spawn_position - player.spawn_position
	var assist_destination := ball.carrier.position - spawn_difference * SPRED_ASSIST_FACTOR
	var direction := player.position.direction_to(assist_destination)
	var weight := get_bicircular_weight(player.position, assist_destination, 30, 0.2, 60, 1)
	return weight * direction


func get_bicircular_weight(position: Vector2, center_target: Vector2, inner_circle_radius: float, inner_circle_weight: float, outer_circle_radius: float, outer_circle_weight: float) -> float:
	var dirstance_to_center := position.distance_to(center_target)
	if dirstance_to_center > outer_circle_radius:
		return outer_circle_weight
	elif dirstance_to_center < inner_circle_radius:
		return inner_circle_weight
	else:
		var distance_to_inner_radius := dirstance_to_center - inner_circle_radius
		var close_range_disntace := outer_circle_radius - inner_circle_radius
		return lerpf(inner_circle_weight, outer_circle_weight, distance_to_inner_radius / close_range_disntace)


func face_towards_target_all() -> void:
	if not player.is_facing_target_goal():
		player.heading = player.heading * -1


func is_ball_possessed_by_opponent() -> bool:
	return ball.carrier != null and ball.carrier.country != player.country


func is_ball_carried_by_teammate() -> bool:
	return ball.carrier != null and ball.carrier != player and ball.carrier.country == player.country


func has_opponents_nearby() -> bool:
	var players = player.opponent_detection_area.get_overlapping_bodies()
	return players.find_custom(func(p: Player): return p.country != player.country) > -1
