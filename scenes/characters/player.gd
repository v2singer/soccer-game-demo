class_name Player
extends CharacterBody2D

signal swap_requested(player: Player)

const BALL_CONTROL_HEIGHT_MAX := 10.0
const CONTROL_SPRITE_MAP : Dictionary = {
	ControlSchema.CPU : preload("res://assets/art/props/cpu.png"),
	ControlSchema.P1 : preload("res://assets/art/props/1p.png"),
	ControlSchema.P2 : preload("res://assets/art/props/2p.png")
}

const GRAVITY := 8.0
const WALK_ANIM_THERSHOULD := 0.6

enum ControlSchema{CPU, P1, P2}
enum Role {GOALTE, DEFENSE, MIDFIELD, OFFENSE}
enum SkinColor {LIGHT, MEDIUM, DARK}
enum State {MOVING, TACKLING, RECOVERING, PREP_SHOOT, SHOOTING, PASSING, HEADER, VOLLEY_KICK, BICYCLE_KICK, CHEST_CONTROL, HURT, DIVING, CELEBRATING, MOURNING, RESETING}

@export var ball : Ball
@export var control_schema : ControlSchema
@export var own_goal : Goal
@export var power : float
@export var speed : float
@export var target_goal : Goal

@onready var animation_player : AnimationPlayer = %AnimationPlayer
@onready var ball_detection_area : Area2D = %BallDetectionArea
@onready var control_sprite : Sprite2D = %ControlSprite
@onready var player_sprite : Sprite2D = $PlayerSprite
@onready var goalie_hands_collider : CollisionShape2D = %GoalieHandsCollider
@onready var permanent_damage_emitter_area : Area2D = %PermanentDamageEmitterArea
@onready var tackle_damege_emitter_area : Area2D = %TackelDamageEmitterArea
@onready var teammate_detection_area : Area2D = %TeammateDetectionArea
@onready var opponent_detection_area : Area2D = %OpponentDetectionArea
@onready var root_particles : Node2D = %RootParticles
@onready var run_particles : GPUParticles2D = %RunParticles

var ai_behavior_factory : AIBehaviorFactory = AIBehaviorFactory.new()
var country : String = ""
var current_state : PlayerState = null
var current_ai_behavior : AIBehavior = null
var fullname := ""
var kickoff_position : Vector2 = Vector2.ZERO
var heading := Vector2.RIGHT
var height := 0.0
var height_velocity := 0.0
var state := State.MOVING
var role := Player.Role.MIDFIELD
var skin_color := Player.SkinColor.MEDIUM
var spawn_position := Vector2.ZERO
var state_factory := PlayerStateFactory.new()
var weight_on_duty_steering := 0.0


func _ready() -> void:
	set_control_texture()
	setup_ai_behavior()
	switch_state(State.MOVING)
	permanent_damage_emitter_area.monitoring = role == Role.GOALTE
	goalie_hands_collider.disabled = role != Role.GOALTE
	set_shader_properties()
	tackle_damege_emitter_area.body_entered.connect(on_tackle_player.bind())
	permanent_damage_emitter_area.body_entered.connect(on_tackle_player.bind())
	spawn_position = position
	GameEvents.team_scored.connect(on_team_scored.bind())
	GameEvents.game_over.connect(on_game_over.bind())
	var initialize_position := kickoff_position if country == GameManager.countries[0] else spawn_position
	switch_state(State.RESETING, PlayerStateData.build().set_reset_position(initialize_position))


func _process(delta: float) -> void:
	flip_sprites()
	set_sprite_visibility()
	process_gravity(delta)
	move_and_slide()


func set_shader_properties() -> void:
	player_sprite.material.set_shader_parameter("skin_color", skin_color)
	var countries := DataLoader.get_countries()
	var country_color := countries.find(country)
	country_color = clampi(country_color, 0, countries.size() - 1)
	player_sprite.material.set_shader_parameter("team_color", country_color)


func initialize(c_position: Vector2, c_ball: Ball, c_own_goal: Goal, c_target_goal: Goal, c_player_data: PlayerResource, c_country: String, c_kick_off_position: Vector2) -> void:
	position = c_position
	ball = c_ball
	own_goal = c_own_goal
	target_goal = c_target_goal
	fullname = c_player_data.full_name
	role = c_player_data.role
	skin_color = c_player_data.skin_color
	speed = c_player_data.speed
	power = c_player_data.power
	heading = Vector2.LEFT if target_goal.position.x < position.x else Vector2.RIGHT
	country = c_country
	kickoff_position = c_kick_off_position


