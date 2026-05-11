extends Area2D

@onready var player = $"/root/Node2D/Player"
@onready var sprite = $AnimatedSprite2D
@onready var discharge_sprite = $DischargeSprite
const EXP = preload("uid://bln5qlwy18sjf")

@export var MAX_HEALTH: float = 15.0
var health: float = MAX_HEALTH

@export var BASE_MOVE_SPEED: float = 80.0
var move_speed: float = BASE_MOVE_SPEED

var dying: bool = false
@export var DYING_TIME: float = 0.5
var dying_timer: float = DYING_TIME
@export var EXP_AMOUNT: int = 0

# Other enemies might not have these variables:
@onready var hitbox1 = $CollisionShape2D
@onready var hitbox2 = $CollisionShape2D2
@onready var hitbox_discharge = $"Hitbox_(Discharge)"
var anti_knockback_position = null

@export var CHARGE_DIST: float = 300.0
@export var CHARGE_TIME: float = 1.0
@export var DISCHARGE_TIME: float = 3.0
@export var DISCHARGE_COOLDOWN: float = 5.0
var mode = "default"
var mode_timer = 0.0

const LIGHTNING = preload("uid://2rpf5ee3ixmd")
@export var STRIKE_COOLDOWN: float = 1.0
var strike_timer = 0.0

func _ready():
	discharge_sprite.visible = false
	AudioManager.eelJingle.play()

func _process(delta):
	scale = Vector2(1,1) * (0.75 + clamp(0.25 * health / MAX_HEALTH, 0.0, 0.25))
	if dying:
		monitorable = false
		monitoring = false
		dying_timer -= delta
		scale = Vector2(1,1) * clamp(0.75 * dying_timer / DYING_TIME, 0.0, 0.75)
		sprite.modulate = Color(1,0,0,clamp(0.5 * dying_timer / DYING_TIME, 0.0, 0.5))
	elif player:
		var player_vect = player.global_position - global_position
		var player_dist = player_vect.length()
		var player_dir = player_vect / player_dist
		
		if anti_knockback_position:
			global_position = anti_knockback_position
		scale.x = abs(scale.x) if player_dir.x > 0 else -1 * abs(scale.x)
		
		mode_timer -= delta
		
		match mode:
			"default":
					mode = "hunting"
			"hunting":
				if mode_timer <= 0.0 and player_dist <= CHARGE_DIST:
					mode = "charging"
					mode_timer = CHARGE_TIME
					hitbox1.disabled = true
					hitbox2.disabled = true
					sprite.play("charge")
					AudioManager.eel_chargeup.play()
				else:
					global_position += player_dir * move_speed * delta
					anti_knockback_position = global_position
					
					strike_timer -= delta
					if strike_timer <= 0.0:
						var new_strike = LIGHTNING.instantiate()
						new_strike.global_position = player.global_position + (Vector2(randf(), randf()).rotated(randf() * 2 * PI) * 200)
						get_parent().add_child(new_strike)
						strike_timer += STRIKE_COOLDOWN
			"charging":
				strike_timer = STRIKE_COOLDOWN
				if mode_timer <= 0.0:
					mode = "discharging"
					mode_timer = DISCHARGE_TIME
					hitbox_discharge.disabled = false
					discharge_sprite.visible = true
					sprite.play("default")
					AudioManager.eel_discharge.play()
					AudioManager.eel_chargeup.stop()
			"discharging":
				if mode_timer <= 0.0:
					mode = "default"
					mode_timer = DISCHARGE_COOLDOWN
					hitbox_discharge.disabled = true
					hitbox1.disabled = false
					hitbox2.disabled = false
					discharge_sprite.visible = false
					sprite.play("default")
					AudioManager.eel_discharge.stop()
				else:
					global_position += player_dir * move_speed * delta
					anti_knockback_position = global_position
			"dying":
				if not sprite.is_playing():
					queue_free()

func scale_health(s: float):
	health = MAX_HEALTH * s

func damage(dmg: float):
	if mode == "dying":
		return
	health -= dmg
	if health <= 0.0:
		mode = "dying"
		sprite.play("death")
		discharge_sprite.visible = false
		AudioManager.eeveel_death.play()
