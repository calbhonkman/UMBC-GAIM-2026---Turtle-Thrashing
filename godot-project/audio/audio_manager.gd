extends Node2D

#Music
@onready var music1 = $music1
@onready var music2 = $music2

#SFX
@onready var xp_pickup_sfx = $xp_pickup
@onready var punch = $punch
@onready var laser = $laser
@onready var cloud = $cloud
@onready var slap = $slap
@onready var eat = $eat
@onready var slam = $slam
@onready var whoosh = $whoosh
@onready var rulerTwang = $rulerTwang
@onready var poof = $poof
@onready var stampede = $stampede
@onready var roar = $roar
@onready var suck = $suck
@onready var playerHurt = $playerHurt
@onready var eliteWarning = $eliteWarning
@onready var trt_sma_pch_1 = $turtlesamapunch1
@onready var trt_sma_pch_2 = $turtlesamapunch2
@onready var trt_sma_pch_3 = $turtlesamapunch3
@onready var trt_sma_pch_4 = $turtlesamapunch4
@onready var trt_sma_pch_5 = $turtlesamapunch5
@onready var eel_lightning = $eel_lightning
@onready var raccoon_surrender = $raccoon_surrender
@onready var king_throw = $king_throw
@onready var raccoon_throw = $raccoon_throw
@onready var chargeup = $chargeup
@onready var ui_pop = $ui_pop
@onready var eel_chargeup = $eel_chargeup
@onready var eel_discharge = $eel_discharge
@onready var heartbeat = $heartbeat
@onready var eeveel_death = $eeveel_death

#Voices/Jingles
@onready var crabJingle = $crabJingle
@onready var eelJingle = $eelJingle
@onready var raccoonKingJingle = $raccoonKingJingle
@onready var levelUp = $levelUp

var paused_sounds : Dictionary 

func pause_all_sounds():
	paused_sounds = {}
	for sound : AudioStreamPlayer in get_children():
		if sound.name == "music1" or sound.name == "music2": continue
		if sound.playing: 
			paused_sounds[sound] = sound.get_playback_position()
			sound.stop()

func resume_all_sounds():
	for sound : AudioStreamPlayer in paused_sounds:
		var playback_position = paused_sounds[sound]
		sound.play(playback_position)
