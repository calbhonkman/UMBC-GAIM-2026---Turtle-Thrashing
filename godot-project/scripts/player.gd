extends CharacterBody2D

@onready var sprite = $Sprite
@onready var indicator = $"Direction Indicator"
@onready var camera = $"../Camera"

@export var SPEED = 200
@export var CAMERA_DIST = 100
@export var MAX_HEALTH = 5
@export var INVINCIBLE_TIME = 1.0

var health = 5
var invincible_timer = 0
var xp = 0
var level = 1
var levelup_req = level * 10 + ((level-1) * 10) / 4

func _process(delta):
	invincible_timer = max(0, invincible_timer - delta)
	if invincible_timer > 0:
		sprite.modulate = Color(1,1-sqrt(invincible_timer/INVINCIBLE_TIME),1-sqrt(invincible_timer/INVINCIBLE_TIME),1)
	else:
		sprite.modulate = Color(1,1,1,1)
	
	var movement_direction = Input.get_vector("left","right","up","down")
	camera.global_position = global_position + movement_direction * CAMERA_DIST
	if health <= 0:
		sprite.play("death")
		indicator.visible = false
		get_tree().paused = true
	elif movement_direction.length() != 0:
		sprite.play("walk")
		indicator.visible = true
		indicator.rotation = movement_direction.angle()
		sprite.scale.x = abs(sprite.scale.x) * movement_direction.x / abs(movement_direction.x) if movement_direction.x != 0 else sprite.scale.x
		move_and_collide(movement_direction * SPEED * delta)
	else:
		sprite.play("default")
		indicator.visible = false


func _on_area_2d_area_entered(area: Area2D) -> void:
	# If hit by an enemy
	if area.has_meta("enemy"):
		if invincible_timer == 0:
			health -= 1
			invincible_timer = INVINCIBLE_TIME
		area.queue_free()
	# If hit by exp
	elif area.has_meta("exp"):
		pass
