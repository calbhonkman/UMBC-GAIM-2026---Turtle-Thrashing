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
@export var ATTACK_AMOUNT: int = 3
@export var BULLET: Resource
@export var BULLET_SPEED: float = 500.0
@export var BULLET_LIFETIME: float = 10.0

var health = 1

var mode = "default"
var mode_timer = 0
var anti_knockback_position = null

var bullets = []
var b_direction = []
var b_position = []
var b_lifetime = []
var b_amount = 0

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
					mode = "attacking"
					mode_timer = ATTACK_TIME
					b_amount = 0
					sprite.play("attack")
			"attacking":
				if mode_timer <= 0.0:
					mode = "default"
					mode_timer = ATTACK_COOLDOWN
					sprite.play("default")
				elif mode_timer <= (ATTACK_AMOUNT - b_amount) * (ATTACK_TIME / ATTACK_AMOUNT):
					bullets.append(BULLET.instantiate())
					add_child(bullets.back())
					b_direction.append(player_dir)
					b_position.append(global_position)
					b_lifetime.append(BULLET_LIFETIME)
					b_amount += 1
			"dying":
				var new_xp = EXP.instantiate()
				get_parent().add_child(new_xp)
				new_xp.global_position = global_position
				queue_free()
		
		if bullets.size() > 0:
			for i in range(bullets.size()):
				if i < bullets.size():
					b_lifetime[i] -= delta
					if bullets[i] and b_lifetime[i] <= 0.0:
						bullets[i].queue_free()
					if bullets[i] == null:
						bullets.remove_at(i)
						b_direction.remove_at(i)
						b_position.remove_at(i)
						b_lifetime.remove_at(i)
						i += -1
					else:
						bullets[i].global_position = b_position[i] + b_direction[i] * BULLET_SPEED * delta
						b_position[i] = bullets[i].global_position
						bullets[i].scale.x = -1 * abs(bullets[i].scale.x) if b_direction[i].x < 0 else abs(bullets[i].scale.x)
						for area in bullets[i].get_overlapping_areas():
							if area != self and area.is_in_group("Enemies"):
								area.damage(INF)
								b_direction[i] = (player.global_position - bullets[i].global_position) / (player.global_position - bullets[i].global_position)

func scale_health(s: float):
	health = MAX_HEALTH * s

func damage(dmg: float):
	health -= dmg
	print(health)
	if health <= 0.0:
		mode = "dying"
