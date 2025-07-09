class_name AIBehavior
extends Node

const AI_TICK_FREQUENCY := 200

var ball : Ball = null
var player : Player = null
var teammate_detection_area : Area2D = null
var opponent_detection_area_not_used : Area2D = null # TODO: xxx
var time_since_last_ai_tick := Time.get_ticks_msec()


func _ready() -> void:
	time_since_last_ai_tick = Time.get_ticks_msec() + randi_range(0, AI_TICK_FREQUENCY)


func setup(c_player: Player, c_ball: Ball, c_teammate_detection_area: Area2D) -> void:
	ball = c_ball
	player = c_player
	teammate_detection_area = c_teammate_detection_area


func process_ai() -> void:
	if Time.get_ticks_msec() - time_since_last_ai_tick > AI_TICK_FREQUENCY:
		time_since_last_ai_tick = Time.get_ticks_msec()
		perform_ai_movement()
		perform_ai_decisions()


func perform_ai_movement() -> void:
	pass


func perform_ai_decisions() -> void:
	pass


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
	var players = player.opponent_detection_area.get_overlapping_bodies().filter(func(pitem): return pitem is Player)
	return players.find_custom(func(p): return p is Player and p.country != player.country) > -1
