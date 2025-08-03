class_name PlayerStateVolleyKick
extends PlayerState

const BALL_MIN_SHOOT := 1.0
const BALL_MAX_SHOOT := 20.0
const BONUS_POWER := 1.5


func _enter_tree() -> void:
	animation_player.play("volley_kick")
	ball_detection_area.body_exited.connect(on_ball_entered.bind())


func on_ball_entered(contact_ball: Ball) -> void:
	if contact_ball.can_air_connect(BALL_MIN_SHOOT, BALL_MAX_SHOOT):
		var destination := target_goal.get_random_target_position()
		var direction := ball.position.direction_to(destination)
		SoundPlayer.paly(SoundPlayer.Sound.POWERSHOT)
		contact_ball.shoot(direction * player.power * BONUS_POWER)


func on_animation_complete() -> void:
	transition_state(Player.State.RECOVERING)
