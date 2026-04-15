extends Node2D
#@onready var bossBar = $ColorRect
@onready var sprite = $BarSprite
@onready var bossBar = $ProgressBar

var currBoss = null
var max_health

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if visible == true:
		bossBar.value = int(currBoss.health / max_health * 100)

func newElite(boss):
	currBoss = boss
	max_health = currBoss.health
	if boss.name == "(boss)_Raccoon":
		pass
		#sprite.play("raccoon")
	elif boss.name == "(boss)_Crab":
		sprite.play("crab")
	elif boss.name == "(boss)_Eeveel":
		pass
		#sprite.play("eel")
