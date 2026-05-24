extends Area2D

@onready var player = $"/root/Node2D/Player"
@onready var sprite_p1 = $"Sprite (Phase 1)"
@onready var sprite_p2 = $"Sprite (Phase 2)"
@onready var knife_hitbox_p1 = $"Knife Hitbox (Phase 1)"
@onready var knife_hitbox_p2 = $"Knife Hitbox (Phase 2)"
const EXP = preload("uid://bln5qlwy18sjf")

@export var MAX_HEALTH: float = 15.0
var health: float = MAX_HEALTH

@export var BASE_MOVE_SPEED: float = 250.0
var move_speed: float = BASE_MOVE_SPEED

@export var FLIP_SPEED: float = 20.0
var facing_direction = 1.0

# Other enemies might not have these variables:
@export var FORK: Resource
@export var BEAM: Resource
@export var BAGUETTE: Resource
@export var BASE_DAMAGE: float = 1.0
@export var COOLDOWN: float = 1.0
@export var PULL_TIME: float = 5.0
@export var PULL_STRENGTH: float = 400.0
@export var knockback_immunity = true
var sprite = null
var knife_hitbox = null
var mode = "default"
var next_mode = "knife1"
var mode_timer = 0
var beam_cooldown = false
var bullets = []
var health_scale = 0

func _ready():
	sprite = sprite_p1
	knife_hitbox = knife_hitbox_p1
	AudioManager.hillbilly_voice_intro.play()

