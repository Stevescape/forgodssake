extends Character
var rng = RandomNumberGenerator.new()

func generate_target(players):
	var target = rng.randi_range(0, players.size()-1)
	
	while players[target].is_dead:
		target = rng.randi_range(0, players.size()-1)
		
	return players[target]

func move1(enemy, players):
	var dmg = 5
	await display_text("Bark")
	
	for target in players:
		await target.take_damage(dmg)
	
func move2(enemy, players):
	
	
	var dmg = 7
	# First target is enemy, second is ally
	await display_text("Spin")
		
	var target1 = generate_target(players)
	var target2 = generate_target(players)
	while target2 == target1:
		target2 = generate_target(players)
		
	
	await target1.take_damage(dmg)
	await target2.take_damage(dmg)
	
func attack(enemy, players):
	var target = generate_target(players)
	
	var dmg = 7
	
	await display_text("Shank")
	await target.take_damage(dmg)
