extends Node2D

#Music
@onready var music = $music

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

#Voices/Jingles
@onready var crabJingle = $crabJingle
@onready var eelJingle = $eelJingle
@onready var raccoonKingJingle = $raccoonKingJingle
@onready var levelUp = $levelUp

var paused_sounds : Dictionary 

func pause_all_sounds():
	paused_sounds = {}
	for sound : AudioStreamPlayer in get_children():
		if sound.name == "music": continue
		if sound.playing: 
			paused_sounds[sound] = sound.get_playback_position()
			sound.stop()

func resume_all_sounds():
	for sound : AudioStreamPlayer in paused_sounds:
		var playback_position = paused_sounds[sound]
		sound.play(playback_position)
