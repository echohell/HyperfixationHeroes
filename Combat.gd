extends Node2D

class_name Combat
															   # signals showing current game state
signal update_information(text: String)                        # sends info to text box for visuals
signal register_combat_start(combat_node: Node)                                # combat has started
signal turn_advance(combatant: Dictionary)                                       # turn has changed
signal combatant_added(combatant: Dictionary)                     # adding a combatant to the fight
signal combatant_down(combatant: Dictionary)           # combatant is down and will miss their turn
signal update_turn_queue(combatants: Array, turn_queue: Array)             # updates the turn order
signal update_combatants(combatants: Array)                        # updates the list of combatants
signal combat_finished()                                                       # combat is finished

enum Group{Players, Enemies}                                   # enums dictating information states
enum UnitClass{Melee, Ranged, Magic}

var groups = [[], []]                                               # players first, enemies second
var combatants = []                                                           # array of combatants
var current_combatant = 0                                                   # the current combatant
var turn = 0                                    # simple val for tracking turn forward, keep global
var turn_queue = []                                                    # array for whose turn it is

@onready var _unit = load("res://Unit.tscn")                # loads unit scene to instantiate units

@export var _playergroup: Node2D                        # exported classes to be used on game board
@export var _enemygroup: Node2D
@export var _combat_UI: Control
@export var _gameboard: GameBoard

# Idea for skills is that they are appended to here from a UI func on combat call, first space is
# ALWAYS basic attack, which has no like mp / energy / rage cost and does a set amount of damage.
# the 4 variables after 0 are the SPECIAL skills. if they dont have 4 special skills slotted, only
# the amount given from skills list shows. 3 skills, 3 buttons, etc. etc. Name HAS to match with
# string the object is, not the string of the skill name.
var skills_list = [
	["Meleeattack", "Rend", "Meteor", "Sandstorm", "Mudshot"],                              # melee
	["Rangeattack","Mudshot"],                                                             # ranged
	["Magicattack","Fireball"]                                                              # magic
] 


func _ready():
	emit_signal("register_combat_start", self)                                 # combat has started
	randomize()                                                           # setup randomized values
						# add combatants with the information (Base template, name, side, position)
	add_combatant(create_combatant(CombatantData.combatants["Player"], "Player"), 0, Vector2i(15,9))
	add_combatant(create_combatant(CombatantData.combatants["Player"], "Player2"), 0, Vector2i(13,9))
	add_combatant(create_combatant(CombatantData.combatants["Player"], "Player3"), 0, Vector2i(11,12))
	add_combatant(create_combatant(CombatantData.combatants["Player"], "Enemy"), 1, Vector2i(33,6))
	add_combatant(create_combatant(CombatantData.combatants["Player"], "Enemy2"), 1, Vector2i(37,6))
													 # when combatants are added, update turn queue
	emit_signal("update_turn_queue", combatants, turn_queue)
	
	_gameboard._on_combat_processing_turn_advance(combatants[turn_queue[0]])
	_combat_UI.set_skill_list(combatants[turn_queue[0]].skills_list)


func create_combatant(definition: CombatantDefinition, override_name = ""):
																		  # local var to set values
	var created = {
		"name" = definition.name,
		"max_hp" = definition.max_hp,
		"hp" = definition.max_hp,
		"class" = definition._class_t,
		"alive" = true,
		"movement_class" = definition._class_m,
		"skills_list" = skills_list[definition._class_t].duplicate(),
		"icon" = definition.icon,
		"map_sprite" = definition.map_sprite,
		"movement" = definition.movement,
		"initiative" = definition.initiative,
		"turn_taken" = false,
		"unit" = definition.unit,
	}
	
	if override_name != "":
		created.name = override_name                                  # over ride the name is given
		
	if definition.skills.size() > 0:              # append array of skill lists based on class type
		created["skills_list"].append_array(definition.skills)
	
	return created                                                   # return the created combatant


