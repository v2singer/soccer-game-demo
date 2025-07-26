class_name UI
extends CanvasLayer


@onready var flag_textures : Array[TextureRect] = [%HomeFlagTexture, %AwayFlagTexture]
@onready var player_label : Label = %PlayerLabel
@onready var score_label : Label = %ScoreLabel
@onready var time_label : Label = %TimeLabel

func _ready() -> void:
	update_score()
	update_flags()
	update_clock()
	player_label.text = ""


func _process(_delta: float) -> void:
	update_clock()


func update_score() -> void:
	score_label.text = ScoreHepler.get_score_text(GameManager.score)


func update_flags() -> void:
	for i in flag_textures.size():
		flag_textures[i].texture = FlagHelper.get_texture(GameManager.countries[i])


func update_clock() -> void:
	if GameManager.time_left < 0:
		time_label.modulate = Color.YELLOW
	time_label.text = TimeHelper.get_time_text(GameManager.time_left)
