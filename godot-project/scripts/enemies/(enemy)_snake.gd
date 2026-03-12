extends Area2D

@onready var player = $"/root/Node2D/Player"
@onready var sprite = $AnimatedSprite2D
const EXP = preload("uid://bln5qlwy18sjf")

@export var EXP_AMOUNT: int = 2
@export var MAX_HEALTH: float = 1.0
@export var LUNGE_SPEED: float = 300.0
@export var REG_SPEED: float = 150.0
@export var LUNGE_RANGE: float = 350.0
@export var LUNGE_COOLDOWN: float = 1.0
var lunge: bool = false

var health
var mode_timer = 0
var lungeDirection = global_position
var dying = false

func _ready():
	health = MAX_HEALTH

func _process(delta):
	if player:
		var playerDirection = player.global_position - global_position
		playerDirection = playerDirection / playerDirection.length()
		mode_timer = max(0, mode_timer - delta)
		if (player.global_position - global_position).length() < LUNGE_RANGE:
			if(lunge == true):
				global_position += lungeDirection * delta * LUNGE_SPEED
				if(mode_timer == 0):
					lunge = false
					mode_timer = LUNGE_COOLDOWN
					sprite.play("charge")
			else:
				if(mode_timer == 0):
					lunge = true
					mode_timer = LUNGE_COOLDOWN
					sprite.play("lunge")
					lungeDirection = playerDirection
		else:
			lunge = false
			global_position += playerDirection * delta * REG_SPEED
			sprite.play("default")
		scale.x = -1 * abs(scale.x) if playerDirection.x > 0 else abs(scale.x)
		
	if dying:
		for i in range(EXP_AMOUNT):
			var new_xp = EXP.instantiate()
			new_xp.global_position = global_position
			get_parent().add_child(new_xp)
		queue_free()

func scale_health(s: float):
	health = MAX_HEALTH * s

func damage(dmg: float):
	health -= dmg
	if health <= 0.0:
		dying = true
