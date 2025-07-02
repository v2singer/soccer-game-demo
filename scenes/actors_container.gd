class_name ActorsContainer
extends Node2D

const PLAYER_PREFAB := preload("res://scenes/characters/player.tscn")

@export var ball : Ball
@export var goal_home : Goal
@export var goal_away : Goal
@export var team_home : String
@export var team_away : String


@onready var spawns : Node2D = %Spawns

var squad_home : Array[Player] = []
var squad_away : Array[Player] = []


func _ready() -> void:
	squad_home = spawn_players(team_home, goal_home)
	spawns.scale.x = -1
	squad_away = spawn_players(team_away, goal_away)

	var this_player : Player = get_children().filter(func(p): return p is Player)[4]
	this_player.control_schema = Player.ControlSchema.P1
	this_player.set_control_texture()


func spawn_players(country: String, own_goal: Goal) -> void:
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