func setup_ai_behavior() -> void:
	current_ai_behavior = ai_behavior_factory.get_ai_behavior(role)
	current_ai_behavior.setup(self, ball, teammate_detection_area)
	current_ai_behavior.name = "AI Behavior"
	add_child(current_ai_behavior)


func switch_state(set_state: State, state_data: PlayerStateData = PlayerStateData.new()) -> void:
	if current_state != null:
		current_state.queue_free()

	current_state = state_factory.get_fresh_state(set_state)
	current_state.setup(self, state_data, animation_player, ball,
		teammate_detection_area, ball_detection_area, own_goal,
		target_goal, current_ai_behavior, tackle_damege_emitter_area,
		opponent_detection_area)
	current_state.state_transition_requested.connect(switch_state.bind())
	current_state.name = "PlayerStateMachine: " + str(set_state)
	call_deferred("add_child", current_state)


func set_movement_animation() -> void:
	var vel_length := velocity.length()
	if vel_length < 1:
		animation_player.play("idle") # almost stop
	elif vel_length < speed * WALK_ANIM_THERSHOULD:
		animation_player.play("walk") # slow run
	else:
		animation_player.play("run") # run


func process_gravity(delta: float) -> void:
	if height > 0:
		height_velocity -= GRAVITY * delta
		height += height_velocity
		if height <= 0:
			height = 0
	player_sprite.position = Vector2.UP * height


func set_heading() -> void:
	if velocity.x > 0:
		heading = Vector2.RIGHT
	elif velocity.x < 0:
		heading = Vector2.LEFT

func flip_sprites() -> void:
	if heading == Vector2.RIGHT:
		player_sprite.flip_h = false
		tackle_damege_emitter_area.scale.x = 1
		opponent_detection_area.scale.x = 1
		root_particles.scale.x = 1
	elif heading == Vector2.LEFT:
		player_sprite.flip_h = true
		tackle_damege_emitter_area.scale.x = -1
		opponent_detection_area.scale.x = -1
		root_particles.scale.x = -1

func get_hurt(hurt_origin: Vector2) -> void:
	switch_state(Player.State.HURT, PlayerStateData.build().set_hurt_dirction(hurt_origin))

func has_ball() -> bool:
	return ball.carrier == self


func is_ready_for_kickoff() -> bool:
	return current_state != null and current_state.is_ready_for_kickoff()

func set_control_texture() -> void:
	control_sprite.texture = CONTROL_SPRITE_MAP[control_schema]

func set_sprite_visibility() -> void:
	control_sprite.visible = has_ball() or not control_schema == ControlSchema.CPU
	run_particles.emitting = velocity.length() == speed

func set_control_scheme(scheme: ControlSchema) -> void:
	control_schema = scheme
	set_control_texture()

func get_pass_request(player: Player) -> void:
	if ball.carrier == self and current_state != null and current_state.can_pass():
		switch_state(Player.State.PASSING, PlayerStateData.build().set_pass_target(player))

func is_facing_target_goal() -> bool:
	var direction_to_target_goal := position.direction_to(target_goal.position)
	return heading.dot(direction_to_target_goal) > 0

func on_animation_complete() -> void:
	if current_state != null:
		current_state.on_animation_complete()

func on_tackle_player(player) -> void:
	if player is Player:
		if player != self and player.country != country and player == ball.carrier:
			player.get_hurt(position.direction_to(player.position))

func on_team_scored(team_scored_on: String) -> void:
	if country == team_scored_on:
		switch_state(Player.State.MOURNING)
	else:
		switch_state(Player.State.CELEBRATING)

func on_game_over(winning_team: String) -> void:
	if country == winning_team:
		switch_state(Player.State.MOURNING)
	else:
		switch_state(Player.State.CELEBRATING)

func control_ball() -> void:
	if ball.height > BALL_CONTROL_HEIGHT_MAX:
		switch_state(Player.State.CHEST_CONTROL)

func can_carry_ball() -> bool:
	return current_state != null and current_state.can_carry_ball()

func face_towards_target_all() -> void:
	if not is_facing_target_goal():
		heading = heading * -1
