extends Node2D 

const TURTLE_SAMA = preload("uid://cv148hqf0xhcr") 
@onready var player = $"/root/Node2D/Player" 

@export var unlocked: bool = false 
@export var upgrade_descriptions: Array[String] 
@export var upgrade_icon: Resource 
@export var upgrade_icon_selected: Resource 

@export var BASE_PUNCHES: int = 4 
@export var BASE_DAMAGE: float = 0.5

var punches = 0 
var damage = 0 
var size_mod = 1.0 
var minion = null 

func _ready(): 
	punches = BASE_PUNCHES 
	damage = BASE_DAMAGE
	
func get_random_upgrade(index): 
	if not unlocked: 
		return Vector2(index, 0) 
	else: 
		return Vector2(index, randi_range(1, 3)) 
		
func get_upgrade_description(index: int): 
	var desc = "[outline_size=10][outline_color=black]" 
	desc += "[b]Turtle-Sama[/b][br]" 
	match index: 
		0: 
			desc += "Unlocks the Lengendary Turtle-Sama!" 
			desc += "[br]Attacks the strongest enemy close to you." 
		1: 
			desc += "[i][color=#8f8f8f]Turtle-Sama hits even harder.[/color][/i]" 
			desc += "[br]Increases Punch Damage ([color=#8FFFFF]" + str(round(damage * 100) / 100.0) + " -> " + str(round((damage + 0.5) * 100) / 100.0) + "[/color])." 
		2: 
			desc += "[i][color=#8f8f8f]Turtle-Sama punches even more.[/color][/i]" 
			desc += "[br]Increases punches per flurry ([color=#8FFFFF]" + str(punches) + " -> " + str(punches + 2) + "[/color])." 
		3: 
			desc += "[i][color=#8f8f8f]Turtle-Sama is bigger and badder.[/color][/i]" 
			desc += "[br]Increases size ([color=#8FFFFF]" + str(round(size_mod * 100) / 100.0) + "x -> " + str(round(size_mod * 1.25 * 100) / 100.0) + "[/color])." 
	desc += "[/outline_color][/outline_size]" 
	
	return desc 
	
func upgrade(index: int): 
	match index: 
		0: 
			unlocked = true 
			visible = true 
			minion = TURTLE_SAMA.instantiate() 
			#get_tree().current_scene.add_child(minion)
			get_tree().current_scene.add_child.call_deferred(minion)
			minion.global_position = player.global_position
		1: 
			damage += 0.5
		2: 
			punches += 2
		3: 
			size_mod *= 1.25
	minion.update_stats(damage, punches, size_mod) 
