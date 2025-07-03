class_name ActorsContainer
extends Node2D

const DURATION_WEIGHT_CACHE := 200
const PLAYER_PREFAB := preload("res://scenes/characters/player.tscn")

@export var ball : Ball
@export var goal_home : Goal
@export var goal_away : Goal
@export var team_home : String
@export var team_away : String


@onready var spawns : Node2D = %Spawns


var squad_home : Array[Player] = []
var squad_away : Array[Player] = []
var time_since_last_cache_refresh = Time.get_ticks_msec()


func _ready() -> void:
	squad_home = spawn_players(team_home, goal_home)
	spawns.scale.x = -1
	squad_away = spawn_players(team_away, goal_away)

	var this_player : Player = get_children().filter(func(p): return p is Player)[4]
	this_player.control_schema = Player.ControlSchema.P1
	this_player.set_control_texture()


func _process(_delta: float) -> void:
	if Time.get_ticks_msec() - time_since_last_cache_refresh > DURATION_WEIGHT_CACHE:
		time_since_last_cache_refresh = Time.get_ticks_msec()
		set_on_duty_weights()


func spawn_players(country: String, own_goal: Goal) -> Array[Player]:
	var player_nodes : Array[Player] = []
	var players := DataLoader.get_squad(country)
	var target_goal := goal_home if own_goal == goal_away else goal_away
	for p_i in players.size():
		var player_position := spawns.get_child(p_i).global_position as Vector2
		var player_data := players[p_i] as PlayerResource
		var player := spawn_player(player_position, own_goal, target_goal, player_data, country)
		player_nodes.append(player)
		add_child(player)
	return player_nodes


func spawn_player(player_position: Vector2, own_goal: Goal, target_goal: Goal, player_data: PlayerResource, country: String) -> Player:
	var player := PLAYER_PREFAB.instantiate()
	player.initialize(player_position, ball, own_goal, target_goal, player_data, country)
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
