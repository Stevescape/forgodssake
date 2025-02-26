extends Node

@export var player1: Character
@export var player2: Character
@export var player3: Character
@export var player4: Character
@export var enemy: Character

var player_ids = GlobalSignal.player_ids
var cur_player = 0
var static_players
var players
var summons = []

var dog = preload("res://Scenes/dog.tscn")
var move : Callable
var run_game = true
var rng = RandomNumberGenerator.new()

signal advanced
signal move_selected

func _ready() -> void:
	static_players = [player1, player2, player3, player4]
	
	players = static_players.duplicate()
	
	# Ensure player_ids are at least 4 in case there are less than 4 players
	if player_ids.size() < 4:
		var i = 0
		while player_ids.size() < 4:
			player_ids.append(player_ids[i])
			i += 1
	
	print(player_ids)
	
	for player in players:
		player.health = player.max_health
		player.update_health()
		player._update_label()

	enemy.health = enemy.max_health
	enemy.update_health()
	enemy._update_label(true)

	GlobalSignal.summon_dog.connect(_on_summon)
	
	disable_all_buttons()
	enable_player_buttons(cur_player)
	
	if multiplayer.is_server():
		start_game()

### 🌟 Multiplayer-Safe Turn Loop
@rpc("authority", "call_local", "reliable")
func start_game():
	while run_game:
		
		for i in static_players:
			# Wait for the player to finish their move
			player_turn.rpc()
			await GlobalSignal.player_done
			
			check_enemy_death.rpc()
			
			# Advance to next player
			advance_player.rpc()
			await advanced
			# Enable buttons for the next player's turn
			enable_player_buttons.rpc(cur_player)
		disable_all_buttons.rpc()

		# Do summon turn
		print("Doing summon turn")
		summon_turn.rpc()
		await GlobalSignal.summon_done

		check_enemy_death.rpc()
		
		# Do enemy turn
		print("Enemy turn")
		enemy_turn.rpc()
		await GlobalSignal.enemy_done

		check_death.rpc()

@rpc ("authority", "call_local", "reliable")
func check_death():
	var all_dead = true
	for player in static_players:
		if not player.is_dead:
			all_dead = false
	
	if summons.size() > 0:
		if players[4].is_dead:
			players[4].queue_free()
			summons.remove_at(0)
			players.remove_at(4)
			
	if all_dead:
		await $Textbox.display_text("Good luck next time!")
		run_game = false
		$Menu.show()

@rpc ("authority", "call_local", "reliable")
func check_enemy_death():	
	if enemy.is_dead:
		await $Textbox.display_text("Congratulations! You are winner!")
		run_game = false
		$Menu.show()


### 🌟 Synchronize Player Turn
@rpc("any_peer", "call_local", "reliable")
func player_turn():
	await move_selected
	
	disable_all_buttons.rpc()  # Disable buttons for all other players
	
	await move.call(enemy, players, players[generate_target(players)])
	GlobalSignal.player_done.emit()

### 🌟 Synchronize Turn Advancement
@rpc("any_peer", "call_local", "reliable")
func advance_player():
	cur_player += 1
	cur_player = cur_player % static_players.size()
	
	while players[cur_player].skip_turn or players[cur_player].is_dead:
		players[cur_player].skip_turn = false
		cur_player += 1
		cur_player = cur_player % static_players.size()

	print("Next turn: Player", cur_player + 1)
	await get_tree().create_timer(0.5).timeout
	advanced.emit()

### 🌟 Handle Summons Properly
@rpc("authority", "call_local", "reliable")
func summon_dog():
	if multiplayer.is_server():
		var summon = dog.instantiate()
		$Players.add_child(summon)
		summons.append(summon)
		players.append(summon)
		
		summon_dog_rpc.rpc()

@rpc("authority", "call_remote", "reliable")
func summon_dog_rpc():
	var summon = dog.instantiate()
	$Players.add_child(summon)
	summons.append(summon)
	players.append(summon)
	print("Summon added on peer.")


@rpc("authority", "call_local", "reliable")
func summon_turn():
	for summon in summons:
		await summon.attack(enemy, players, [])
	await get_tree().create_timer(0.5).timeout
	GlobalSignal.summon_done.emit()

