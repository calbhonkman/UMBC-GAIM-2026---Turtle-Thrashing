extends Area2D

@onready var player = $"/root/Node2D/Player"
@onready var sprite = $AnimatedSprite2D
const EXP = preload("uid://bln5qlwy18sjf")

@export var MAX_HEALTH: float = 1.0
var health: float = MAX_HEALTH

@export var BASE_MOVE_SPEED: float = 80.0
var move_speed: float = BASE_MOVE_SPEED

var stunned: bool = false
@export var STUN_RESIST: float = 0.0 # Percent
var stun_timer: float = 0.0 # Seconds

var dying: bool = false
@export var DYING_TIME: float = 0.5
var dying_timer: float = DYING_TIME
@export var EXP_AMOUNT: int = 1

@export var FLIP_SPEED: float = 20
var facing_direction = 1.0

func _process(delta):
	# Gets smaller as it takes damage (down to 75% size at 0 HP)
	scale = Vector2(1,1) * (0.75 + clamp(0.25 * health / MAX_HEALTH, 0.0, 0.25))
	
	# Turns red and shrinks down to 0% when HP reaches 0
	if dying and dying_timer > 0.0:
		monitorable = false
		monitoring = false
		dying_timer -= delta
		scale = Vector2(1,1) * clamp(0.75 * dying_timer / DYING_TIME, 0.0, 0.75)
		sprite.modulate = Color(1,0,0,clamp(0.5 * dying_timer / DYING_TIME, 0.0, 0.5))
	# Despawns once it has shrunk down to 0%
	elif dying and dying_timer <= 0.0:
		AudioManager.poof.play()
		for i in round(MAX_HEALTH):
			var new_xp = EXP.instantiate()
			get_parent().add_child(new_xp)
			new_xp.global_position = global_position
		queue_free()
	# If HP > 0 and stunned by an ability such as Slap..
	elif stunned:
		stun_timer -= delta
		if stun_timer <= 0:
			stunned = false
			sprite.modulate = Color(1,1,1,1)
	# If HP > 0 and not stunned...
	elif player:
		var player_dir = player.global_position - global_position
		player_dir = player_dir / player_dir.length()
		global_position += player_dir * delta * move_speed
		facing_direction = player_dir.x / abs(player_dir.x) if player_dir.x != 0.0 else facing_direction
		sprite.scale.x = move_toward(sprite.scale.x, facing_direction, delta * FLIP_SPEED)
		sprite.play("walk")

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
