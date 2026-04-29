extends Area2D

@onready var player = $"/root/Node2D/Player"
@onready var sprite = $AnimatedSprite2D
const EXP = preload("uid://bln5qlwy18sjf")

@export var MAX_HEALTH: float = 1.0
var health: float = MAX_HEALTH

@export var BASE_MOVE_SPEED: float = 120.0
var move_speed: float = BASE_MOVE_SPEED

var stunned: bool = false
@export var STUN_RESIST: float = 0.0 # Percent
var stun_timer: float = 0.0 # Seconds

var dying: bool = false
@export var DYING_TIME: float = 0.5
var dying_timer: float = DYING_TIME
@export var EXP_AMOUNT: int = 1

# Other enemies may not have these variables:
@export var RUNAWAY_RANGE: float = 350.0
@export var ATTACK_RANGE: float = 700.0
@export var ATTACK_COOLDOWN: float = 4.0
@export var PREPARE_TIME: float = 1.0
@export var ATTACK_TIME: float = 2.0
@export var ATTACK_AMOUNT: int = 1
@export var BULLETS: Array[Resource]
@export var BULLET_SPEED: float = 500.0
@export var BASE_BULLET_LIFETIME: float = 1.0
var bullet_lifetime = BASE_BULLET_LIFETIME
var mode = "default"
var mode_timer = 0
var next_bullet = null
var bullets = []
var b_direction = []
var b_position = []
var b_lifetime = []
var b_amount = 0

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
			var player_vect = player.global_position - global_position
			var player_dist = player_vect.length()
			var player_dir = player_vect / player_dist
			var playerDirection = player.global_position - global_position
			playerDirection = playerDirection / playerDirection.length()
			sprite.scale.x = -1 * abs(sprite.scale.x) * playerDirection.x / abs(playerDirection.x) if playerDirection.x != 0 else sprite.scale.x
			mode_timer -= delta
			
			match mode:
				"default":
					if mode_timer <= 0.0:
						mode = "hunting"
				"hunting":
					if player_dist > ATTACK_RANGE:
						global_position += player_dir * move_speed * delta
						sprite.play("walk")
					elif player_dist <= ATTACK_RANGE:
						mode_timer = PREPARE_TIME
						mode = "charging"
						next_bullet = BULLETS[0]
						bullet_lifetime = BASE_BULLET_LIFETIME * 3.0
						sprite.play("prep")
					elif player_dist <= RUNAWAY_RANGE:
						mode = "runaway"
				"runaway":
					sprite.scale.x = sprite.scale.x if playerDirection.x != 0 else -1 * abs(sprite.scale.x) * playerDirection.x / abs(playerDirection.x)
					if player_dist < RUNAWAY_RANGE:
						global_position -= player_dir * move_speed * delta
						sprite.play("walk")
					else:
						mode_timer = PREPARE_TIME
						mode = "charging"
						next_bullet = BULLETS[0]
						bullet_lifetime = BASE_BULLET_LIFETIME * 3.0
						sprite.play("prep")
				"charging":
					if mode_timer <= 0.0:
						mode = "attacking"
						mode_timer = ATTACK_TIME
						b_amount = 0
						sprite.play("throw")
				"attacking":
					if mode_timer <= 0.0:
						mode = "default"
						mode_timer = ATTACK_COOLDOWN
						sprite.play("default")
					elif mode_timer <= (ATTACK_AMOUNT - b_amount) * (ATTACK_TIME / ATTACK_AMOUNT):
						bullets.append(next_bullet.instantiate())
						add_child(bullets.back())
						b_direction.append(player_dir)
						b_position.append(global_position)
						b_lifetime.append(bullet_lifetime)
						b_amount += 1

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
