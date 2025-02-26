extends Node

@export var player1: Character
@export var player2: Character
@export var player3: Character
@export var player4: Character
@export var enemy: Character

var cur_player = 0
var static_players
var players
var summons

var dog = preload("res://Scenes/dog.tscn")
var move : Callable
var run_game
var rng = RandomNumberGenerator.new()

signal move_selected

func _ready() -> void:
	static_players = [player1, player2, player3, player4]
	players = [player1, player2, player3, player4]
	summons = []
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
	run_game = true
	start_game()

func start_game():
	while run_game:
		await player_turn()
		await check_enemy_death()
		await summon_turn()
		await check_enemy_death()
		await enemy_turn()
		await check_death()
		await advance_player()
		await enable_player_buttons(cur_player)

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
		await get_tree().create_timer(1).timeout
		get_tree().quit()
		
func check_enemy_death():	
	if enemy.is_dead:
		await $Textbox.display_text("Congratulations! You are winner!")
		run_game = false
		await get_tree().create_timer(1).timeout
		get_tree().quit()
	
func disable_all_buttons():
	for button in get_tree().get_nodes_in_group("Buttons"):
		button.disabled = true

func enable_player_buttons(player: int):
	for button in get_tree().get_nodes_in_group("Player%dBtns" % (player+1)):
		button.disabled = false

func advance_player():
	# Check if everyone is dead
	var all_dead = true
	for i in static_players:
		if not i.is_dead:
			all_dead = false
	if all_dead:
		return
		
	# Advance player
	cur_player += 1
	cur_player = cur_player % (static_players.size())
	while players[cur_player].skip_turn or players[cur_player].is_dead:
		players[cur_player].skip_turn = false
		cur_player += 1
		cur_player = cur_player % (static_players.size())

func player_turn():
	await move_selected
	
	disable_all_buttons()
	await move.call(enemy, players)
	
func enemy_turn():
	var num = rng.randi_range(1, 100)

	if num <= 33:
		await enemy.move1(enemy, players)
	elif num <= 66:
		await enemy.move2(enemy, players)
	elif num <= 100:
		await enemy.attack(enemy, players)

func summon_turn():
	for i in summons:
		await i.attack(enemy, players)

func _on_summon():
	var summon = dog.instantiate()
	$Players.add_child(summon)
	summons.append(summon)
	players.append(summon)

func _on_p1_mv1_pressed() -> void:
	move = Callable(players[cur_player], "move1")
	move_selected.emit()
	
func _on_p1_mv2_pressed() -> void:
	move = Callable(players[cur_player], "move2")
	move_selected.emit()

func _on_p1_att_pressed() -> void:
	move = Callable(players[cur_player], "attack")
	move_selected.emit()

func _on_p2_mv1_pressed() -> void:
	move = Callable(players[cur_player], "move1")
	move_selected.emit()
	
func _on_p2_mv2_pressed() -> void:
	move = Callable(players[cur_player], "move2")
	move_selected.emit()

func _on_p2_att_pressed() -> void:
	move = Callable(players[cur_player], "attack")
	move_selected.emit()
	
func _on_p3_mv1_pressed() -> void:
	move = Callable(players[cur_player], "move1")
	move_selected.emit()
	
func _on_p3_mv2_pressed() -> void:
	move = Callable(players[cur_player], "move2")
	move_selected.emit()

func _on_p3_att_pressed() -> void:
	move = Callable(players[cur_player], "attack")
	move_selected.emit()
	
func _on_p4_mv1_pressed() -> void:
	move = Callable(players[cur_player], "move1")
	move_selected.emit()
	
func _on_p4_mv2_pressed() -> void:
	move = Callable(players[cur_player], "move2")
	move_selected.emit()

func _on_p4_att_pressed() -> void:
	move = Callable(players[cur_player], "attack")
	move_selected.emit()

func _input(event: InputEvent) -> void:
	if $Textbox.visible and (Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or Input.is_action_pressed("ui_accept")):
		GlobalSignal.close_box.emit()
