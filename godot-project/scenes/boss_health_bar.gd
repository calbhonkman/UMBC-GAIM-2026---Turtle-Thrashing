extends Node2D
@onready var sprite = $BarSprite
@onready var crab_bar = $CrabBar
@onready var raccoon_bar = $RaccoonBar

#Crab Border Constants
var CRAB_POS_X: float = -12.0
var CRAB_POS_Y: float = 436.0
var CRAB_SIZE_X: float = 1.0
var CRAB_SIZE_Y: float = 1.0

#Raccoon Border Constants
var RACCOON_POS_X: float = -10.0
var RACCOON_POS_Y: float = 434.0
var RACCOON_SIZE_X: float = 0.25
var RACCOON_SIZE_Y: float = 0.25


var bosses = ["raccoon", "crab", "eel"]
var curr_boss = null
var curr_bar = null
var max_health

func _ready():
	crab_bar.visible = false
	raccoon_bar.visible = false
	
	curr_bar = crab_bar #placeholder assignment

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if visible == true:
		curr_bar.value = int(curr_boss.health / max_health * 100)

func newElite(boss):
	curr_bar.visible = false
	curr_boss = boss
	max_health = curr_boss.health
	if boss.name == "(boss)_Raccoon":
		curr_bar = raccoon_bar
		setBorder(bosses[0], RACCOON_POS_X, RACCOON_POS_Y, RACCOON_SIZE_X, RACCOON_SIZE_Y)
	elif boss.name == "(boss)_Crab":
		curr_bar = crab_bar
		setBorder(bosses[1], CRAB_POS_X, CRAB_POS_Y, CRAB_SIZE_X, CRAB_SIZE_Y)
	elif boss.name == "(boss)_Eeveel":
		pass
		#sprite.play("eel")
	curr_bar.visible = true

func setBorder(spr, pos_x, pos_y, size_x, size_y):
	sprite.position.x = pos_x
	sprite.position.y = pos_y
	sprite.scale.x = size_x
	sprite.scale.y = size_y
	sprite.play(spr)
