extends Character

@export var mv1_dmg: int = 2
@export var mv1_heal: int = 3
@export var mv2_dmg: int = 8
@export var att_dmg: int = 4

func put_tooltips(player):
	var buttons = get_tree().get_nodes_in_group("Player%dBtns" % player)
	for i in buttons.size():
		if i == 0:
			buttons[i].tooltip_text = \
			"Summon mystical water to deal %d damage and heal %d hp to a teammate!" % [mv1_dmg, mv1_heal]
		if i == 1:
			buttons[i].tooltip_text = \
			"Call upon a tsunami dealing %d damage, but it leaves you exhausted." % [mv2_dmg]
		if i == 2:
			buttons[i].tooltip_text = \
			"You just poke them. %d damage." % [att_dmg]
			

func move1(enemy, players, _targets):
	# First target is enemy, second is ally
	show_select_buttons.rpc()
	var i = await GlobalSignal.player_selected
	hide_select_buttons.rpc()
	
	display_text.rpc("Water")
	await GlobalSignal.textbox_closed
	
	var target = players[i]
	
	enemy.take_damage.rpc(mv1_dmg)
	
	await GlobalSignal.textbox_closed
	
	target.heal.rpc(mv1_heal)
	await GlobalSignal.textbox_closed
	
	
func move2(enemy, players, targets):
	skip_turn = true
	
	await display_text("Tsunami")
	
	await play_animation("tsunami")
	
	await enemy.take_damage(mv2_dmg)
	
	
	
func attack(enemy, players, targets):
	await display_text("Stab")
	await enemy.take_damage(att_dmg)

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
