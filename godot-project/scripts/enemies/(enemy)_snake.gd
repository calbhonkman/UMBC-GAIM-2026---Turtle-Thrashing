extends Area2D

@onready var player = $"/root/Node2D/Player"
@onready var sprite = $AnimatedSprite2D
const EXP = preload("uid://bln5qlwy18sjf")

@export var MAX_HEALTH: float = 1.0
var health: float = MAX_HEALTH

@export var BASE_MOVE_SPEED: float = 150.0
var move_speed: float = BASE_MOVE_SPEED

var stunned: bool = false
@export var STUN_RESIST: float = 0.0 # Percent
var stun_timer: float = 0.0 # Seconds

var dying: bool = false
@export var DYING_TIME: float = 0.5
var dying_timer: float = DYING_TIME
@export var EXP_AMOUNT: int = 2

# These variables are exclusive to the Snake:
var lunge: bool = false
@export var LUNGE_RANGE: float = 350.0
@export var LUNGE_SPEED: float = 300.0
@export var LUNGE_COOLDOWN: float = 1.0 # Seconds
var mode_timer: float = 0.0 # Seconds
var lunge_direction = Vector2.ZERO

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
		if stunned:
			stun_timer -= delta
			if stun_timer <= 0:
				stunned = false
				sprite.modulate = Color(1,1,1,1)
		else:
			var playerDirection = player.global_position - global_position
			playerDirection = playerDirection / playerDirection.length()
			mode_timer = max(0, mode_timer - delta)
			if (player.global_position - global_position).length() < LUNGE_RANGE:
				if (lunge == true):
					global_position += lunge_direction * delta * LUNGE_SPEED
					if (mode_timer == 0):
						lunge = false
						mode_timer = LUNGE_COOLDOWN
						sprite.play("charge")
				else:
					if (mode_timer == 0):
						lunge = true
						mode_timer = LUNGE_COOLDOWN
						sprite.play("lunge")
						lunge_direction = playerDirection
			else:
				lunge = false
				global_position += playerDirection * delta * move_speed
				sprite.play("default")
			scale.x = -1 * abs(scale.x) if playerDirection.x > 0 else abs(scale.x)

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
