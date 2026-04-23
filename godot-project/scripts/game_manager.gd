extends Node2D

@onready var player = $"../Player"

@onready var camera = $Camera
@onready var clock = $Camera/Clock
@onready var level = $Camera/Level
@onready var health = $"Camera/Health Icon/Health"
@onready var bossHealthBar = $"Camera/BossHealthBar"
@onready var elite_warning = $"Camera/Elite Warning"
@onready var time_bar = $"Camera/Timer Bar/TimeBar"
@onready var time_border = $"Camera/Timer Bar/TimeBoder"

const DAMAGE_PARTICLE = preload("uid://dum7dfhvymdrp")

@export var CAMERA_LIMIT: float = 1600.0

@export var WAVE_TIME: float = 150.0 # seconds
@export var NUM_WAVES: int = 4
var game_timer: float = 0.0
var current_wave: int = 1
var spawn_timer: float = 0.0
var next_spawn_time: float = 0.0
var spawn_counter: int = 1

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

var remaining_elites = []
var boss_fight = false
var boss = null

var pausable = true

@export var EXP_HUE_SPEED: float = 2.0
var exp_hue: float = 0.0

func _ready():
	remaining_elites = ELITES.duplicate()
	bossHealthBar.visible = false
	elite_warning.visible = false

func _process(delta):
	exp_hue = wrapf(exp_hue + (EXP_HUE_SPEED * delta), 0.0, 1.0)
	
	if not AudioManager.music.playing:
		AudioManager.music.play()
	
	var cam_limit_x = CAMERA_LIMIT - (get_viewport().get_visible_rect().size.x/2)
	var cam_limit_y = CAMERA_LIMIT - (get_viewport().get_visible_rect().size.y/2)
	camera.global_position.x = clampf(player.global_position.x, -1*cam_limit_x, cam_limit_x)
	camera.global_position.y = clampf(player.global_position.y, -1*cam_limit_y, cam_limit_y)
	
	level.text = "Level " + str(player.level) + " (" + str(player.experience) + "/" + str(5 * (player.level * (player.level+1) / 2)) + ")"
	health.text = str(player.health)
	
	if pausable and Input.is_action_just_pressed("pause"):
		get_tree().paused = !get_tree().paused
		screen_paused.visible = !screen_paused.visible
		AudioManager.pause_all_sounds()
	
	if player.health <= 0:
		AudioManager.music.stop()
		pausable = false
		get_tree().paused = true
		screen_lose.visible = true
	
	if not get_tree().paused and player.experience >= 5 * (player.level * (player.level+1) / 2):
		player.level += 1
		pausable = false
		get_tree().paused = true
		AudioManager.pause_all_sounds()
		screen_level.prepare_to_upgrade()
	
	if boss_fight and boss == null:
		pausable = false
		get_tree().paused = true
		if current_wave >= ELITES.size() or game_timer >= WAVE_TIME * NUM_WAVES:
			screen_win.visible = true
		else:
			screen_level.prepare_to_upgrade()
			boss = null
		current_wave += 1
		boss_fight = false
		bossHealthBar.visible = false
	
	if not get_tree().paused:
		game_timer = (round(game_timer / WAVE_TIME) * WAVE_TIME) if boss_fight else game_timer + delta
		var clock_time = clampf((WAVE_TIME * NUM_WAVES) - game_timer, 0.0, WAVE_TIME * NUM_WAVES)
		var timer_minutes = str(int(clock_time / 60.0))
		var timer_seconds = ("0" if (fmod(clock_time, 60.0) < 10) else "") + str(int(fmod(clock_time, 60.0)))
		clock.text = timer_minutes + ":" + timer_seconds
		time_bar = (1 - ((game_timer * current_wave) / (WAVE_TIME * NUM_WAVES))) * 100
		
		if game_timer >= (WAVE_TIME - 10) and elite_warning.visible == false and boss == null:
			elite_warning.visible = true
			AudioManager.eliteWarning.play()
		
		if game_timer >= ((WAVE_TIME - 10) * current_wave) and elite_warning.visible == false and boss == null:
			elite_warning.visible = true
			AudioManager.eliteWarning.play()
		
		elif game_timer >= (WAVE_TIME * current_wave) and boss == null:
			boss = spawn(remaining_elites.pop_at(randi_range(0, remaining_elites.size()-1)))
			boss_fight = true
			bossHealthBar.visible = true
			bossHealthBar.newElite(boss)
			elite_warning.visible = false
		
		spawn_timer += delta
		if spawn_timer >= next_spawn_time:
			if boss_fight:
				if boss.name == "(boss)_Raccoon":
					# Small Raccoon
					spawn(ENEMIES[3])
				elif boss.name == "(boss)_Crab":
					# Small Crab
					spawn(ENEMIES[0])
				elif boss.name == "(boss)_Eeveel":
					# Small Crab
					spawn(ENEMIES[0])
			else:
				if spawn_counter % 60 == 0:
					spawn(FOOD[0])
				if current_wave >= 1 and spawn_counter % 20 == 0:
					if current_wave == 1:
						spawn(ENEMIES[1]) # Snake
					if current_wave == 2:
						spawn(ENEMIES[5]) # Seagull
						spawn(ENEMIES[5]) # Seagull
						spawn(ENEMIES[5]) # Seagull
					if current_wave == 3:
						spawn(ENEMIES[4]) # Bush
				if current_wave >= 2 and spawn_counter % 15 == 0:
					if current_wave == 2:
						spawn(ENEMIES[2]) # Turtle
					if current_wave == 3:
						spawn(ENEMIES[5]) # Seagull
						spawn(ENEMIES[5]) # Seagull
						spawn(ENEMIES[5]) # Seagull
				elif current_wave >= 2 and spawn_counter % 10 == 0:
					if current_wave == 2:
						spawn(ENEMIES[1]) # Snake
					if current_wave == 3:
						spawn(ENEMIES[2]) # Turtle
				elif current_wave >= 3 and spawn_counter % 5 == 0:
					spawn(ENEMIES[1]) # Snake
				else:
					spawn(ENEMIES[0]) # Crab

func clear_enemies():
	for child in enemies_group.get_children():
		if child.is_in_group("Enemies"):
			child.queue_free()

func spawn(entity: Resource):
	var new_spawn = entity.instantiate()
	enemies_group.add_child(new_spawn)
	new_spawn.global_position = player.global_position + (SPAWN_AREA * Vector2.LEFT).rotated(randf_range(0, 2*PI))
	if new_spawn.get_script():
		new_spawn.scale_health(1 + (game_timer / 60.0))
	next_spawn_time += 1.0 - (0.5 * current_wave / NUM_WAVES)
	spawn_counter += 1
	return new_spawn

func _on_button_main_menu_pressed():
	get_tree().paused = false
	for child in AudioManager.get_children():
		child.stop()
	get_tree().change_scene_to_file("res://scenes/mainmenu.tscn")

func _on_button_continue_pressed():
	resume()

func resume():
	screen_paused.visible = false
	screen_level.visible = false
	get_tree().paused = false
	pausable = true
	AudioManager.resume_all_sounds()

func create_damage_particle(dmg_position, damage):
	var new_damage_particle = DAMAGE_PARTICLE.instantiate()
	enemies_group.add_child(new_damage_particle)
	new_damage_particle.global_position = dmg_position - (new_damage_particle.get_size() / 2.0)
	new_damage_particle.text = "[font_size=" + str(16 * max(1.0, damage)) + "][color=red][b][i]" + str(round(damage * 100) / 100.0) + "[/i][/b][/color][/font_size]"
