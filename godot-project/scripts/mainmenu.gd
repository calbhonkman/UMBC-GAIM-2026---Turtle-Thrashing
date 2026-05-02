extends Node2D

var game_scene = preload("res://scenes/game.tscn")

@onready var attract_mode = $VideoStreamPlayer
@onready var cursor = $Cursor
@export var ATTRACT_MODE_TIME: float = 15.0
var video_length
var timer

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	attract_mode.visible == false
	timer = ATTRACT_MODE_TIME
	video_length = attract_mode.get_stream_length()

func _process(delta):
	cursor.global_position = get_global_mouse_position()
	timer = max(0, timer - delta)
	if timer == 0 and attract_mode.visible == false:
		# Pick a random spot in the video to play from
		attract_mode.visible = true
		attract_mode.play()
		attract_mode.stream_position = randf_range(0.0, video_length)
		
func _input(event):
	# Video stops playing when the mouse is moved
	if event is InputEventMouseMotion:
		attract_mode.visible = false
		attract_mode.stop()
		timer = ATTRACT_MODE_TIME

func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_quit_button_pressed():
	get_tree().quit()
