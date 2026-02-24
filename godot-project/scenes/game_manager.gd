extends Node2D

@onready var player = $"../Player"
@onready var camera = $"../Camera"
@onready var clock = $"../Camera/Clock"

@export var CAMERA_LIMIT: float = 1600.0
@export var GAME_TIME: float = 5.0 # minutes

var game_timer = 0.0

func _ready():
	game_timer = GAME_TIME * 60 # seconds

func _process(delta):
	var cam_limit_x = CAMERA_LIMIT - (get_viewport().get_visible_rect().size.x/2)
	var cam_limit_y = CAMERA_LIMIT - (get_viewport().get_visible_rect().size.y/2)
	camera.global_position.x = clampf(player.global_position.x, -1*cam_limit_x, cam_limit_x)
	camera.global_position.y = clampf(player.global_position.y, -1*cam_limit_y, cam_limit_y)
	
	if game_timer <= 0.0:
		get_tree().paused = true
	
	if not get_tree().paused:
		game_timer = clampf(game_timer - delta, 0, GAME_TIME * 60.0)
		var timer_minutes = str(int(game_timer / 60.0))
		var timer_seconds = ("0" if (fmod(game_timer, 60.0) < 10) else "") + str(int(fmod(game_timer, 60.0)))
		clock.text = timer_minutes + ":" + timer_seconds
	
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = !get_tree().paused