func _process(delta):
	scale = Vector2(1,1) * (0.75 + clamp(0.25 * health / MAX_HEALTH, 0.0, 0.25))
	
	if player:
		var player_vect = player.global_position - global_position
		var player_dist = player_vect.length()
		var player_dir = player_vect / player_dist
		
		facing_direction = -1 * player_dir.x / abs(player_dir.x) if player_dir.x != 0.0 else facing_direction
		sprite.scale.x = move_toward(sprite.scale.x, facing_direction, delta * FLIP_SPEED)
		knife_hitbox.scale.x = move_toward(knife_hitbox.scale.x, facing_direction, delta * FLIP_SPEED)
		$"Beam Pivot".scale.x = move_toward($"Beam Pivot".scale.x, facing_direction, delta * FLIP_SPEED)
		$"Fork Pivot".scale.x = move_toward($"Fork Pivot".scale.x, facing_direction, delta * FLIP_SPEED)
		
		mode_timer -= delta
		
		match mode:
			"default":
				# Basically cooldown mode
				if sprite == sprite_p1 and health <= 0.5 * MAX_HEALTH * health_scale:
					mode = "transition"
					PULL_STRENGTH *= 1.5
					sprite.play("transition")
					AudioManager.hillbilly_voice_half.play()
					AudioManager.hillbilly_voice_intro.stop()
				elif mode_timer <= 0.0:
					mode = "hunting"
					sprite.play("walk")
			"transition":
				if not sprite.is_playing():
					sprite.visible = false
					sprite = sprite_p2
					knife_hitbox = knife_hitbox_p2
					sprite.visible = true
					mode = "default"
					sprite.play("default")
			"hunting":
				var knife_hitbox = knife_hitbox_p1 if sprite == sprite_p1 else knife_hitbox_p2
				if next_mode == "knife1":
					if player.hitbox in knife_hitbox.get_overlapping_areas():
						mode = "knife1"
						sprite.play("knife1")
					else:
						global_position += player_dir * move_speed * delta
				else:
					mode = next_mode
					#mode_timer = ATTACK_TIME
					sprite.play(next_mode)
			"knife1":
				if not sprite.is_playing():
					mode = "knife2"
					if player.hitbox in knife_hitbox.get_overlapping_areas():
						player.damage(1)
					sprite.play("knife2")
			"knife2":
				if not sprite.is_playing():
					mode = "default"
					mode_timer = COOLDOWN if sprite == sprite_p1 else COOLDOWN / 2
					next_mode = "fork1"
					sprite.play("default")
			"fork1":
				if not sprite.is_playing():
					bullets.clear()
					var amount = 1 if sprite == sprite_p1 else 3
					var anim = "fork_p1" if sprite == sprite_p1 else "fork_p2"
					
					for i in range(amount):
						bullets.append(FORK.instantiate())
						bullets.back().global_position = $"Fork Pivot/Fork Position".global_position
						bullets.back().play(anim)
						bullets.back().wait((i+3) * 0.25)
						$"/root/Node2D/(Group) Bullets".add_child(bullets.back())
					
					mode = "fork2"
					sprite.play("fork2")
			"fork2":
				if not sprite.is_playing():
					mode = "default"
					mode_timer = COOLDOWN if sprite == sprite_p1 else COOLDOWN / 2
					next_mode = "beam1"
					sprite.play("default")
			"beam1":
				if not sprite.is_playing():
					mode = "beam2"
					mode_timer = PULL_TIME
					sprite.play("beam2")
					if sprite == sprite_p1:
						$"Beam Pivot/Area2D".play("beam_p1")
						AudioManager.hillbilly_suck_p1.play()
					else:
						$"Beam Pivot/Area2D".play("beam_p2")
						AudioManager.hillbilly_suck_p2.play()
					$"Beam Pivot".visible = true
			"beam2":
				if mode_timer <= 0.0:
					mode = "beam3"
					$"Beam Pivot".modulate.a = 0.0
					sprite.play("beam3")
				else:
					$"Beam Pivot".modulate.a = (pow((PULL_TIME - mode_timer) / PULL_TIME, 2) * 0.50) + 0.25
					var pull_str = PULL_STRENGTH * ((pow((mode_timer) / PULL_TIME, 2) * 0.75) + 0.25) * delta
					player.global_position.y += pull_str if player.global_position.y < $"Beam Pivot/Area2D".global_position.y else -1 * pull_str
			"beam3":
				if not sprite.is_playing():
					mode = "beam4"
					sprite.play("beam4")
					$"Beam Pivot".modulate.a = 1.0
					beam_cooldown = false
					if sprite == sprite_p1:
						AudioManager.hillbilly_laser_p1.play()
					else:
						AudioManager.hillbilly_laser_p2.play()
			"beam4":
				if not sprite.is_playing():
					mode = "beam5"
					sprite.play("beam5")
					$"Beam Pivot".visible = false
				elif not beam_cooldown and player.hitbox in $"Beam Pivot/Area2D".get_overlapping_areas():
					beam_cooldown = true
					player.damage(1.0)
			"beam5":
				if not sprite.is_playing():
					mode = "default"
					mode_timer = COOLDOWN if sprite == sprite_p1 else COOLDOWN / 2
					next_mode = "baguette1"
					sprite.play("default")
			"baguette1":
				if not sprite.is_playing():
					mode = "baguette2"
					bullets.clear()
					var amount = 5 if sprite == sprite_p1 else 10
					var anim = "baguette_p1" if sprite == sprite_p1 else "baguette_p2"
					for i in range(amount):
						bullets.append(BAGUETTE.instantiate())
						bullets.back().play(anim)
						$"/root/Node2D/(Group) Bullets".add_child(bullets.back())
						
					sprite.play("baguette2")
			"baguette2":
				if not sprite.is_playing():
					mode = "default"
					mode_timer = COOLDOWN if sprite == sprite_p1 else COOLDOWN / 2
					next_mode = "knife1"
					sprite.play("default")
			"dying":
				if not sprite.is_playing():
					queue_free()

func scale_health(s: float):
	health = MAX_HEALTH * s
	health_scale = s

func damage(dmg: float):
	if mode == "dying":
		return
	health -= dmg
	if health <= 0.0:
		mode = "dying"
		sprite.play("death")
		AudioManager.hillbilly_voice_death.play()
		AudioManager.hillbilly_voice_half.stop()
