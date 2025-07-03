class_name AIBehavior
extends Node

const AI_TICK_FREQUENCY := 200

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
	print(name + " moving")
	var total_steering_force := Vector2.ZERO
	total_steering_force += get_onduty_streering_force()
	total_steering_force = total_steering_force.limit_length(1.0)
	player.velocity = total_steering_force * player.speed


func perform_ai_decisions():
	print(name + " devision")
	pass

func get_onduty_streering_force() -> Vector2:
	return player.weight_on_duty_steering * player.position.direction_to(ball.position)