func add_combatant(combatant: Dictionary, side: int, _position: Vector2i):
	
	combatant["position"] = _position                                      # set the position given
	combatant["side"] = side                                         # set the player or enemy side
	combatants.append(combatant)                                       # append to combatants array
	groups[side].append(combatants.size() - 1)               # append to groups of the correct side
	
	var new_sprite = Sprite2D.new()
	new_sprite.position = Vector2(_position * 32) + Vector2(16, 16)      # sets relative sprite pos
	
	$"../../Background Tiles".add_child(new_sprite)             # sprite while being null, is still
													  # something we can move around to follow unit
	
	if side == 0:                                                               # side 0 is players
		var _usable_unit = _unit.instantiate()      # .unit is the scene that connects to tile move
		_usable_unit.position = Vector2(_position * 32)                 # set position by cell size
		_usable_unit.set_move_range(combatant.movement)                # set the move range of base
		_playergroup.add_child(_usable_unit)                               # add it to player group
	
	elif side == 1:                                                               # side 1 is enemy
		var _usable_unit = _unit.instantiate()      # .unit is the scene that connects to tile move 
		_usable_unit.position = Vector2(_position * 32)                 # set position by cell size
		_usable_unit.set_move_range(combatant.movement)                # set the move range of base
		_enemygroup.add_child(_usable_unit)                                 # add it to enemy group
	
	else:
		combatant["initiative"] -= 1                                # change initiative for sorting
	
	combatant["sprite"] = new_sprite
	
	turn_queue.append(combatants.size() - 1)                   # append size to the turn queue list
	turn_queue.sort_custom(sort_turn_queue)                      # sort based on initiative numbers
	
	emit_signal("combatant_added", combatant)       # emit signal that the combatant has been added


func sort_turn_queue(a, b):                          # simple sorting of initiative for combat turn
	
	if combatants[b].initiative < combatants[a].initiative:
		return true
	else:
		return false

func get_current_combatant():                                     # retrieves the current combatant
	return combatants[current_combatant]

func get_distance(attacker: Dictionary, target: Dictionary):         # get the dist between 2 cells
	var point1 = attacker.position
	var point2 = target.position
	return absi(point1.x - point2.x) + absi(point1.y - point2.y)      # return the absolute integer

func attack_melee(attacker: Dictionary, target: Dictionary, skill: String): # resolves melee attack
	attack(attacker, target, skill)

func attack_ranged(attacker: Dictionary, target: Dictionary, skill: String):# resolves range attack
	attack(attacker, target, skill)

func attack_magic(attacker: Dictionary, target: Dictionary, skill: String): # resolves magic attack
	var skill_data = SkillData.skills[skill]
	do_damage(attacker, target, skill_data)                             # don't need to check range
	advance_turn()                                                      # advance turn after attack

func attack(attacker: Dictionary, target: Dictionary, _attack: String):
	var distance = get_distance(attacker, target)                              # check the distance
	var skill = SkillData.skills[_attack]                                         # check the skill
	var valid = distance <= skill.max_range and distance >= skill.min_range# check its within range
	
	if valid:
		var prob = calc_skill_hitchance(skill, distance)               # calculate the skill chance
		var random_number = randi() % 100                                # grab a randomized number
		
		if random_number < prob:                           # if the random number beats probability
			do_damage(attacker, target, skill)                                          # do damage
		
		else:                                                                                # miss
			update_information.emit("[center][color=white] {0} has missed their attack on {1}. \n\n".format(
				[attacker.name, 
				target.name])
				)
		
		if groups[Group.Enemies].size() < 1:            # if theres no enemies left, combat is done
			combat_finish()                # call this to end combat and queue free combat elements
		
		advance_turn()                                                     # advance turn otherwise
	
	else:
		update_information.emit("[center][color=white] Target is too far away. \n\n")
		
		if attacker.side == 1:                                             # if its the enemys turn
			advance_turn()                                         # advance the turn after resolve

func set_next_combatant():
	turn += 1                                                               # update the turn value
	if turn >= turn_queue.size():                          # if turn is bigger than turn queue size
		for combamount in combatants:                  # set all the combatants turns back to false
			combamount.turn_taken = false
		turn = 0                                                        # turn is now set back to 0
	current_combatant = turn_queue[turn]                             # update the current combatant

