class_name BallStateCarried
extends BallState


const DRIBBLE_FREQUENCY : float = 10.0
const DRIBBLE_INTENSITY : float = 3.0
const OFFSET_FROM_PLAYER := Vector2(10, 4)

var drible_time = 0.0

func _enter_tree() -> void:
	assert(carrier != null)
	GameEvents.ball_possessed.emit(carrier.fullname)

func _process(delta: float) -> void:
	var vx := 0.0

	drible_time += delta

	if carrier.velocity != Vector2.ZERO:
		if carrier.velocity.x != 0:
			vx = cos(drible_time * DRIBBLE_FREQUENCY) * DRIBBLE_INTENSITY
		if carrier.heading.x >= 0:
			animation_player.play("roll")
			animation_player.advance(0)
		else:
			animation_player.play_backwards("roll")
			animation_player.advance(0)
	else:
		animation_player.play("idle")
	process_gravity(delta)
	ball.position = carrier.position + Vector2(
		vx + carrier.heading.x * OFFSET_FROM_PLAYER.x, OFFSET_FROM_PLAYER.y)

func _exit_tree() -> void:
	GameEvents.ball_released.emit()
