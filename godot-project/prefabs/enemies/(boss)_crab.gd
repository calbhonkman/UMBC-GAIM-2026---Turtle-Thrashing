extends Area2D

@onready var player = $"/root/Node2D/Player"
@onready var sprite = $AnimatedSprite2D
@onready var hitbox = $CollisionShape2D
@onready var hitbox_slam = $"(hitbox)_slam"
const EXP = preload("uid://bln5qlwy18sjf")

@export var MAX_HEALTH: float = 15
@export var BASE_SPEED: float = 200.0
@export var BASE_DAMAGE: float = 1.0
@export var ATTACK_RANGE: float = 150.0
@export var ATTACK_COOLDOWN: float = 2.0
@export var CHARGE_PREP_TIME: float = 1.5
@export var CHARGE_DURATION: float = 2.0
@export var CHARGE_COOLDOWN: float = 2.0
@export var JUMP_DISTANCE: float = 1000
@export var JUMP_AIR_TIME: float = 3.0
@export var JUMP_WARNING_TIME: float = 1.5
@export var JUMP_COOLDOWN: float = 2.0
@export var ATTACK_TIME: float = 2.0

var health = 1

var mode = "default"
var mode_timer = 0
var charge_direction = Vector2.ZERO
var jump_landing_position = null
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
				elif (abs(player_vect.x) >= (get_viewport_rect().size.x / 2)) or (abs(player_vect.y) >= (get_viewport_rect().size.y / 2)):
					mode = "jumping part one"
					sprite.play("jump1")
				elif player_vect.y >= 0.0:
					global_position += player_dir * BASE_SPEED * delta
					anti_knockback_position = global_position
				elif mode_timer <= 0.0:
					mode = "charging part one"
					mode_timer = CHARGE_PREP_TIME
					charge_direction = player_dir
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
					global_position += charge_direction * (3.0 * BASE_SPEED) * delta
					anti_knockback_position = global_position
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