func advance_turn():
	combatants[current_combatant].turn_taken = true                        # set turn taken to true
	set_next_combatant()                                                   # set the next combatant
	while !combatants[current_combatant].alive:              # while the current combatant is alive
		set_next_combatant()                                               # set the next combatant
	var comb = combatants[current_combatant]
	emit_signal("turn_advance", comb)                     # advance the turn with current combatant
	emit_signal("update_combatants", combatants)                            # update the combatants
	
	if comb.side == 1:                                               # if the turn side is an enemy
		await get_tree().create_timer(1).timeout                    # timeout for a second of delay
		ai_process(comb)                                                         # process enemy ai

func combat_finish():
	emit_signal("combat_finished")                        # send the signal that combat is finished
	pass

func do_damage(_attacker: Dictionary, target: Dictionary, skill: skillDefinitions):
	var damage = randi_range(skill.min_damage, skill.max_damage)# random number between min and max
	target.hp -= damage                                                # take damage from target hp
	update_combatants.emit(combatants)                                           # update combatant
	update_information.emit("[center][color=white] Damage Taken by {0} for [color=red] {1}. [/color] \n\n".format([target.name, damage]))
	
	if target.hp <= 0:                                                     # if the target has 0 hp
		combatant_goes_down(target)                                     # call combat down function

func combatant_goes_down(combatant: Dictionary):
	var comb_id = combatants.find(combatant)                                   # find the combatant
	
	if comb_id != -1:                                                  # if the combat id is not -1
		combatant.alive = false                                                 # they are now down
		groups[combatant.side].erase(comb_id)                    # erase combatant from their group
		update_information.emit("[center][color=white] {0} is down. \n\n".format([combatant.name]))
	combatant_down.emit(combatant)                                     # emit the combatant is down

func calc_skill_hitchance(skill: skillDefinitions, distance: int) -> int:
	var min_range = skill.min_range
	var max_range = skill.max_range
	
	if distance > max_range:                  # if they are above max range, return max probability
		return skill.max_prob
	
	if distance < min_range:                  # if they are below min range, return min probability
		return skill.min_prob
	
	if distance <= max_range and distance >= min_range:          # check distance and return values
		return 90 - 10 * (distance - 1)
	return 0                                                        # return 0 if nothing works out

func calc_prob(_attack: String, distance: int):
	if _attack == "melee" or _attack == "magic":        # if attack is melee or magic, return value
		return 90 - 10 * (distance - 1)
	
	if _attack == "ranged":                    # if attack is ranged, return specificed probability
		return 25 if distance == 1 or distance == 5 else 90



																						 # enemy AI
func sort_weight_array(a, b):
	if a[0] > b[0]:                                                               # sort val weight
		return true
	else:
		return false

func ai_process(comb : Dictionary):
	var nearest_target: Dictionary                                                # set val nearest
	
	if comb.class == UnitClass.Melee:                                   # if the combatant is melee
		var l = INF
		
		for target_comb_index in groups[Group.Players]:           # target combatant index in group
			var target = combatants[target_comb_index]         # target is based on combatant index
			var distance = get_distance(comb, target)   # get the distance between enemy and target
			
			if distance < l:
				l = distance
				nearest_target = target
					# this would be where we would have enemy attacks based on skills and distances
		if get_distance(comb, nearest_target) == 1:   # get the distance to check if in melee range
			attack(comb, nearest_target, "Meleeattack")      # attack with melee (spelling matters)
			return                                                                    # then return
			
	await _gameboard.ai_process(nearest_target.position)                # else wait for ai progress
	attack(comb, nearest_target, "Meleeattack")                                        # and attack


func ai_pick_target(weights):
	var rand_num = randf()                                                   # grab a random number
	var full_weight = 1.0
	for w in weights:                                                      # for variables in array
		var weight = w[0]                                               #  make var weight on array
		full_weight -= weight                                   # reduce total weight by var weight
		
		if rand_num > full_weight - 0.001:             #full_weight - 0.001 due to float inaccuracy
			return w[1]                              # if rand num is greater, return array point 1
