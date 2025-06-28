class_name PlayerStatePassing
extends PlayerState

func _enter_tree() -> void:
	animation_player.play("kick")

	player.velocity = Vector2.ZERO


func on_animation_complete() -> void:
	var pass_target := find_teammate_in_view()
	print('pass target is: ', pass_target)
	if pass_target == null:
		print('not target:', player.heading * player.speed)
		ball.pass_to(ball.position + player.heading * player.speed)
	else:
		print('has target:', pass_target.position , pass_target.velocity)
		ball.pass_to(pass_target.position + pass_target.velocity)
	transition_state(Player.State.MOVING)


func find_teammate_in_view() -> Player:
	var players_in_view := teammate_detection_area.get_overlapping_bodies()
	var teammate_in_view : Array[Player] = []
	for pitem in players_in_view:
		if pitem is Player and pitem != player:
			teammate_in_view.append(pitem)

	teammate_in_view.sort_custom(
		func(p1: Player, p2: Player): return (
			p1.position.distance_squared_to(player.position) < p2.position.distance_squared_to(player.position)
			)
		)
	if teammate_in_view.size() > 0:
		return teammate_in_view[0]
	return null
