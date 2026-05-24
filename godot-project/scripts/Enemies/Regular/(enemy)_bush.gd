extends Area2D

@onready var player = $"/root/Node2D/Player"
@onready var sprite = $AnimatedSprite2D
@onready var area_suck = $"(hitbox)_suck"
@onready var hitbox_suck = $"(hitbox)_suck/CollisionShape2D"
@onready var air_sprite = $"Air Sprite"
const EXP = preload("uid://bln5qlwy18sjf")

@export var MAX_HEALTH: float = 3.0
var health: float = MAX_HEALTH

@export var BASE_MOVE_SPEED: float = 20.0
var move_speed: float = BASE_MOVE_SPEED

var stunned: bool = false
@export var STUN_RESIST: float = 0.0 # Percent
var stun_timer: float = 0.0 # Seconds

var dying: bool = false
@export var DYING_TIME: float = 0.5
var dying_timer: float = DYING_TIME
@export var EXP_AMOUNT: int = 1

# Other enemies may not have these variables:
@export var SUCK_STRENGTH: float = 150.0
@export var SUCK_RANGE: float = 150.0
@export var HOSTILE_RANGE: float = 400.0
@export var HOSTILE_SPEED: float = 150.0
var mode = "default"

func _ready():
	hitbox_suck.disabled = true
	air_sprite.visible = false
	air_sprite.play("default")

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
			var playerDirection = player.global_position - global_position
			playerDirection = playerDirection / playerDirection.length()
			sprite.scale.x = abs(sprite.scale.x) * sign(playerDirection.x)
			air_sprite.scale.x = abs(air_sprite.scale.x) * sign(sprite.scale.x)
			hitbox_suck.position.x = abs(hitbox_suck.position.x) * sign(playerDirection.x)
			air_sprite.position.x = abs(air_sprite.position.x) * sign(playerDirection.x)
			match mode:
				"default":
					global_position += playerDirection * delta * move_speed
					sprite.play("default")
					if (player.global_position - global_position).length() <= HOSTILE_RANGE:
						mode = "unleash hostile"
						AudioManager.roar.play()
						sprite.play("unleash")
					elif abs(player.global_position.y - global_position.y) <= SUCK_RANGE:
						mode = "unleash suck"
						AudioManager.suck.play()
						sprite.play("unleash")
				"unleash hostile":
					await sprite.animation_finished
					_go_to_hostile()
				"unleash suck":
					air_sprite.visible = true
					await sprite.animation_finished
					_go_to_suck()
				"hostile":
					global_position += playerDirection * delta * HOSTILE_SPEED
					if (player.global_position - global_position).length() > HOSTILE_RANGE:
						hitbox_suck.disabled = true
						mode = "retract"
						sprite.play("retract")
				"suck":
					hitbox_suck.disabled = false
					for area in area_suck.get_overlapping_areas():
						if area == player.hitbox:
							var knockback_dir = (global_position - player.global_position).normalized()
							player.global_position += knockback_dir * SUCK_STRENGTH * delta
					if (player.global_position - global_position).length() < HOSTILE_RANGE:
						mode = "hostile"
						AudioManager.suck.stop()
						AudioManager.roar.play()
						air_sprite.visible = false
						sprite.play("attack")
					elif abs(player.global_position.y - global_position.y) > SUCK_RANGE:
						hitbox_suck.disabled = true
						mode = "retract"
						sprite.play("retract")
				"retract":
					AudioManager.suck.stop()
					air_sprite.visible = false
					await sprite.animation_finished
					_go_to_default()
				
					
func _go_to_hostile():
	mode = "hostile"
	sprite.play("attack")
	
func _go_to_suck():
	mode = "suck"
	sprite.play("suck")
	
func _go_to_default():
	mode = "default"

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
