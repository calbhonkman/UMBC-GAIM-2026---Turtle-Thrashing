extends Area2D

@onready var player = $"/root/Node2D/Player"

@onready var sprite = $AnimatedSprite2D
const EXP = preload("uid://bln5qlwy18sjf")

@export var MAX_HEALTH: float = 1.0
@export var SPEED: float = 40.0

var health

var dying = false
var stunned = false
var stun_timer = 0.0

func _ready():
	health = MAX_HEALTH

func _process(delta):
	if player:
		if stunned:
			stun_timer -= delta
			if stun_timer <= 0:
				stunned = false
				sprite.modulate = Color(1,1,1,1)
		else: 	
			var playerDirection = player.global_position - global_position
			playerDirection = playerDirection / playerDirection.length()
			global_position += playerDirection * delta * SPEED
			sprite.scale.x = -1 * abs(sprite.scale.x) * playerDirection.x / abs(playerDirection.x) if playerDirection.x != 0 else sprite.scale.x
			sprite.play("walk")
	
	if dying:
		var new_xp = EXP.instantiate()
		get_parent().add_child(new_xp)
		new_xp.global_position = global_position
		queue_free()

func scale_health(s: float):
	health = MAX_HEALTH * s

func damage(dmg: float):
	health -= dmg
	if health <= 0.0:
		dying = true
		
func stun(time: float):
	if stunned != true:
		stunned = true
		stun_timer = time
		sprite.modulate = Color(0.788, 0.788, 0.0, 1.0)
