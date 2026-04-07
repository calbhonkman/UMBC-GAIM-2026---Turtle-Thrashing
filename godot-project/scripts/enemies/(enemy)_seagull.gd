extends Area2D

@onready var player = $"/root/Node2D/Player"
@onready var sprite = $AnimatedSprite2D
@onready var warning_sprite = $WarningSprite
@onready var dive_box = $DiveBox
@onready var hitbox = $CollisionShape2D
@onready var camera = $"/root/Node2D/GameManager/Camera"
@export var CAMERA_LIMIT: float = 1600.0
const EXP = preload("uid://bln5qlwy18sjf")

@export var MAX_HEALTH: float = 2.0
var health: float = MAX_HEALTH

@export var BASE_MOVE_SPEED: float = 40.0
var move_speed: float = BASE_MOVE_SPEED

var stunned: bool = false
@export var STUN_RESIST: float = 0.0 # Percent
var stun_timer: float = 0.0 # Seconds

var dying: bool = false
@export var DYING_TIME: float = 0.5
var dying_timer: float = DYING_TIME
@export var EXP_AMOUNT: int = 1

# Other enemies may not have these variables:
var mode = "default"
var mode_timer
var dive_area: Rect2
var target_position
@export var COOLDOWN_TIME: float = 5.0
@export var WARNING_TIME: float = 2.0
@export var LAND_TIME: float = 2.0
@export var STRUGGLE_TIME: float = 5.0
@export var DIVE_SPEED: float = 1000.0

func _ready():
	dive_box.disabled = true
	hitbox.disabled = true
	sprite.visible = false
	warning_sprite.visible = false
	mode_timer = COOLDOWN_TIME

func _process(delta):
	scale = Vector2(1,1) * (0.75 + clamp(0.25 * health / MAX_HEALTH, 0.0, 0.25))
	if dying and dying_timer > 0.0:
		monitorable = false
		monitoring = false
		dying_timer -= delta
		scale = Vector2(1,1) * clamp(0.75 * dying_timer / DYING_TIME, 0.0, 0.75)
		sprite.modulate = Color(1,0,0,clamp(0.5 * dying_timer / DYING_TIME, 0.0, 0.5))
	elif dying and dying_timer <= 0.0:
		AudioManager.poof.play()
		for i in round(MAX_HEALTH):
			var new_xp = EXP.instantiate()
			get_parent().add_child(new_xp)
			new_xp.global_position = global_position
		queue_free()
	elif player:
		if stunned:
			stun_timer -= delta
			if stun_timer <= 0:
				stunned = false
				sprite.modulate = Color(1,1,1,1)
		else: 	
			match mode:
				"default":
					mode_timer = max(0, mode_timer - delta)
					if mode_timer == 0:
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
						rotation = 90
						mode = "dive"
						warning_sprite.visible = false
						sprite.visible = true
						sprite.play("default")
						global_position.y = camera.global_position.y - CAMERA_LIMIT / 2
						global_position.x = target_position.x
				"dive":
					global_position.y += DIVE_SPEED * delta
					if global_position.y >= target_position.y:
						rotation = 0
						mode = "land"
						mode_timer = LAND_TIME
						hitbox.disabled = false
						sprite.play("land")
						AudioManager.rulerTwang.play()
				"land":
					mode_timer = max(0, mode_timer - delta)
					if mode_timer == 0:
						mode = "struggle"
						mode_timer = STRUGGLE_TIME
						sprite.play("struggle")
				"struggle":
					mode_timer = max(0, mode_timer - delta)
					if mode_timer == 0:
						mode = "escape"
						hitbox.disabled = true
						sprite.play("escape")
				"escape":
					await sprite.animation_finished
					mode_timer = COOLDOWN_TIME
					mode = "default"
					hitbox.disabled = true
					sprite.visible = false

func scale_health(s: float):
	MAX_HEALTH *= s
	health = MAX_HEALTH

func damage(dmg: float):
	health -= dmg
	if health <= 0.0:
		dying = true
		
func stun(time: float):
	if stunned != true:
		stunned = true
		stun_timer = time
		sprite.modulate = Color(0.788, 0.788, 0.0, 1.0)
