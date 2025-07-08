class_name AIBehaviorGoalie
extends AIBehavior

var PROXIMITY_CONCERN := 1.0


func perform_ai_movement() -> void:
	var total_steering_force := get_goalie_steering_force()
	total_steering_force = total_steering_force.limit_length(1.0)
	player.velocity = total_steering_force * player.speed


func perform_ai_decisions() -> void:
	if ball.is_headed_for_scoring_area(player.own_goal.get_scoring_area()):
		player.switch_state(Player.State.DIVING)
	pass


func get_goalie_steering_force() -> Vector2:
	var top_t := player.own_goal.get_top_target_positon()
	var bottom_t := player.own_goal.get_bottom_target_position()
	var center := player.spawn_position
	var target_y := clampf(ball.position.y, top_t.y, bottom_t.y)
	var destination := Vector2(center.x, target_y)
	var direction := player.position.direction_to(destination)
	var distance_to_destination := player.position.distance_to(destination)
	var weight := clampf(distance_to_destination / PROXIMITY_CONCERN, 0, 1)
	return weight * direction
