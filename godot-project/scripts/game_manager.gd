extends Node2D

@onready var player = $"../Player"

@onready var camera = $Camera
@onready var clock = $Camera/Clock
@onready var level = $Camera/Level
@onready var health = $"Camera/Health Icon/Health"

@export var CAMERA_LIMIT: float = 1600.0
@export var GAME_TIME: float = 5.0 # minutes
@export var ENDLESS_MODE: bool = false

@export var FOOD: Array[Resource]

@onready var enemies_group = $"../(Group) Enemies"
const ENEMY = preload("uid://d1k32mfbnnud3")
const BIGENEMY = preload("uid://dq43dbtcuu4m")
const SNAKE = preload("uid://dfuv28c2ne1eo")
@export var ENEMIES: Array[Resource]
@export var SPAWN_COOLDOWN = 1.0
@export var SPAWN_AREA = 1500

@onready var screen_paused = $"Camera/[Paused]"
@onready var screen_level = $"Camera/[Level Up]"
@onready var screen_lose = $"Camera/[Game Over]"
@onready var screen_win = $"Camera/[You Win]"


const UPGRADE_BUTTON = preload("uid://o1ekysyg808j")
@export var number_of_upgrades: int = 3
@export var things_to_upgrade: Array[Node2D]
var current_upgrades: Array[Vector2]
var upgrade_buttons = []

var game_timer = 0.0
var next_spawn_time = 0.0

var boss = null
var boss_fight = false
var boss_defeated = false
var pausable = true

func _ready():
	game_timer = 0.0
	next_spawn_time = game_timer + 1.0

func _process(delta):
	global_position = player.global_position
	
	var cam_limit_x = CAMERA_LIMIT - (get_viewport().get_visible_rect().size.x/2)
	var cam_limit_y = CAMERA_LIMIT - (get_viewport().get_visible_rect().size.y/2)
	camera.global_position.x = clampf(player.global_position.x, -1*cam_limit_x, cam_limit_x)
	camera.global_position.y = clampf(player.global_position.y, -1*cam_limit_y, cam_limit_y)
	
	level.text = "Level " + str(player.level) + " (" + str(player.experience) + "/" + str(5 * (player.level * (player.level+1) / 2)) + ")"
	health.text = str(player.health)
	
	
	if pausable and Input.is_action_just_pressed("pause"):
		get_tree().paused = !get_tree().paused
		screen_paused.visible = !screen_paused.visible
	elif player.health <= 0:
		pausable = false
		get_tree().paused = true
		screen_lose.visible = true
	elif not get_tree().paused and player.experience >= 5 * (player.level * (player.level+1) / 2):
		player.level += 1
		pausable = false
		get_tree().paused = true
		screen_level.visible = true
		select_upgrades()
	elif boss_fight:
		if boss == null:
			pausable = false
			get_tree().paused = true
			screen_win.visible = true
	elif game_timer >= GAME_TIME * 60.0 and not ENDLESS_MODE:
		# Unleash the Raccoon
		clear_enemies()
		boss = spawn_enemy(ENEMIES[3])
		boss_fight = true
	
	if not get_tree().paused:
		game_timer += delta
		var clock_time = game_timer if ENDLESS_MODE else clampf(GAME_TIME * 60.0 - game_timer, 0.0, GAME_TIME * 60.0)
		var timer_minutes = str(int(clock_time / 60.0))
		var timer_seconds = ("0" if (fmod(clock_time, 60.0) < 10) else "") + str(int(fmod(clock_time, 60.0)))
		clock.text = timer_minutes + ":" + timer_seconds
		
		if game_timer >= next_spawn_time:
			if boss_fight:
				# Small Raccoon
				spawn_enemy(ENEMIES[4])
				spawn_enemy(ENEMIES[4])
				spawn_enemy(ENEMIES[4])
			elif int(next_spawn_time) % 30 == 0:
				# Turtle
				spawn_enemy(ENEMIES[2])
				spawn_enemy(ENEMIES[2])
			elif int(next_spawn_time) % 10 == 0:
				# Snake
				spawn_enemy(ENEMIES[1])
			else:
				# Crab
				spawn_enemy(ENEMIES[0])
				spawn_enemy(ENEMIES[0])
			next_spawn_time += 1.0 # seconds

func clear_enemies():
	for child in enemies_group.get_children():
		if child.is_in_group("Enemies"):
			child.damage(INF)

func spawn_enemy(enemy: Resource):
	var new_enemy = enemy.instantiate()
	enemies_group.add_child(new_enemy)
	new_enemy.global_position = find_spawn_position()
	if new_enemy.get_script():
		new_enemy.scale_health(1 + (game_timer / 60.0))
	return new_enemy

func find_spawn_position():
	# Screen size
	var s_size = get_viewport().get_visible_rect().size
	# Player size
	var p_pos = player.global_position
	
	var possible_directions = []
	
	# Check which directions have space for enemies
	if (p_pos.y-(s_size.y/2) > -1 * SPAWN_AREA):
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

func _on_button_continue_pressed():
	resume()

func _on_button_upgrade_pressed(index):
	things_to_upgrade[int(current_upgrades[index].x)].upgrade(int(current_upgrades[index].y))
	resume()

func resume():
	screen_paused.visible = false
	screen_level.visible = false
	get_tree().paused = false
	pausable = true

func reset_upgrades():
	current_upgrades.clear()
	for button in upgrade_buttons:
		button.queue_free()
	upgrade_buttons.clear()

func select_upgrades():
	reset_upgrades()
	
	# ttu = things_to_upgrade
	var ttu = things_to_upgrade.duplicate()
	for i in range(min(number_of_upgrades, ttu.size())):
		# Make a button for the upgrade
		upgrade_buttons.append(UPGRADE_BUTTON.instantiate())
		screen_level.add_child(upgrade_buttons.back())
		
		# Assign an upgrade to the button
		var ttu_index = randi_range(0, ttu.size()-1)
		current_upgrades.append(Vector2(things_to_upgrade.find(ttu[ttu_index]), ttu[ttu_index].get_upgrade()))
		upgrade_buttons.back().get_child(0).text = ttu[ttu_index].upgrade_descriptions[current_upgrades.back().y]
		upgrade_buttons.back().pressed.connect(_on_button_upgrade_pressed.bind(i))
		ttu.remove_at(ttu_index)
	position_upgrade_buttons()

func position_upgrade_buttons():
	var screen_size_x = get_viewport_rect().size.x
	var camera_offset = camera.global_position.x - (screen_size_x / 2)
	var button_width = upgrade_buttons[0].size.x * upgrade_buttons[0].scale.x
	var pos_buffer = (screen_size_x - (number_of_upgrades * button_width)) / (number_of_upgrades + 1)
	for i in range(upgrade_buttons.size()):
		upgrade_buttons[i].global_position.x = camera_offset + (pos_buffer * (i+1)) + (button_width * i)
