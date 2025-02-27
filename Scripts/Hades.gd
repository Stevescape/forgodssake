extends Character


@export var mv1_dmg: int = 6
@export var mv1_self_dmg: int = 4
@export var mv2_heal: int = 2
@export var att_dmg: int = 2

var move_names = ["Soul Siphon", "Summon Dog", "Also Poke"]
var move_tooltips = ["Suck them deealing %d damage, but taking %d damage in shame" % [mv1_dmg, mv1_self_dmg],
					"Summon your best friend Borpie. If already on the field, heal %d hp." % [mv2_heal],
					"You just poke them. %d damage." % [att_dmg]]

func _init():
	max_health = 12
	entity_name = "Hades"

func put_tooltips(player):
	var buttons = get_tree().get_nodes_in_group("Player%dBtns" % player)
	for i in range(3):
		buttons[i].tooltip_text = move_tooltips[i]
		buttons[i].text = move_names[i]

func move1(enemy, _players, targets):
	await display_text("You attack %s using your soul taking some recoil damage in the process" % enemy.entity_name)
	
	await enemy.take_damage(mv1_dmg-debuff)
	await self.take_damage(mv1_self_dmg, true, true)
	debuff = 0
	GlobalSignal.player_done.emit()
	
	
func move2(enemy, players, targets):
	if players.size() <= 4:
		await display_text("You summon your trusty dog!")
		GlobalSignal.summon_dog.emit()
		GlobalSignal.player_done.emit()
	else:
		await self.heal(mv2_heal)
		GlobalSignal.player_done.emit()
	
func attack(enemy, _players, targets):
	await display_text("Bident Stab")
	await enemy.take_damage(att_dmg- debuff)

	debuff = 0
	GlobalSignal.player_done.emit()

func get_image_path():
	return "res://Assets/hades.png"
