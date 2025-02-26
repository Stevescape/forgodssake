extends Character

@export var att_dmg: int = 5

func attack(enemy, _players, targets):
	await display_text("Demon dog takes a chunk out of %s." % enemy.entity_name)
	await enemy.take_damage(att_dmg)
	GlobalSignal.summon_done.emit()
	

func heal(amount: int):
	health = max(0, health-amount)
	await textbox.display_text("%s has taken %d damage from the holy power." % [entity_name, amount])
	update_health()
	
