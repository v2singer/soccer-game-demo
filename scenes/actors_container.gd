class_name ActorsContainer
extends Node2D

const DURATION_WEIGHT_CACHE := 200
const PLAYER_PREFAB := preload("res://scenes/characters/player.tscn")

@export var ball : Ball
@export var goal_home : Goal
@export var goal_away : Goal

@onready var kickoffs : Node2D = %KickOffs
@onready var spawns : Node2D = %Spawns


var squad_home : Array[Player] = []
var squad_away : Array[Player] = []
var time_since_last_cache_refresh = Time.get_ticks_msec()
var is_checking_for_kickoff_readiness := false

func _init() -> void:
	GameEvents.team_reset.connect(on_team_reset.bind())

func _ready() -> void:
	squad_home = spawn_players(GameManager.countries[0], goal_home)
	goal_home.initialize(GameManager.countries[0])
	spawns.scale.x = -1
	kickoffs.scale.x = -1
	squad_away = spawn_players(GameManager.countries[1], goal_away)
	goal_home.initialize(GameManager.countries[1])

	setup_control_schemes()

func _process(_delta: float) -> void:
	if Time.get_ticks_msec() - time_since_last_cache_refresh > DURATION_WEIGHT_CACHE:
		time_since_last_cache_refresh = Time.get_ticks_msec()
		set_on_duty_weights()
	if is_checking_for_kickoff_readiness:
		checking_for_kickoff_readiness()


func spawn_players(country: String, own_goal: Goal) -> Array[Player]:
	var player_nodes : Array[Player] = []
	var players := DataLoader.get_squad(country)
	var target_goal := goal_home if own_goal == goal_away else goal_away
	for p_i in players.size():
		var player_position := spawns.get_child(p_i).global_position as Vector2
		var player_data := players[p_i] as PlayerResource
		var kickoff_position := player_position
		if p_i > 3:
			kickoff_position = kickoffs.get_child(p_i - 4).global_position as Vector2
		var player := spawn_player(player_position, own_goal, target_goal, player_data, country, kickoff_position)
		player_nodes.append(player)
		add_child(player)
	return player_nodes


func spawn_player(player_position: Vector2, own_goal: Goal, target_goal: Goal, player_data: PlayerResource, country: String, kickoff_position: Vector2) -> Player:
	var player : Player = PLAYER_PREFAB.instantiate()
	player.initialize(player_position, ball, own_goal, target_goal, player_data, country, kickoff_position)
	player.swap_requested.connect(on_player_swap_request.bind())
	return player

func set_on_duty_weights() -> void:
	for squad in [squad_away, squad_home]:
		var cpu_players : Array[Player] = squad.filter(
			func(p: Player): return p.control_schema == Player.ControlSchema.CPU and p.role != Player.Role.GOALTE
			)
		cpu_players.sort_custom(func(p1: Player, p2: Player):
			return p1.spawn_position.distance_squared_to(ball.position) < p2.spawn_position.distance_squared_to(ball.position))
		for i in range(cpu_players.size()):
			cpu_players[i].weight_on_duty_steering = 1 - ease(float(i)/10.0, 0.1)

func checking_for_kickoff_readiness() -> void:
	for squad in [squad_home, squad_away]:
		for player : Player in squad:
			if not player.is_ready_for_kickoff():
				return
	setup_control_schemes()
	is_checking_for_kickoff_readiness = false
	GameEvents.kickoff_ready.emit()

func on_player_swap_request(requester: Player) -> void:
	var squad := squad_home if requester.country == squad_home[0].country else squad_away
	var cpu_players : Array[Player] = squad.filter(
		func(p: Player): return p.control_schema == Player.ControlSchema.CPU and p.role != Player.Role.GOALTE
		)

	cpu_players.sort_custom(func(p1: Player, p2: Player):
		return p1.position.distance_squared_to(ball.position) < p2.position.distance_squared_to(ball.position))
	var closest_cpu_to_ball: Player = cpu_players[0]
	if closest_cpu_to_ball.position.distance_squared_to(ball.position) < requester.position.distance_squared_to(ball.position):
		# P1 or P2
		var player_control_schema := requester.control_schema
		requester.set_control_scheme(Player.ControlSchema.CPU)
		closest_cpu_to_ball.set_control_scheme(player_control_schema)
		print('closest player: ', closest_cpu_to_ball, ' ', closest_cpu_to_ball.control_schema, 'requester: ', requester, ' ', requester.control_schema)
		print('old player control scheme:', player_control_schema)
	else:
		print('no closest player')

func setup_control_schemes() -> void:
	var p1_country := GameManager.player_setup[0]
	if GameManager.is_coop():
		var player_squad := squad_home if squad_home[0].coutnry == p1_country else squad_away
		player_squad[4].set_control_scheme(Player.ControlSchema.P1)
		player_squad[5].set_control_scheme(Player.ControlSchema.P2)
	elif GameManager.is_single_player():
		var player_squad := squad_home if squad_home[0].coutnry == p1_country else squad_away
		player_squad[5].set_control_scheme(Player.ControlSchema.P1)
	else: # versus
		var p1_squad := squad_home if squad_home[0].coutnry == p1_country else squad_away
		var p2_squad := squad_home if p1_squad == squad_away else squad_away
		p1_squad[5].set_control_scheme(Player.ControlSchema.P1)
		p2_squad[5].set_control_scheme(Player.ControlSchema.P2)


func on_team_reset() -> void:
	is_checking_for_kickoff_readiness = true
