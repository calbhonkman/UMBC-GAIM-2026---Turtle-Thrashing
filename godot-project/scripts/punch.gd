extends Area2D

@onready var sprite = $AnimatedSprite2D

@export var CHARGEUP = 1.0
@export var LIFETIME = 3.0
@export var FADETIME = 0.3
@export var SPEED = 500.0

var timer = 0
var target = null
var target_direction = Vector2.ZERO

var isCharging = true
var isFading = false

func set_target(t: Area2D):
	target = t
	visible = true

func _process(delta):
	timer += delta
	if isCharging and timer < CHARGEUP:
		pass
	elif isCharging and timer >= CHARGEUP:
		isCharging = false
	
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
		if area.has_meta("enemy"):
			area.death()
