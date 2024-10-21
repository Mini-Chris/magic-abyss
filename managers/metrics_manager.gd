extends Node

var spell_uptimes = {} # what percent of the time is each spell on cooldown
var enemy_kills = {} # how many times did player kill enemy (N/A in current release)
var enemy_deaths = {} # how many times did enemy kill player (N/A in current release)
var chunk_clears = {} # how many times did player clear chunk (N/A in current release)
var chunk_deaths = {} # how many times did chunk kill player (N/A in current release)
# it would be neat if chunk deaths had a heatmap
var floor_times = [] # how long did each floor take to clear
var key_times = [] # how long did the player spend after picking up the key on each floor

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		get_tree().quit() # default behavior
