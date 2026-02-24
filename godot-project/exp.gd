extends Area2D

@onready var player = $"/root/Node2D/Player"

@export var SPEED = 80

func _process(delta):
	pass

func death():
	queue_free()
