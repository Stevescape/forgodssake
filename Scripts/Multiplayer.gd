extends Node

@export var player_list: ItemList  # A UI list to show players
@export var ip_input: LineEdit  # Input field for IP
@export var start_button: Button  # Start button (only for host)

var name_input

var peer = ENetMultiplayerPeer.new()
var select = preload("res://Scenes/CharacterSelect.tscn")

func _ready():
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	name_input = $NameInput

func host_game(port: int):
	peer.create_server(port, 4)
	multiplayer.multiplayer_peer = peer
	print("Hosting game...")

	# Store and sync the host's name immediately
	GlobalSignal.player_display_names[multiplayer.get_unique_id()] = name_input.text
	sync_global.rpc(GlobalSignal.player_display_names)

	# Register the host in the player list
	register_player.rpc(multiplayer.get_unique_id())

	start_button.visible = true

func join_game(ip: String, port: int):
	peer.create_client(ip, port)
	multiplayer.multiplayer_peer = peer
	print("Joining game at " + ip)

# Sync player display names to all clients
@rpc("authority", "call_local", "reliable")
func sync_global(dict):
	GlobalSignal.player_display_names = dict
	update_ui_list()

func _on_peer_connected(id):
	print("Player connected: ", id)

	# Host updates player names and syncs to everyone
	sync_global.rpc(GlobalSignal.player_display_names)

	# Register the new player in the list
	register_player.rpc(id)

# When a player disconnects, remove them from the list
func _on_peer_disconnected(id):
	print("Player disconnected: ", id)
	remove_player.rpc(id)

func _on_connected_to_server():
	# Send the player's name to the server so it gets updated everywhere
	update_display_name.rpc(multiplayer.get_unique_id(), name_input.text)
	# Immediately request a sync of player names from the host
	request_name_sync.rpc()

# Request a name sync from the host (for newly joined players)
@rpc("any_peer", "call_remote", "reliable")
func request_name_sync():
	if multiplayer.is_server():
		sync_global.rpc(GlobalSignal.player_display_names)

# Function to update a player's display name across all peers
@rpc("any_peer", "reliable")
func update_display_name(id, name):
	GlobalSignal.player_display_names[id] = name
	update_ui_list()

# Helper function to update the player list UI
func update_ui_list():
	player_list.clear()
	for id in GlobalSignal.player_display_names.keys():
		player_list.add_item(GlobalSignal.player_display_names[id])

func _on_host_pressed() -> void:
	GlobalSignal.is_multi = true
	var port = get_node("Panel/VBoxContainer/HBoxContainer/VBoxContainer2/LineEdit").text.to_int()
	var display_name = name_input.text
	
	GlobalSignal.player_display_names[multiplayer.get_unique_id()] = display_name
	host_game(port)
	
func _on_join_pressed() -> void:
	GlobalSignal.is_multi = true
	start_button.visible = false
	var ip = get_node("Panel/VBoxContainer/HBoxContainer/VBoxContainer/LineEdit").text
	var port = get_node("Panel/VBoxContainer/HBoxContainer/VBoxContainer2/LineEdit").text.to_int()
	
	player_list.add_item(name_input.text + " (You)")
	join_game(ip, port)

func _on_start_button_pressed():
	start_game.rpc()

@rpc("authority", "call_local", "reliable")
func register_player(id):
	if id in GlobalSignal.player_ids:
		return  # Prevent duplicate entry

	if id in GlobalSignal.player_display_names:
		player_list.add_item(GlobalSignal.player_display_names[id])
	else:
		player_list.add_item("Player %d" % id)

	GlobalSignal.player_ids.append(id)


@rpc("authority", "call_local", "reliable")
func remove_player(id):
	GlobalSignal.player_ids.erase(id)
	GlobalSignal.player_display_names.erase(id)
	update_ui_list()

@rpc("authority", "call_local", "reliable")
func start_game():
	if not GlobalSignal.is_multi:
		GlobalSignal.player_ids.append(multiplayer.get_unique_id())
		
	if GlobalSignal.player_ids.size() < 4:
		var i = 0
		while GlobalSignal.player_ids.size() < 4:
			GlobalSignal.player_ids.append(GlobalSignal.player_ids[i])
			i += 1

	$MultiplayerSpawner.add_spawnable_scene("res://Scenes/CharacterSelect.tscn")
	get_tree().current_scene.queue_free()

	var instances_scene = select.instantiate()
	get_tree().root.add_child(instances_scene)
	get_tree().current_scene = instances_scene
