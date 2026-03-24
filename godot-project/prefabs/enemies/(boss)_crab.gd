extends Area2D

@onready var player = $"/root/Node2D/Player"
@onready var sprite = $AnimatedSprite2D
@onready var hitbox_slam = $"(hitbox)_slam"
@onready var hitbox_jump = $"(hitbox)_jump"
const EXP = preload("uid://bln5qlwy18sjf")

@export var MAX_HEALTH: float = 30
@export var BASE_SPEED: float = 200.0
@export var BASE_DAMAGE: float = 1.0
@export var ATTACK_RANGE: float = 150.0
@export var ATTACK_COOLDOWN: float = 2.0
@export var CHARGE_PREP_TIME: float = 1.0
@export var CHARGE_DURATION: float = 2.0
@export var CHARGE_COOLDOWN: float = 2.0
@export var JUMP_DISTANCE: float = 1000
@export var ATTACK_TIME: float = 2.0

var health = 1

var mode = "default"
var mode_timer = 0
var charge_direction = Vector2.ZERO
var anti_knockback_position = null

func _ready():
	health = MAX_HEALTH
	anti_knockback_position = global_position

func _process(delta):
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
				if player.hitbox in hitbox_slam.get_overlapping_areas():
					mode = "slamming part one"
					sprite.play("slam1")
				elif player_dist < JUMP_DISTANCE and player_vect.y >= 0.0:
					global_position += player_dir * BASE_SPEED * delta
					anti_knockback_position = global_position
				elif player_dist < JUMP_DISTANCE and mode_timer <= 0.0:
					mode = "charging part one"
					mode_timer = CHARGE_PREP_TIME
					charge_direction = player_dir
					sprite.play("charge1")
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
					global_position += charge_direction * (3.0 * BASE_SPEED) * delta
					anti_knockback_position = global_position
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
			"dying":
				var new_xp = EXP.instantiate()
				get_parent().add_child(new_xp)
				new_xp.global_position = global_position
				queue_free()

func scale_health(s: float):
	health = MAX_HEALTH * s

func damage(dmg: float):
	health -= dmg
	print(health)
	if health <= 0.0:
		mode = "dying"
