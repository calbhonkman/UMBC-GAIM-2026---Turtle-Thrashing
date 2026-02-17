extends Node2D

@onready var player = $"../Player"
const ENEMY = preload("uid://d1k32mfbnnud3")

@export var SPAWNTIMER = 1.0
@export var SPAWNDISTANCE = 500

var timer = 0

func _process(delta):
	timer += delta
	
	if timer >= SPAWNTIMER:
		var new_enemy = ENEMY.instantiate()
		new_enemy.global_position = player.global_position + (SPAWNDISTANCE*Vector2.RIGHT.rotated(randf_range(0, 2*PI)))
		add_child(new_enemy)
		timer = 0
