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

var dying: bool = false
@export var DYING_TIME: float = 0.5
var dying_timer: float = DYING_TIME
@export var EXP_AMOUNT: int = 1

# Other enemies may not have these variables:
@export var ATTACK_RANGE: float = 350.0
@export var ATTACK_COOLDOWN: float = 4.0
@export var PREPARE_TIME: float = 1.0
@export var ATTACK_TIME: float = 1.0
@export var ATTACK_AMOUNT: int = 3
@export var BULLETS: Array[Resource]
@export var RACCOON: Resource
@export var BULLET_SPEED: float = 500.0
@export var BULLET_LIFETIME: float = 3.0
var anti_knockback_position = null
var mode = "default"
var mode_timer = 0
var bullets = []
var b_direction = []
var b_position = []
var b_lifetime = []
var b_amount = 0

func _ready():
	#Test
	AudioManager.raccoonJingle.play()

func _process(delta):
	scale = Vector2(1,1) * (0.75 + clamp(0.25 * health / MAX_HEALTH, 0.0, 0.25))
	if dying and dying_timer > 0.0:
		monitorable = false
		monitoring = false
		dying_timer -= delta
		scale = Vector2(1,1) * clamp(0.75 * dying_timer / DYING_TIME, 0.0, 0.75)
		sprite.modulate = Color(1,0,0,clamp(0.5 * dying_timer / DYING_TIME, 0.0, 0.5))
	elif dying and dying_timer <= 0.0:
		for i in EXP_AMOUNT:
			var new_xp = EXP.instantiate()
			get_parent().add_child(new_xp)
			new_xp.global_position = global_position
		queue_free()
	elif player:
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
					global_position += player_dir * move_speed * delta
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
					if randi_range(1,20) == 1:
						bullets.append(BULLETS[2].instantiate())
					else:
						bullets.append(BULLETS[randi_range(0,1)].instantiate())
					add_child(bullets.back())
					b_direction.append(player_dir)
					b_position.append(global_position)
					b_lifetime.append(BULLET_LIFETIME)
					b_amount += 1
			"dying":
				queue_free()
		
		if bullets.size() > 0:
			for i in range(bullets.size()):
				if i < bullets.size():
					b_lifetime[i] -= delta
					if bullets[i] and b_lifetime[i] <= 0.0:
						if bullets[i].get_meta("bullet_type") == "Raccoon":
							var new_enemy = RACCOON.instantiate()
							$"/root/Node2D/(Group) Enemies".add_child(new_enemy)
							new_enemy.global_position = bullets[i].global_position
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
							if bullets[i].has_meta("bullet_type") and bullets[i].get_meta("bullet_type") == "Bowling" and area != self and area.is_in_group("Enemies"):
								area.damage(INF)
								b_direction[i] = (player.global_position - b_position[i]) / (player.global_position - b_position[i]).length()

func scale_health(s: float):
	health = MAX_HEALTH * s

func damage(dmg: float):
	health -= dmg
	print(health)
	if health <= 0.0:
		mode = "dying"

func stun(time: float):
	if stunned != true:
		stunned = true
		stun_timer = time
