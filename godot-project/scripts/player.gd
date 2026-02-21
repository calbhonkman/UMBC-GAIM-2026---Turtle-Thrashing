extends CharacterBody2D

@onready var sprite = $Sprite
@onready var indicator = $Indicator
@onready var camera = $Camera

@export var SPEED = 200
@export var CAMERA_LIMIT = 1600
@export var MAX_HEALTH = 5
@export var INVINCIBLE_TIME = 1.0

var health
var invincible_timer = 0
var experience = 0
var level = 1

func _ready():
	health = MAX_HEALTH

func _process(delta):
	var cam_limit_x = CAMERA_LIMIT - (get_viewport().get_visible_rect().size.x/2)
	var cam_limit_y = CAMERA_LIMIT - (get_viewport().get_visible_rect().size.y/2)
	camera.global_position.x = clampf(global_position.x, -1*cam_limit_x, cam_limit_x)
	camera.global_position.y = clampf(global_position.y, -1*cam_limit_y, cam_limit_y)
	
	invincible_timer = max(0, invincible_timer - delta)
	if invincible_timer > 0:
		sprite.modulate = Color(1,1-sqrt(invincible_timer/INVINCIBLE_TIME),1-sqrt(invincible_timer/INVINCIBLE_TIME),1)
	else:
		sprite.modulate = Color(1,1,1,1)
	
	if experience >= (level * 10 + ((level-1) * 10) / 4):
		level += 1
	
	var movement_direction = Input.get_vector("left","right","up","down")
	if health <= 0:
		sprite.play("death")
		indicator.visible = false
		get_tree().paused = true
	elif movement_direction.length() != 0:
		sprite.play("walk")
		indicator.visible = true
		indicator.rotation = movement_direction.angle()
		sprite.scale.x = abs(sprite.scale.x) * movement_direction.x / abs(movement_direction.x) if movement_direction.x != 0 else sprite.scale.x
		velocity = movement_direction * SPEED
		move_and_slide()
	elif health > 0:
		sprite.play("default")
		indicator.visible = false


func _on_area_2d_area_entered(area: Area2D) -> void:
	# If hit by an enemy
	if area.get_script() and area.get_script().get_path() == "res://scripts/enemy.gd":
		if invincible_timer == 0:
			health -= 1
			invincible_timer = INVINCIBLE_TIME
			if health == 0:
				sprite.play("death")
		area.queue_free()
	# If hit by exp
	elif area.has_meta("exp"):
		experience += 1
		area.queue_free()
