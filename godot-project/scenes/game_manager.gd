extends Node2D

@onready var player = $"../Player"
@onready var camera = $"../Camera"

@onready var clock = $"../Camera/Clock"
@onready var level = $"../Camera/Level"
@onready var health = $"../Camera/Health"

@export var CAMERA_LIMIT: float = 1600.0
@export var GAME_TIME: float = 5.0 # minutes


@onready var enemies_group = $"../(Group) Enemies"
const ENEMY = preload("uid://d1k32mfbnnud3")
@export var SPAWN_COOLDOWN = 1.0
@export var SPAWN_AREA = 1500

var game_timer = 0.0
var next_spawn_time = 0.0

func _ready():
	game_timer = GAME_TIME * 60 # seconds
	next_spawn_time = game_timer

func _process(delta):
	var cam_limit_x = CAMERA_LIMIT - (get_viewport().get_visible_rect().size.x/2)
	var cam_limit_y = CAMERA_LIMIT - (get_viewport().get_visible_rect().size.y/2)
	camera.global_position.x = clampf(player.global_position.x, -1*cam_limit_x, cam_limit_x)
	camera.global_position.y = clampf(player.global_position.y, -1*cam_limit_y, cam_limit_y)
	
	level.text = "Level " + str(player.level) + " (" + str(player.experience) + "/" + str(5 * (player.level * (player.level+1) / 2)) + ")"
	health.text = str(player.health) + " HP"
	
	if game_timer <= 0.0:
		get_tree().paused = true
	
	if not get_tree().paused:
		game_timer = clampf(game_timer - delta, 0, GAME_TIME * 60.0)
		var timer_minutes = str(int(game_timer / 60.0))
		var timer_seconds = ("0" if (fmod(game_timer, 60.0) < 10) else "") + str(int(fmod(game_timer, 60.0)))
		clock.text = timer_minutes + ":" + timer_seconds
		
		if game_timer <= next_spawn_time:
			print("hi")
			var new_enemy = ENEMY.instantiate()
			enemies_group.add_child(new_enemy)
			new_enemy.global_position = find_spawn_position()
			new_enemy.scale_health(game_timer / 60.0)
			next_spawn_time = ceil(game_timer) - SPAWN_COOLDOWN
	
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = !get_tree().paused

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
