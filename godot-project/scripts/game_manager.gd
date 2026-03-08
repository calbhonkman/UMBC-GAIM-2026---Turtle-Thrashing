extends Node2D

@onready var player = $"../Player"

@onready var camera = $Camera
@onready var clock = $Camera/Clock
@onready var level = $Camera/Level
@onready var health = $"Camera/Health Icon/Health"

@export var CAMERA_LIMIT: float = 1600.0
@export var GAME_TIME: float = 99.0 # minutes

const BERRY = preload("uid://ct5pf58tx5o1e")

@onready var enemies_group = $"../(Group) Enemies"
const ENEMY = preload("uid://d1k32mfbnnud3")
const BIGENEMY = preload("uid://dq43dbtcuu4m")
const SNAKE = preload("uid://dfuv28c2ne1eo")
@export var SPAWN_COOLDOWN = 1.0
@export var SPAWN_AREA = 1500

@onready var screen_paused = $"Camera/[Paused]"
@onready var screen_level = $"Camera/[Level Up]"
@onready var screen_lose = $"Camera/[Game Over]"
@onready var screen_win = $"Camera/[You Win]"


const UPGRADE_BUTTON = preload("uid://o1ekysyg808j")
@export var number_of_upgrades: int = 3
@export var things_to_upgrade: Array[Node2D]
var list_of_upgrades = []
var current_upgrades: Array[Vector2]
var upgrade_buttons = []

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
	health.text = str(player.health)
	
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
		select_upgrades()
	elif pausable and Input.is_action_just_pressed("pause"):
		get_tree().paused = !get_tree().paused
		screen_paused.visible = !screen_paused.visible
	
	if not get_tree().paused:
		game_timer = clampf(game_timer - delta, 0, GAME_TIME * 60.0)
		var timer_minutes = str(int(game_timer / 60.0))
		var timer_seconds = ("0" if (fmod(game_timer, 60.0) < 10) else "") + str(int(fmod(game_timer, 60.0)))
		clock.text = timer_minutes + ":" + timer_seconds
		
		if game_timer <= next_spawn_time:
			var new_enemy = null
			if randi_range(1,30) == 1:
				new_enemy = BERRY.instantiate()
			elif randi_range(1,25) == 1:
				new_enemy = SNAKE.instantiate()
			elif randi_range(1,15) == 1:
				new_enemy = BIGENEMY.instantiate()
			else:
				new_enemy = ENEMY.instantiate()
			enemies_group.add_child(new_enemy)
			new_enemy.global_position = find_spawn_position()
			if new_enemy.get_script():
				new_enemy.scale_health(1 + (GAME_TIME - (game_timer / 60.0)))
			next_spawn_time = next_spawn_time - (SPAWN_COOLDOWN / (1 + (GAME_TIME - (game_timer / 60.0))/2))

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
	things_to_upgrade[current_upgrades[index].x].upgrade(current_upgrades[index].y)
	resume()

func resume():
	screen_paused.visible = false
	screen_level.visible = false
	get_tree().paused = false
	pausable = true

func update_list_of_upgrades():
	var new_list = []
	for t in range(things_to_upgrade.size()):
		for u in range(things_to_upgrade[t].upgrade_descriptions.size()):
			new_list.append(Vector2(t,u))

func reset_upgrades():
	current_upgrades.clear()
	for button in upgrade_buttons:
		button.queue_free()
	upgrade_buttons.clear()

func select_upgrades():
	reset_upgrades()
	for i in range(number_of_upgrades):
		# Make a button for the upgrade
		upgrade_buttons.append(UPGRADE_BUTTON.instantiate())
		screen_level.add_child(upgrade_buttons.back())
		
		# Assign an upgrade to the button
		# ttu = things_to_upgrade
		var ttu_index = randi_range(0, things_to_upgrade.size()-1)
		current_upgrades.append(Vector2(ttu_index, things_to_upgrade[ttu_index].get_upgrade()))
		upgrade_buttons.back().text = things_to_upgrade[ttu_index].upgrade_descriptions[current_upgrades.back().y]
		upgrade_buttons.back().pressed.connect(_on_button_upgrade_pressed.bind(i))
	position_upgrade_buttons()

func position_upgrade_buttons():
	var screen_size_x = get_viewport_rect().size.x
	var camera_offset = camera.global_position.x - (screen_size_x / 2)
	var button_width = upgrade_buttons[0].size.x
	var pos_buffer = (screen_size_x - (number_of_upgrades * button_width)) / (number_of_upgrades + 1)
	for i in range(upgrade_buttons.size()):
		upgrade_buttons[i].global_position.x = camera_offset + (pos_buffer * (i+1)) + (button_width * i)
