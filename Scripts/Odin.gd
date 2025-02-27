extends Character


@export var mv2_debuff: int = 2
@export var att_dmg: int = 2

var rng = RandomNumberGenerator.new()

var move_names = ["Gaze of the Allfather", "Rune of Weakness", "Spear Strike"]
var move_tooltips = ["Stuns the enemy for one turn as they are overwhelmed by cosmic knowledge. Has a 50% chance of hitting",
					"Lowers the enemy's attack by %d for one turn" % mv2_debuff,
					"A spear strike dealing %d damage." % att_dmg]

signal random_num
signal mv1_done

func _init():
	max_health = 15
	entity_name = "Daddy"

func put_tooltips(player):
	var buttons = get_tree().get_nodes_in_group("Player%dBtns" % player)
	for i in range(3):
		buttons[i].tooltip_text = move_tooltips[i]
		buttons[i].text = move_names[i]

func move1(enemy, _players, targets):
	gen_random.rpc(enemy.get_path())
	await random_num
	

@rpc ("authority", "call_remote", "reliable")
func gen_random(enemy_path):
	var num = rng.randi_range(1, 100)
	move1_rpc.rpc(enemy_path, num)
	await mv1_done
	random_num.emit()

@rpc ("any_peer", "call_local", "reliable")
func move1_rpc(enemy_path, num):
	var enemy = get_node(enemy_path)
	
	if num <= 50:
		await display_text("You use your big sexy eye to seduce and stun %s for one turn" % enemy.entity_name)
		enemy.skip_turn = true
	else:
		await display_text("You stare off into the sunset missing the enemy")
	mv1_done.emit()
	GlobalSignal.player_done.emit()
	
func move2(enemy, players, targets):
	enemy.debuff += mv2_debuff
	await display_text("You debuff %s causing them to deal %d less damage." % [enemy.entity_name, mv2_debuff])
	GlobalSignal.player_done.emit()
	
	
func attack(enemy, _players, targets):
	await display_text("You strike %s with your spear." % enemy.entity_name)
	await enemy.take_damage(att_dmg- debuff)

	debuff = 0
	GlobalSignal.player_done.emit()

func get_image_path():
	return "res://Assets/oshit.png"
