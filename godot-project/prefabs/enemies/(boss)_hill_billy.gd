extends Area2D

@onready var player = $"/root/Node2D/Player"
@onready var sprite_p1 = $"Sprite (Phase 1)"
@onready var sprite_p2 = $"Sprite (Phase 2)"
@onready var knife_hitbox_p1 = $"Knife Hitbox (Phase 1)"
@onready var knife_hitbox_p2 = $"Knife Hitbox (Phase 2)"
const EXP = preload("uid://bln5qlwy18sjf")

@export var MAX_HEALTH: float = 15.0
var health: float = MAX_HEALTH

@export var BASE_MOVE_SPEED: float = 250.0
var move_speed: float = BASE_MOVE_SPEED

# Other enemies might not have these variables:
@export var FORK: Resource
@export var BEAM: Resource
@export var BAGUETTE: Resource
@export var BASE_DAMAGE: float = 1.0
@export var ATTACK_TIME: float = 5.0
@export var PULL_TIME: float = 5.0
@export var PULL_STRENGTH: float = 150.0
var anti_knockback_position = null
var sprite = null
var mode = "default"
var next_mode = "fork"
var mode_timer = 0
var bullets = []

func _ready():
	sprite = sprite_p1
	AudioManager.crabJingle.play()

func _process(delta):
	scale = Vector2(1,1) * (0.75 + clamp(0.25 * health / MAX_HEALTH, 0.0, 0.25))
	if player:
		var player_vect = player.global_position - global_position
		var player_dist = player_vect.length()
		var player_dir = player_vect / player_dist
		
		if anti_knockback_position:
			global_position = anti_knockback_position
		scale.x = -1 * abs(scale.x) if player_dir.x > 0 else abs(scale.x)
		
		mode_timer -= delta
		
		match mode:
			"default":
				# Basically cooldown mode
				if health <= 0.5 * MAX_HEALTH:
					mode = "transition"
					sprite.play("transition")
				elif mode_timer <= 0.0:
					mode = "hunting"
					sprite.play("walk")
			"transition":
				if not sprite.is_playing():
					sprite.visible = false
					sprite = sprite_p2
					sprite.visible = true
					mode = "default"
					sprite.play("default")
			"hunting":
				var knife_hitbox = knife_hitbox_p1 if sprite == sprite_p1 else knife_hitbox_p2
				if next_mode == "knife1":
					if player.hitbox in knife_hitbox.get_overlapping_areas():
						mode = "knife1"
						sprite.play("knife1")
					else:
						global_position += player_dir * move_speed * delta
						anti_knockback_position = global_position
				else:
					mode = next_mode
					mode_timer = ATTACK_TIME
					sprite.play(next_mode)
			"fork":
				if mode_timer <= 0.0:
					mode = "default"
					next_mode = "knife1"
					sprite.play("default")
			"knife1":
				if not sprite.is_playing():
					mode = "knife2"
					var knife_hitbox = knife_hitbox_p1 if sprite == sprite_p1 else knife_hitbox_p2
					if player.hitbox in knife_hitbox.get_overlapping_areas():
						player.damage(1)
					sprite.play("knife2")
			"knife2":
				if not sprite.is_playing():
					mode = "default"
					next_mode = "baguette"
					sprite.play("default")
			"baguette":
				if mode_timer <= 0.0:
					mode = "default"
					next_mode = "beam1"
					sprite.play("default")
			"beam1":
				if not sprite.is_playing():
					mode = "beam2"
					mode_timer = PULL_TIME
					sprite.play("beam2")
			"beam2":
				if mode_timer <= 0.0:
					mode = "beam3"
					sprite.play("beam3")
				else:
					player.global_position -= player_dir * PULL_STRENGTH * delta
			"beam3":
				if not sprite.is_playing():
					mode = "default"
					next_mode = "fork"
					sprite.play("default")
			"dying":
				if not sprite.is_playing():
					queue_free()

func scale_health(s: float):
	health = MAX_HEALTH * s

func damage(dmg: float):
	if mode == "dying":
		return
	health -= dmg
	if health <= 0.0:
		mode = "dying"
		sprite.play("death")
