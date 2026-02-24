extends Area2D

@onready var sprite = $AnimatedSprite2D

@export var LIFETIME = 10.0
@export var FADETIME = 0.3
@export var SPEED = 500.0

var timer = 0
var target = null
var target_direction = null
var isFading = false

func set_target(t: Area2D):
	target = t

func _process(delta):
	timer += delta
	if timer >= LIFETIME:
		queue_free()
	if isFading:
		sprite.modulate = Color(1,1,1,1-(timer/FADETIME))
		if timer > FADETIME:
			queue_free()
	elif target != null:
		target_direction = (target.global_position - global_position)
		target_direction = target_direction / target_direction.length()
		rotation = target_direction.angle()
		
	global_position += target_direction * delta * SPEED
	
	for area in get_overlapping_areas():
		if area == target:
			isFading = true
			timer = 0
		if area.get_script() and area.get_script().get_path() == "res://scripts/enemy.gd":
			area.death()
