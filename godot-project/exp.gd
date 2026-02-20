extends Area2D

@onready var player = $"/root/Node2D/Player"

@export var SPEED = 80

func _process(delta):
	if player:
		var playerDirection = player.global_position - global_position
		playerDirection = playerDirection / playerDirection.length()
		global_position += playerDirection * delta * SPEED

func death():
	queue_free()
