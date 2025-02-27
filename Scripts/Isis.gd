extends Character

@export var mv1_heal: int = 2
@export var mv2_shield: int = 5
@export var att_dmg: int = 4

signal mv2_done

var move_names = ["Healing Wind", "Isis' Blessing", "Smack"]
var move_tooltips = ["You heal the whole team for %d hp." % [mv1_heal],
					"You grant a one-time use shield that blocks %d damage." % [mv2_shield],
					"You hit the enemy with your scepter. %d damage." % [att_dmg]]

func _init():
	max_health = 10
	entity_name = "Isis"

func put_tooltips(player):
	var buttons = get_tree().get_nodes_in_group("Player%dBtns" % player)
	for i in range(3):
		buttons[i].tooltip_text = move_tooltips[i]
		buttons[i].text = move_names[i]
			

func move1(enemy, players, targets):
	await display_text("Healing Wind")
	
	for i in players:
		await i.heal(mv1_heal)
	

func move2(enemy, players, _targets):
	# First target is enemy, second is ally
	show_select_buttons.rpc()
	var i = await GlobalSignal.player_selected
	hide_select_buttons.rpc()
	
	var target = players[i]
	
	move2_rpc.rpc(target.get_path())
	await mv2_done
	
@rpc ("any_peer", "call_local", "reliable")
func move2_rpc(target_path):
	await display_text("Isis' Blessing")
	var target = get_node(target_path)
	
	await target.shielded(mv2_shield)
	mv2_done.emit()
	#GlobalSignal.player_done.emit()
	
	

	
func attack(enemy, players, targets):
	await display_text("BOOOOOONK!")
	await enemy.take_damage(att_dmg-debuff)
	debuff = 0

func get_image_path():
	return "res://Assets/isisTheGod.png"

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
