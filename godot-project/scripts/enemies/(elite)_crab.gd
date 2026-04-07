extends Area2D

@onready var player = $"/root/Node2D/Player"
@onready var sprite = $AnimatedSprite2D
const EXP = preload("uid://bln5qlwy18sjf")

@export var MAX_HEALTH: float = 15.0
var health: float = MAX_HEALTH

@export var BASE_MOVE_SPEED: float = 300.0
var move_speed: float = BASE_MOVE_SPEED

var stunned: bool = false
@export var STUN_RESIST: float = 100.0 # Percent
var stun_timer: float = 0.0 # Seconds

# Other enemies might not have these variables:
@onready var hitbox = $CollisionShape2D
@onready var hitbox_slam = $"(hitbox)_slam"
@export var BASE_DAMAGE: float = 1.0
@export var ATTACK_RANGE: float = 150.0
@export var ATTACK_COOLDOWN: float = 1.0
@export var CHARGE_PREP_TIME: float = 1.0
@export var CHARGE_DURATION: float = 0.5
@export var CHARGE_COOLDOWN: float = 0.5
@export var JUMP_DISTANCE: float = 1000
@export var JUMP_AIR_TIME: float = 3.0
@export var JUMP_WARNING_TIME: float = 1.5
@export var JUMP_COOLDOWN: float = 1.0
@export var ATTACK_TIME: float = 2.0
var charge_direction = Vector2.ZERO
var anti_knockback_position = null
var jump_landing_position = null
var mode = "default"
var mode_timer = 0

func _ready():
	AudioManager.crabJingle.play()

func _process(delta):
	scale = Vector2(1,1) * (0.75 + clamp(0.25 * health / MAX_HEALTH, 0.0, 0.25))
	if player:
		var player_vect = player.global_position - hitbox_slam.global_position
		var player_dist = player_vect.length()
		var player_dir = player_vect / player_dist
		
		if anti_knockback_position:
			global_position = anti_knockback_position
		scale.x = -1 * abs(scale.x) if player_dir.x > 0 else abs(scale.x)
		
		mode_timer -= delta
		
		match mode:
			"default":
				# Basically cooldown mode
				if mode_timer <= 0.0:
					mode = "hunting"
					sprite.play("walk")
			"hunting":
				if (player.global_position - hitbox_slam.global_position).length() < ($"(hitbox)_slam/CollisionShape2D".shape.radius / 2.0):
					mode = "slamming part one"
					sprite.play("slam1")
				elif (abs(player_vect.x) >= (get_viewport_rect().size.x / 2)) or (abs(player_vect.y) >= (get_viewport_rect().size.y / 2)):
					mode = "jumping part one"
					sprite.play("jump1")
				elif player_vect.y >= 0.0 or abs(player_vect.y) < abs(player_vect.x):
					global_position += player_dir * move_speed * delta
					anti_knockback_position = global_position
				elif mode_timer <= 0.0:
					mode = "charging part one"
					mode_timer = CHARGE_PREP_TIME
					charge_direction = Vector2.UP
					sprite.play("charge1")
			"slamming part one":
				# The slam is split into two separate animations
				# The actual moment of impact is the end of slam1
				# This is the exact moment when damage is dealt
				if not sprite.is_playing():
					mode = "slamming part two"
					for area in hitbox_slam.get_overlapping_areas():
						if area == player.hitbox:
							player.damage(1)
					sprite.play("slam2")
			"slamming part two":
				if not sprite.is_playing():
					mode = "default"
					mode_timer = ATTACK_COOLDOWN
					sprite.play("default")
			"jumping part one":
				if not sprite.is_playing():
					mode = "jumping part one and a half"
					mode_timer = JUMP_AIR_TIME
					hitbox.disabled = true
					sprite.play("jump1.5")
			"jumping part one and a half":
				if mode_timer <= 0.0:
					mode = "jumping part one and a half and a half"
					mode_timer = JUMP_WARNING_TIME
					sprite.play("jump1.5.5")
				else:
					global_position = player.global_position
					anti_knockback_position = global_position
			"jumping part one and a half and a half":
				if mode_timer <= 0.0:
					mode = "jumping part two"
					hitbox.disabled = false
					for area in get_overlapping_areas():
						if area == player.hitbox:
							player.damage(1)
					sprite.play("jump2")
			"jumping part two":
				if not sprite.is_playing():
					mode = "default"
					mode_timer = JUMP_COOLDOWN
			"charging part one":
				if mode_timer <= 0.0:
					mode = "charging part two"
					mode_timer = CHARGE_DURATION
					sprite.play("charge2")
			"charging part two":
				if mode_timer <= 0.0:
					mode = "default"
					mode_timer = CHARGE_COOLDOWN
					sprite.play("default")
				else:
					global_position += charge_direction * (3.0 * move_speed) * delta
					anti_knockback_position = global_position
			"dying":
				if not sprite.is_playing():
					sprite.play("death2")
					mode = "dead"
			"dead":
				if not sprite.is_playing():
					queue_free()

func scale_health(s: float):
	health = MAX_HEALTH * s

func damage(dmg: float):
	if mode == "dying" or mode == "dead":
		return
	health -= dmg
	print(health)
	if health <= 0.0:
		mode = "dying"
		sprite.play("death1")
