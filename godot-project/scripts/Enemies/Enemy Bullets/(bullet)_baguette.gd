extends Area2D

@onready var player = $"/root/Node2D/Player"

@onready var warning_sprite = $WarningSprite
@onready var dive_box = $DiveBox
@onready var hitbox = $CollisionShape2D
@onready var camera = $"/root/Node2D/GameManager/Camera"
@export var CAMERA_LIMIT: float = 1600.0

# Other enemies may not have these variables:
var mode = "default"
var mode_timer
var dive_area: Rect2
var target_position
@export var WARNING_TIME: float = 2.0
@export var DIVE_SPEED: float = 1000.0

func _ready():
	$AnimatedSprite2D.visible = false
	dive_box.disabled = true
	hitbox.disabled = true
	warning_sprite.visible = false

func _process(delta):
	if player:
		match mode:
			"default":
				mode = "target"
				dive_box.global_position = player.global_position
				dive_area = dive_box.shape.get_rect()
				var x = randf_range(dive_area.position.x, dive_area.position.x + dive_area.size.x)
				var y = randf_range(dive_area.position.y, dive_area.position.y + dive_area.size.y)
				target_position = dive_box.global_position + Vector2(x,y)
				warning_sprite.global_position = target_position
				warning_sprite.visible = true
				mode_timer = WARNING_TIME
			"target":
				mode_timer = max(0, mode_timer - delta)
				if mode_timer == 0:
					mode = "dive"
					$AnimatedSprite2D.visible = true
					warning_sprite.visible = false
					global_position.y = camera.global_position.y - CAMERA_LIMIT / 2
					global_position.x = target_position.x
			"dive":
				global_position.y += DIVE_SPEED * delta
				if global_position.y >= target_position.y:
					mode = "landed"
					hitbox.disabled = false
					dive_box.disabled = true
					
					mode_timer = 1.0
			"landed":
				mode_timer = max(0, mode_timer - delta)
				if mode_timer == 0:
					queue_free()
				elif player.hitbox in get_overlapping_areas():
					player.damage(1)

func play(anim):
	$AnimatedSprite2D.play(anim)
