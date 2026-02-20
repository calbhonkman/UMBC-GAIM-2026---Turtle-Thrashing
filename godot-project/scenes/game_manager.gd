extends Node2D

@onready var clock = $"../Camera/Clock"

# How long the game lasts (in minutes)
@export var GAME_TIME = 0.1

var remaining_time = 0

func _ready():
	remaining_time = GAME_TIME * 60 # Convert minutes to seconds

func _process(delta):
	if remaining_time > 0:
		remaining_time -= delta
		var minutes = str(int(remaining_time/60))
		var seconds = str(int(fmod(remaining_time, 60)))
		seconds = "0" + seconds if seconds.length() == 1 else seconds
		clock.text = minutes + ":" + seconds
	else:
		get_tree().paused = true
	
func _input(event):
	if event.is_action_pressed("pause"):
		get_tree().paused = !get_tree().paused
