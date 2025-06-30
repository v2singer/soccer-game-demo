class_name PlayerResources
extends Resource

@export var full_name : String
@export var skin_color : Player.SkinColor
@export var role : Player.Role
@export var speed : float
@export var power : float


func _init(n1: String, n2: Player.SkinColor, n3: Player.Role, n4: float, n5: float) -> void:
	full_name = n1
	skin_color = n2
	role = n3
	speed = n4
	power = n5
