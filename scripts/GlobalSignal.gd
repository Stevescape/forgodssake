extends Node

signal textbox_closed
signal close_box
signal summon_dog
signal enemy_done
signal player_done
signal summon_done
signal player_selected(player)

var player_ids = []
var is_multi = false
var cur_player = 0
var enemy
var player_display_names = {}
