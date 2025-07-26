class_name KeyUtils


enum Action {LEFT, RIGHT, UP, DOWN, SHOOT, PASST}

const ACTIONS_MAP : Dictionary = {
	Player.ControlSchema.P1: {
		Action.LEFT: "p1_left",
		Action.RIGHT: "p1_right",
		Action.UP: "p1_up",
		Action.DOWN: "p1_down",
		Action.SHOOT: "p1_shoot",
		Action.PASST: "p1_pass"
	},
	Player.ControlSchema.P2: {
		Action.LEFT: "p2_left",
		Action.RIGHT: "p2_right",
		Action.UP: "p2_up",
		Action.DOWN: "p2_down",
		Action.SHOOT: "p2_shoot",
		Action.PASST: "p2_pass",
	}
}

static func get_input_vector(schema: Player.ControlSchema) -> Vector2 :
	var map : Dictionary = ACTIONS_MAP[schema]
	return Input.get_vector(map[Action.LEFT], map[Action.RIGHT], map[Action.UP], map[Action.DOWN])

static func is_action_pressed(schema: Player.ControlSchema, action: Action) -> bool:
	return Input.is_action_pressed(ACTIONS_MAP[schema][action])

static func is_action_just_pressed(schema: Player.ControlSchema, action: Action) -> bool:
	return Input.is_action_just_pressed(ACTIONS_MAP[schema][action])

static func is_action_just_released(schema: Player.ControlSchema, action: Action) -> bool:
	return Input.is_action_just_released(ACTIONS_MAP[schema][action])
