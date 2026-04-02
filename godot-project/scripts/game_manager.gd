extends Node2D

@onready var player = $"../Player"

@onready var camera = $Camera
@onready var clock = $Camera/Clock
@onready var level = $Camera/Level
@onready var health = $"Camera/Health Icon/Health"

const DAMAGE_PARTICLE = preload("uid://dum7dfhvymdrp")

@export var CAMERA_LIMIT: float = 1600.0
@export var GAME_TIME: float = 5.0 # minutes
@export var ENDLESS_MODE: bool = false

@export var FOOD: Array[Resource]

@onready var enemies_group = $"../(Group) Enemies"
const ENEMY = preload("uid://d1k32mfbnnud3")
const BIGENEMY = preload("uid://dq43dbtcuu4m")
const SNAKE = preload("uid://dfuv28c2ne1eo")
@export var ENEMIES: Array[Resource]
@export var ELITES: Array[Resource]
@export var SPAWN_COOLDOWN = 1.0
@export var SPAWN_AREA = 800

@onready var screen_paused = $"Camera/[Paused]"
@onready var screen_level = $"Camera/[Level Up]"
@onready var screen_lose = $"Camera/[Game Over]"
@onready var screen_win = $"Camera/[You Win]"

var game_timer = 0.0
var next_spawn_time = 0.0

var remaining_elites = []
var bosses = []
var boss_fight = false
var pausable = true

func _ready():
	game_timer = 0.0
	next_spawn_time = game_timer + 1.0
	
	remaining_elites = ELITES

func _process(delta):
	if not get_tree().paused and not AudioManager.music.playing:
		AudioManager.music.play()
	global_position = player.global_position
	
	var cam_limit_x = CAMERA_LIMIT - (get_viewport().get_visible_rect().size.x/2)
	var cam_limit_y = CAMERA_LIMIT - (get_viewport().get_visible_rect().size.y/2)
	camera.global_position.x = clampf(player.global_position.x, -1*cam_limit_x, cam_limit_x)
	camera.global_position.y = clampf(player.global_position.y, -1*cam_limit_y, cam_limit_y)
	
	level.text = "Level " + str(player.level) + " (" + str(player.experience) + "/" + str(5 * (player.level * (player.level+1) / 2)) + ")"
	health.text = str(player.health)
	
	if not bosses.is_empty():
		var free_upgrade = false
		for i in range(bosses.size()):
			if i < bosses.size() and bosses[i] == null:
				bosses.remove_at(i)
				i += -1
				free_upgrade = true
		if free_upgrade and ((game_timer <= GAME_TIME * 60.0) or not bosses.is_empty()):
			# Free upgrade
			pausable = false
			get_tree().paused = true
			screen_level.prepare_to_upgrade()
	
	if pausable and Input.is_action_just_pressed("pause"):
		get_tree().paused = !get_tree().paused
		screen_paused.visible = !screen_paused.visible
	elif player.health <= 0:
		AudioManager.music.stop()
		pausable = false
		get_tree().paused = true
		screen_lose.visible = true
	elif not get_tree().paused and player.experience >= 5 * (player.level * (player.level+1) / 2):
		player.level += 1
		pausable = false
		get_tree().paused = true
		screen_level.prepare_to_upgrade()
	elif boss_fight and bosses.is_empty():
		if game_timer >= GAME_TIME * 60.0:
			pausable = false
			get_tree().paused = true
			screen_win.visible = true
		else:
			boss_fight = false
		
	
	if not get_tree().paused:
		game_timer += delta
		var clock_time = game_timer if ENDLESS_MODE else clampf(GAME_TIME * 60.0 - game_timer, 0.0, GAME_TIME * 60.0)
		var timer_minutes = str(int(clock_time / 60.0))
		var timer_seconds = ("0" if (fmod(clock_time, 60.0) < 10) else "") + str(int(fmod(clock_time, 60.0)))
		clock.text = timer_minutes + ":" + timer_seconds
		
		if game_timer >= next_spawn_time:
			if boss_fight:
				for boss in bosses:
					if boss.name == "(boss)_Raccoon":
						# Small Raccoon
						spawn_enemy(ENEMIES[3])
					if boss.name == "(boss)_Crab":
						# Small Crab
						spawn_enemy(ENEMIES[0])
			elif int(next_spawn_time) % 180 == 0 and not ENDLESS_MODE:
				# !! ELITE !!
				clear_enemies()
				bosses.append(spawn_enemy(remaining_elites.pop_at(randi_range(0, len(remaining_elites)-1))))
				boss_fight = true
			elif int(next_spawn_time) % 60 == 0:
				spawn_enemy(FOOD[0])
			elif int(next_spawn_time) % 20 == 0:
				# Turtle
				spawn_enemy(ENEMIES[2])
				spawn_enemy(ENEMIES[2])
			elif int(next_spawn_time) % 15 == 0:
				# Snake
				spawn_enemy(ENEMIES[1])
			else:
				# Crab
				spawn_enemy(ENEMIES[0])
			next_spawn_time += 1.0 # seconds

func clear_enemies():
	for child in enemies_group.get_children():
		if child.is_in_group("Enemies"):
			child.damage(INF)

func spawn_enemy(enemy: Resource):
	var new_enemy = enemy.instantiate()
	enemies_group.add_child(new_enemy)
	new_enemy.global_position = player.global_position + (SPAWN_AREA * Vector2.LEFT).rotated(randf_range(0, 2*PI))
	if new_enemy.get_script():
		new_enemy.scale_health(1 + (game_timer / 60.0))
	return new_enemy

func _on_button_main_menu_pressed():
	get_tree().paused = false
	AudioManager.music.stop()
	get_tree().change_scene_to_file("res://scenes/mainmenu.tscn")

func _on_button_continue_pressed():
	resume()

func resume():
	screen_paused.visible = false
	screen_level.visible = false
	get_tree().paused = false
	pausable = true

func create_damage_particle(dmg_position, damage):
	var new_damage_particle = DAMAGE_PARTICLE.instantiate()
	enemies_group.add_child(new_damage_particle)
	new_damage_particle.global_position = dmg_position - (new_damage_particle.get_size() / 2.0)
	new_damage_particle.text = "[font_size=" + str(12 * max(2.0, damage)) + "][color=red][b][i]" + str(round(damage * 100) / 100.0) + "[/i][/b][/color][/font_size]"
