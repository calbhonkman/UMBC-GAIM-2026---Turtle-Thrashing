extends Area2D

@onready var player = $"/root/Node2D/Player"
@onready var sprite = $AnimatedSprite2D
const EXP = preload("uid://bln5qlwy18sjf")

@export var MAX_HEALTH: float = 30
@export var BASE_SPEED: float = 300.0
@export var BASE_DAMAGE: float = 1.0
@export var ATTACK_RANGE: float = 350.0
@export var ATTACK_COOLDOWN: float = 6.0
@export var PREPARE_TIME: float = 1.0
@export var ATTACK_TIME: float = 2.0

var health = 1

var mode = "default"
var mode_timer = 0
var anti_knockback_position = null

func _ready():
	health = MAX_HEALTH
	anti_knockback_position = global_position

func _process(delta):	
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
				if mode_timer <= 0.0:
					mode = "hunting"
			"hunting":
				if player_dist > ATTACK_RANGE:
					global_position += player_dir * BASE_SPEED * delta
					anti_knockback_position = global_position
					sprite.play("walk")
				elif player_dist <= ATTACK_RANGE:
					mode = "charging"
					mode_timer = PREPARE_TIME
					sprite.play("charge")
			"charging":
				if mode_timer <= 0.0:
					mode = "slamming"
					mode_timer = ATTACK_TIME
					sprite.play("slam")
			"slamming":
				if mode_timer <= 0.0:
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