@rpc("authority", "call_remote", "reliable")
func enemy_turn():
	# Server generates the enemy's move decision
	var num = rng.randi_range(1, 100)
	var move_type = ""
	var targets = []
	
	if num <= 33:
		move_type = "move1"
		targets = generate_target(players)
	elif num <= 66:
		move_type = "move2"
		var target1 = generate_target(players)
		targets.append(target1)
		var alive = 0
		for i in players:
			if not i.is_dead:
				alive += 1
		
		var target2
		if alive >= 2:
			target2 = generate_target(players)
			while target2 == target1:
				target2 = generate_target(players)
			targets.append(target2)
	else:
		move_type = "attack"
		targets = generate_target(players)

	# Emit the move type to all peers
	enemy_move_rpc.rpc(move_type, targets)
	
# Broadcast the enemy's move to all peers
@rpc("any_peer", "call_local", "reliable")
func enemy_move_rpc(move_type: String, targets):
	# Make sure all peers execute the same move type
	if move_type == "move1":
		await enemy.move1(enemy, players, targets)
	elif move_type == "move2":
		await enemy.move2(enemy, players, targets)
	elif move_type == "attack":
		await enemy.attack(enemy, players, targets)
	GlobalSignal.enemy_done.emit()

### 🌟 Summon Handling with Multiplayer
func _on_summon():
	summon_dog.rpc()

func generate_target(players):
	var target = rng.randi_range(0, players.size()-1)
	
	while players[target].is_dead:
		target = rng.randi_range(0, players.size()-1)
		
	return target

# Helper function to handle the move
@rpc("any_peer", "call_local", "reliable")
func _on_player_move_pressed(move_name: String):
	move = Callable(players[cur_player], move_name)
	move_selected.emit()  # This should trigger the awaited move

# Player Button Press Handlers (Updated to call .rpc())
@rpc("any_peer", "reliable")
func _on_p1_mv1_pressed():
	_on_player_move_pressed.rpc("move1")  # Remote call to all peers

@rpc("any_peer", "reliable")
func _on_p1_mv2_pressed():
	_on_player_move_pressed.rpc("move2")

@rpc("any_peer", "reliable")
func _on_p1_att_pressed():
	_on_player_move_pressed.rpc("attack")

@rpc("any_peer", "reliable")
func _on_p2_mv1_pressed():
	_on_player_move_pressed.rpc("move1")

@rpc("any_peer", "reliable")
func _on_p2_mv2_pressed():
	_on_player_move_pressed.rpc("move2")

@rpc("any_peer", "reliable")
func _on_p2_att_pressed():
	_on_player_move_pressed.rpc("attack")

@rpc("any_peer", "reliable")
func _on_p3_mv1_pressed():
	_on_player_move_pressed.rpc("move1")

@rpc("any_peer", "reliable")
func _on_p3_mv2_pressed():
	_on_player_move_pressed.rpc("move2")

@rpc("any_peer", "reliable")
func _on_p3_att_pressed():
	_on_player_move_pressed.rpc("attack")

@rpc("any_peer", "reliable")
func _on_p4_mv1_pressed():
	_on_player_move_pressed.rpc("move1")

@rpc("any_peer", "reliable")
func _on_p4_mv2_pressed():
	_on_player_move_pressed.rpc("move2")

@rpc("any_peer", "reliable")
func _on_p4_att_pressed():
	_on_player_move_pressed.rpc("attack")

### 🛑 UI & Input Handling
@rpc ("authority", "call_local", "reliable")
func disable_all_buttons():
	for button in get_tree().get_nodes_in_group("Buttons"):
		button.disabled = true

@rpc ("authority", "call_local", "reliable")
func enable_player_buttons(player: int):
	if multiplayer.get_unique_id() == player_ids[cur_player]:
		for button in get_tree().get_nodes_in_group("Player%dBtns" % (player+1)):
			button.disabled = false

func _input(event: InputEvent) -> void:
	if $Textbox.visible and (Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or Input.is_action_pressed("ui_accept")):
		emit_close_box.rpc()

@rpc ("any_peer", "call_local", "reliable")
func emit_close_box():
	GlobalSignal.close_box.emit()


func _on_menu_pressed() -> void:
	_go_to_lobby.rpc()

@rpc ("any_peer", "call_local", "reliable")
func _go_to_lobby():
	get_tree().change_scene_to_file("res://Scenes/lobby.tscn")
