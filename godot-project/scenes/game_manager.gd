extends Node2D

@onready var clock = $"../Clock"

# How long the game lasts (in minutes)
@export var GAME_TIME = 5

var remaining_time = 0

func _ready():
	remaining_time = 5 * 60 # Convert minutes to seconds

func _process(delta):
	remaining_time -= delta
	clock.text = str(int(remaining_time/60.0)) + ":" + str(int(fmod(remaining_time, 60)))
func _input(event):
	if event.is_action_pressed("pause"):
		get_tree().paused = !get_tree().paused
