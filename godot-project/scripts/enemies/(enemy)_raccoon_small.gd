extends Area2D

@onready var player = $"/root/Node2D/Player"
const EXP = preload("uid://bln5qlwy18sjf")

@export var MAX_HEALTH: float = 1.0
@export var BASE_SPEED: float = 25.0
@export var EXP_AMOUNT: int = 1

var health

var dying = false

func _ready():
	health = MAX_HEALTH

func _process(delta):
	var player_vect = player.global_position - global_position
	var player_dir = player_vect / player_vect.length()
	global_position += player_dir * BASE_SPEED * delta
	
	if dying:
		for i in range(EXP_AMOUNT):
			var new_xp = EXP.instantiate()
			new_xp.global_position = global_position
			get_parent().add_child(new_xp)
		queue_free()

func scale_health(s: float):
	# This "enemy" is meant to die quickly
	pass

func damage(dmg: float):
	health -= dmg
	if health <= 0.0:
		dying = true
