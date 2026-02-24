extends Node2D

@onready var player = $"../Player"
const ENEMY = preload("uid://d1k32mfbnnud3")

@export var SPAWN_TIMER = 1.0
@export var SPAWN_AREA = 1500

var timer = 0

func _process(delta):
	timer += delta
	
	if player and timer >= SPAWN_TIMER:
		var new_enemy = ENEMY.instantiate()
		add_child(new_enemy)
		new_enemy.global_position = find_spawn_position()
		timer = 0

# Finds a position off-screen for an enemy to spawn
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
