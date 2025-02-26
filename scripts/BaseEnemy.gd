extends Character
var rng = RandomNumberGenerator.new()

func move1(_enemy, players, targets):
	var dmg = 5
	await display_text("Bark. Everyone takes %d damage." % dmg)
	
	for target in players:
		if not target.is_dead:
			await target.take_damage(dmg, false)
	
func move2(_enemy, players, targets):
	var dmg = 4
	# First target is enemy, second is ally
	await display_text("Thor spins on you")
	
	for i in targets:
		await players[i].take_damage(dmg)
	
func attack(_enemy, players, target):
	var dmg = 7
	
	await display_text("Thor smacks you with his biiiiiiig hammer")
	await players[target].take_damage(dmg)
