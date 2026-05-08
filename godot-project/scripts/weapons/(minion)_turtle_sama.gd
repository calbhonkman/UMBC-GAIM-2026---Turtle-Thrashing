extends Node2D

@export var SPEED: float = 250.0
@export var ACTIVE_FRAMES: float = 2.0 / 60
@export var PLAYER_RANGE: float = 525.0
@export var ENEMY_RANGE: float = 30.0
@export var PUNCH_RATE: float = 0.25
@export var X_OFFSET: float = 93.0

@export var BASE_PUNCHES: int = 4 
@export var BASE_DAMAGE: float = 0.5 

@onready var sprite = $"Hitbox Area/AnimatedSprite2D"
@onready var hitbox = $"Hitbox Area/Hitbox"
@onready var hitbox_area = $"Hitbox Area"
@onready var detect_area = $"Detection Area"
@onready var detect_range = $"Detection Area/Detection Range"
@onready var target_node = $"Hitbox Area/Target Node"
@onready var player = $"/root/Node2D/Player"

var mode = "fallback"
var hitbox_timer = 0
var punch_timer = 0
var remaining_punches
var prev = []
var target = null

var damage = 0.0
var punches = 0
#var size_mod = 1.0

func _ready():
	hitbox.disabled = true
	detect_area.monitoring = true
	sprite.visible = true
	
	damage = BASE_DAMAGE
	punches = BASE_PUNCHES
	
func _process(delta: float):
	detect_area.global_position = player.global_position
	match mode:
		"default":
			var targetDirection = target_node.global_position - global_position
			if targetDirection.length() > 0:
				targetDirection = targetDirection.normalized()
			if (player.global_position - global_position).length() > PLAYER_RANGE:
				mode = "fallback"
				hitbox_area.scale.x = -1 * abs(hitbox_area.scale.x) * targetDirection.x / abs(targetDirection.x) if targetDirection.x != 0 else hitbox_area.scale.x
			if target:
				target_node.global_position = target.global_position
				global_position += targetDirection * delta * SPEED
				if (target.global_position - global_position).length() < ENEMY_RANGE:
					mode = "prepare"
					sprite.play("prepare")
					hitbox_area.scale.x = -1 * abs(hitbox_area.scale.x) * targetDirection.x / abs(targetDirection.x) if targetDirection.x != 0 else hitbox_area.scale.x
			else:
				find_target()
					
		"prepare":
			if target:
				global_position = target.global_position + Vector2(X_OFFSET * sign(hitbox_area.scale.x), 0)
			if not sprite.is_playing():
				mode = "punching"
				remaining_punches = punches
				punch_timer = 0.0
				sprite.play("attack")
		"punching":
			hitbox_timer -= delta
			punch_timer -= delta
			if target:
				global_position = target.global_position + Vector2(X_OFFSET * sign(hitbox_area.scale.x), 0)
			for area in hitbox_area.get_overlapping_areas():
				if area not in prev and area.is_in_group("Enemies"):
					if area == target:
						if target.health - damage <= 0:
							remaining_punches = 1
					prev.append(area)
					area.damage(damage)
					$"/root/Node2D/GameManager".create_damage_particle(area.global_position, damage)
			if punch_timer <= 0:
				hitbox.disabled = false
				hitbox_timer = ACTIVE_FRAMES
				punch_timer = PUNCH_RATE
				remaining_punches -= 1
				prev.clear()
				if remaining_punches < 0:
					mode = "finish"
					sprite.play("pose")
			else:
				if hitbox_timer <= 0:
					hitbox.disabled = true
		"finish":
			if not sprite.is_playing():
				if (player.global_position - global_position).length() > PLAYER_RANGE:
					mode = "fallback"
				else:
					mode = "default"
					find_target()
				sprite.play("default")
		"fallback":
			var playerDirection = player.global_position - global_position
			if playerDirection.length() > 0:
				playerDirection = playerDirection.normalized()
			global_position += playerDirection * delta * SPEED
			hitbox_area.scale.x = -1 * abs(hitbox_area.scale.x) * playerDirection.x / abs(playerDirection.x) if playerDirection.x != 0 else hitbox_area.scale.x
			if (player.global_position - global_position).length() < PLAYER_RANGE:
				mode = "default"
				find_target()
	
func find_target():
	target = null
	for area in detect_area.get_overlapping_areas():
		if area.is_in_group("Enemies"):
			if target == null:
				target = area
			elif area.health > target.health:
				target = area
	
func update_stats(dmg, pnch, sze):
	damage = dmg
	punches = pnch
	scale = Vector2.ONE * sze
				
