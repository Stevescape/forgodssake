extends Node

@export var player_list: ItemList  # A UI list to show players
@export var ip_input: LineEdit  # Input field for IP
@export var start_button: Button  # Start button (only for host)

var peer = ENetMultiplayerPeer.new()

func _ready():
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)

func host_game(port: int):
	peer.create_server(port, 4)
	multiplayer.multiplayer_peer = peer
	print("Hosting game...")
	player_list.add_item("Host (You)")
	register_player.rpc(multiplayer.get_unique_id())
	start_button.visible = true

func join_game(ip: String, port: int):
	peer.create_client(ip, port)
	multiplayer.multiplayer_peer = peer
	print("Joining game at " + ip)

func _on_peer_connected(id):
	player_list.add_item("Player %d" % id)
	register_player.rpc(id)

# When a player disconnects
func _on_peer_disconnected(id):
	remove_player.rpc()

func _on_connected_to_server():
	player_list.add_item("You")

func _on_host_pressed() -> void:
	GlobalSignal.is_multi = true
	var port = get_node("Panel/VBoxContainer/HBoxContainer/VBoxContainer2/LineEdit").text.to_int()
	host_game(port)
	
func _on_join_pressed() -> void:
	GlobalSignal.is_multi = true
	start_button.visible = false
	var ip = get_node("Panel/VBoxContainer/HBoxContainer/VBoxContainer/LineEdit").text
	var port = get_node("Panel/VBoxContainer/HBoxContainer/VBoxContainer2/LineEdit").text.to_int()
	join_game(ip, port)

func _on_start_button_pressed():
	start_game()

@rpc ("authority", "call_local", "reliable")
func register_player(id):
	GlobalSignal.player_ids.append(id)

@rpc ("authority", "call_local", "reliable")
func remove_player(id):
	GlobalSignal.player_ids.remove_item(id)

@rpc("authority", "reliable")
func start_game():
	start_game.rpc()  # Sync game start across peers
	get_tree().change_scene_to_file("res://Scenes/battle.tscn")
	
