extends Area2D

@onready var player = $"/root/Node2D/Player"
@onready var sprite = $AnimatedSprite2D
const EXP = preload("uid://bln5qlwy18sjf")

@export var MAX_HEALTH: float = 15.0
var health: float = MAX_HEALTH

@export var BASE_MOVE_SPEED: float = 180.0
var move_speed: float = BASE_MOVE_SPEED

var dying: bool = false
@export var DYING_TIME: float = 0.5
var dying_timer: float = DYING_TIME
@export var EXP_AMOUNT: int = 1

# Other enemies may not have these variables:
@export var ATTACK_RANGE: float = 400.0
@export var ATTACK_COOLDOWN: float = 4.0
@export var PREPARE_TIME: float = 2.0
@export var ATTACK_TIME: float = 1.0
@export var DEATH_SPRITE_TIME: float = 1.0
@export var ATTACK_AMOUNT: int = 3
@export var BULLETS: Array[Resource]
@export var RACCOON: Resource
@export var BULLET_SPEED: float = 500.0
@export var BASE_BULLET_LIFETIME: float = 1.0
@export var DEATH_POS_X: float = -28.0
@export var DEATH_POS_Y: float = -65.0
var bullet_lifetime = BASE_BULLET_LIFETIME
@export var knockback_immunity = true
var mode = "default"
var mode_timer = 0
var next_bullet = null
var bullets = []
var b_direction = []
var b_position = []
var b_lifetime = []
var b_amount = 0

func _ready():
	AudioManager.raccoonKingJingle.play()

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
		
		scale.x = -1 * abs(scale.x) if player_dir.x > 0 else abs(scale.x)
		
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
					if randf() > 0.5:
						mode = "charging_bowl"
						next_bullet = BULLETS[0]
						bullet_lifetime = BASE_BULLET_LIFETIME * 3.0
						sprite.play("charge_bowl")
					else:
						mode = "charging_rac"
						next_bullet = BULLETS[1]
						bullet_lifetime = BASE_BULLET_LIFETIME
						sprite.play("charge_rac")
			"charging_bowl":
				if mode_timer <= 0.0:
					mode = "attacking"
					mode_timer = ATTACK_TIME
					b_amount = 0
					sprite.play("attack_bowl")
			"charging_rac":
				if mode_timer <= 0.0:
					mode = "attacking"
					mode_timer = ATTACK_TIME
					b_amount = 0
					sprite.play("attack_rac")
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
					AudioManager.king_throw.play()
			"dying":
				if mode_timer <= 0.0:
					sprite.play("death2")
					mode = "dead"
					mode_timer = DEATH_SPRITE_TIME
					# Trying to center the borrowed poof sprite
					position.x = DEATH_POS_X
					position.y = DEATH_POS_Y
			"dead":
				if not sprite.is_playing():
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
							if bullets[i].get_meta("bullet_type") and bullets[i].get_meta("bullet_type") == "Bowling" and area != self and area.is_in_group("Enemies"):
								area.damage(INF)
								b_direction[i] = (player.global_position - b_position[i]) / (player.global_position - b_position[i]).length()

func scale_health(s: float):
	health = MAX_HEALTH * s

func damage(dmg: float):
	if mode == "dying" or mode == "dead":
		return
	health -= dmg
	if health <= 0.0:
		sprite.play("death1")
		mode = "dying"
		mode_timer = DEATH_SPRITE_TIME
		AudioManager.raccoon_surrender.play()
