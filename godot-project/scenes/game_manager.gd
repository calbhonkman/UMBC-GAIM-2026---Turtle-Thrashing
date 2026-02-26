extends Node2D

@onready var player = $"../Player"
@onready var pickup_area = $"../Player/Pickup Area"
@onready var weapon_punch = $"../Player/(Weapon) Punch"
@onready var weapon_lightning = $"../Player/(Weapon) Lightning"

@onready var camera = $Camera
@onready var clock = $Camera/Clock
@onready var level = $Camera/Level
@onready var health = $Camera/Health

@export var CAMERA_LIMIT: float = 1600.0
@export var GAME_TIME: float = 5.0 # minutes

@onready var enemies_group = $"../(Group) Enemies"
const ENEMY = preload("uid://d1k32mfbnnud3")
@export var SPAWN_COOLDOWN = 1.0
@export var SPAWN_AREA = 1500

@onready var screen_paused = $"Camera/[Paused]"
@onready var screen_level = $"Camera/[Level Up]"
@onready var screen_lose = $"Camera/[Game Over]"
@onready var screen_win = $"Camera/[You Win]"

var game_timer = 0.0
var next_spawn_time = 0.0

var pausable = true

func _ready():
	game_timer = GAME_TIME * 60 # seconds
	next_spawn_time = game_timer

func _process(delta):
	global_position = player.global_position
	
	var cam_limit_x = CAMERA_LIMIT - (get_viewport().get_visible_rect().size.x/2)
	var cam_limit_y = CAMERA_LIMIT - (get_viewport().get_visible_rect().size.y/2)
	camera.global_position.x = clampf(player.global_position.x, -1*cam_limit_x, cam_limit_x)
	camera.global_position.y = clampf(player.global_position.y, -1*cam_limit_y, cam_limit_y)
	
	level.text = "Level " + str(player.level) + " (" + str(player.experience) + "/" + str(5 * (player.level * (player.level+1) / 2)) + ")"
	health.text = str(player.health) + " HP"
	
	if game_timer <= 0.0:
		pausable = false
		get_tree().paused = true
		screen_win.visible = true
	elif player.health <= 0:
		pausable = false
		get_tree().paused = true
		screen_lose.visible = true
	elif player.experience >= 5 * (player.level * (player.level+1) / 2):
		player.level += 1
		pausable = false
		get_tree().paused = true
		screen_level.visible = true
	elif pausable and Input.is_action_just_pressed("pause"):
		get_tree().paused = !get_tree().paused
		screen_paused.visible = !screen_paused.visible
	
	if not get_tree().paused:
		game_timer = clampf(game_timer - delta, 0, GAME_TIME * 60.0)
		var timer_minutes = str(int(game_timer / 60.0))
		var timer_seconds = ("0" if (fmod(game_timer, 60.0) < 10) else "") + str(int(fmod(game_timer, 60.0)))
		clock.text = timer_minutes + ":" + timer_seconds
		
		if game_timer <= next_spawn_time:
			var new_enemy = ENEMY.instantiate()
			enemies_group.add_child(new_enemy)
			new_enemy.global_position = find_spawn_position()
			new_enemy.scale_health(1 + (GAME_TIME - (game_timer / 60.0)))
			next_spawn_time = next_spawn_time - (SPAWN_COOLDOWN / (1 + (GAME_TIME - (game_timer / 60.0))))

func find_spawn_position():
	# Screen size
	var s_size = get_viewport().get_visible_rect().size
	# Player size
	var p_pos = player.global_position
	
	var possible_directions = []
	
	# Check which directions have space for enemies
	if (p_pos.y-(s_size.y/2) > -1*SPAWN_AREA):
		possible_directions.append('North')
	if (p_pos.x+(s_size.x/2) < SPAWN_AREA):
		possible_directions.append('East')
	if (p_pos.y+(s_size.y/2) < SPAWN_AREA):
		possible_directions.append('South')
	if (p_pos.x-(s_size.x/2) > -1*SPAWN_AREA):
		possible_directions.append('West')
	
	# Can't spawn anywhere
	if possible_directions.is_empty():
		print("ERROR: SPAWN_AREA is too small")
		return player.global_position
	
	match possible_directions[randi_range(0,possible_directions.size()-1)]:
		'North':
			return Vector2(randf_range(-1*SPAWN_AREA,SPAWN_AREA),p_pos.y-(s_size.y/2))
		'East':
			return Vector2(p_pos.x+(s_size.x/2),randf_range(-1*SPAWN_AREA,SPAWN_AREA))
		'South':
			return Vector2(randf_range(-1*SPAWN_AREA,SPAWN_AREA),p_pos.y+(s_size.y/2))
		'West':
			return Vector2(p_pos.x-(s_size.x/2),randf_range(-1*SPAWN_AREA,SPAWN_AREA))
		_:
			return player.global_position

func _on_button_main_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/mainmenu.tscn")

func resume():
	screen_paused.visible = false
	screen_level.visible = false
	get_tree().paused = false
	pausable = true

func _on_button_continue_pressed():
	resume()

func _on_upgrade_player_health_pressed():
	player.health = player.MAX_HEALTH
	resume()
func _on_upgrade_player_speed_pressed():
	player.speed *= 1.25
	resume()
func _on_upgrade_player_range_pressed():
	pickup_area.get_child(0).shape.radius *= 1.25
	resume()
func _on_upgrade_punch_amount_pressed():
	weapon_punch.increase_amnt()
	resume()
func _on_upgrade_punch_damage_pressed():
	weapon_punch.dmg += 2
	resume()
func _on_upgrade_punch_cooldown_pressed():
	weapon_punch.cldwn *= 0.75
	weapon_punch.DELAY *= 0.75
	resume()
func _on_upgrade_cloud_amount_pressed():
	weapon_lightning.increase_amnt()
	resume()
func _on_upgrade_cloud_damage_pressed():
	weapon_lightning.dmg += 1
	resume()
func _on_upgrade_cloud_size_pressed():
	weapon_lightning.size_mod *= 1.25
	resume()
