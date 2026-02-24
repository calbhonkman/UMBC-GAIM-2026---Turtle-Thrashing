extends Node2D

@onready var player = $"../Player"
@onready var camera = $"../Camera"

@export var CAMERA_LIMIT: float = 1600.0

func _process(delta):
	var cam_limit_x = CAMERA_LIMIT - (get_viewport().get_visible_rect().size.x/2)
	var cam_limit_y = CAMERA_LIMIT - (get_viewport().get_visible_rect().size.y/2)
	camera.global_position.x = clampf(player.global_position.x, -1*cam_limit_x, cam_limit_x)
	camera.global_position.y = clampf(player.global_position.y, -1*cam_limit_y, cam_limit_y)
