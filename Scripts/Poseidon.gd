extends Character

@export var mv1_dmg: int = 2
@export var mv1_heal: int = 3
@export var mv2_dmg: int = 8
@export var att_dmg: int = 4

signal mv1_done

var move_names = ["Mystical Water", "Tsunami", "Poke"]
var move_tooltips = ["Summon mystical water to deal %d damage and heal %d hp to a teammate!" % [mv1_dmg, mv1_heal],
					"Call upon a tsunami dealing %d damage, but it leaves you exhausted." % [mv2_dmg],
					"You just poke them. %d damage." % [att_dmg]]

func _init():
	max_health = 12
	entity_name = "Pussiedon"

func put_tooltips(player):
	var buttons = get_tree().get_nodes_in_group("Player%dBtns" % player)
	for i in range(3):
		buttons[i].tooltip_text = move_tooltips[i]
		buttons[i].text = move_names[i]
			

func move1(enemy, players, _targets):
	# First target is enemy, second is ally
	show_select_buttons.rpc()
	var i = await GlobalSignal.player_selected
	hide_select_buttons.rpc()
	
	var target = players[i]
	
	move1_rpc.rpc(enemy.get_path(), target.get_path())
	await mv1_done
	
@rpc ("any_peer", "call_local", "reliable")
func move1_rpc(enemy_path, target_path):
	await display_text("Mystic Water")
	
	var enemy = get_node(enemy_path)
	var target = get_node(target_path)
	
	await target.heal(mv1_heal)
	await enemy.take_damage(mv1_dmg-debuff)
	debuff = 0
	
	mv1_done.emit()
	#GlobalSignal.player_done.emit()
	
	
func move2(enemy, players, targets):
	skip_turn = true
	
	await display_text("Tsunami")
	
	await play_animation("tsunami")
	
	await enemy.take_damage(mv2_dmg-debuff)
	debuff = 0
	
	
func attack(enemy, players, targets):
	await display_text("Stab")
	await enemy.take_damage(att_dmg - debuff)
	debuff = 0

func get_image_path():
	return "res://Assets/pusseiden.png"

@rpc ("any_peer", "call_local", "reliable")
func show_select_buttons():
	if multiplayer.get_unique_id() == GlobalSignal.player_ids[GlobalSignal.cur_player]:
		var buttons = get_tree().get_nodes_in_group("SelectButtons")
		for i in buttons:
			i.visible = true

@rpc ("any_peer", "call_local", "reliable")
func hide_select_buttons():
	var buttons = get_tree().get_nodes_in_group("SelectButtons")
	for i in buttons:
		i.visible = false
