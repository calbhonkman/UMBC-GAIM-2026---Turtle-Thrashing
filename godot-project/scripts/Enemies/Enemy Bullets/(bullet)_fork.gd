extends Area2D

@onready var player = $"/root/Node2D/Player"

@export var MOVE_SPEED: float = 600.0
@export var LIFETIME: float = 2.0

var waiting = true
var wait_timer = 0.0
var life_timer = 0.0

var direction = null

func _ready():
	direction = (player.global_position - global_position) / (player.global_position - global_position).length()
	rotation = direction.angle() + (PI / 2)

func _process(delta):
	if wait_timer > 0.0:
		wait_timer -= delta
		direction = (player.global_position - global_position) / (player.global_position - global_position).length()
		rotation = direction.angle() + (PI / 2)
		return
	elif waiting:
		waiting = false
		life_timer = LIFETIME
	elif not waiting and life_timer <= 0.0:
		queue_free()
	
	life_timer -= delta
	
	global_position += direction * MOVE_SPEED * max(0, pow(life_timer / LIFETIME,1)) * delta
	
	if player.hitbox in get_overlapping_areas():
		player.damage(1)
		queue_free()

func play(anim):
	$AnimatedSprite2D.play(anim)

func wait(time):
	wait_timer = time
