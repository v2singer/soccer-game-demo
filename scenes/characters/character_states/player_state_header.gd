class_name PlayerStateHeader
extends PlayerState

const BALL_MIN_SHOOT := 10.0
const BALL_MAX_SHOOT := 30.0
const BONUS_POWER := 1.3
const HEIGHT_START := 0.1
const HEIGHT_VELOCITY := 1.5


func _enter_tree() -> void:
	animation_player.play("header")
	player.height = HEIGHT_START
	player.height_velocity = HEIGHT_VELOCITY
	ball_detection_area.body_entered.connect(on_ball_entered.bind())

func on_ball_entered(contact_ball: Ball) -> void:
	if contact_ball.can_air_connect(BALL_MIN_SHOOT, BALL_MAX_SHOOT):
		SoundPlayer.paly(SoundPlayer.Sound.POWERSHOT)
		contact_ball.shoot(player.velocity.normalized() * player.power * BONUS_POWER )
	pass


func _process(_delta: float) -> void:
	if player.height == 0:
		transition_state(Player.State.RECOVERING)

