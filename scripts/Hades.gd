extends Character


@export var mv1_dmg: int = 6
@export var mv1_self_dmg: int = 4
@export var mv2_heal: int = 2
@export var att_dmg: int = 2

func move1(enemy, _players, targets):
	await display_text("You attack %s using your soul taking some recoil damage in the process" % enemy.entity_name)
	
	await enemy.take_damage(mv1_dmg)
	await self.take_damage(mv1_self_dmg)
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
	await enemy.take_damage(att_dmg)
	await display_text("Bident Stab")
	GlobalSignal.player_done.emit()
