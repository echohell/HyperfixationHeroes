extends Node2D

class_name Combat

signal update_information(text: String)
signal register_combat_start(combat_node: Node)
signal turn_advance(combatant: Dictionary)
signal combatant_added(combatant: Dictionary)
signal combatant_down(combatant: Dictionary)
signal update_turn_queue(combatants: Array, turn_queue: Array)
signal update_combatants(combatants: Array)
signal combat_finished()

enum Group{Players, Enemies}
enum UnitClass{Melee, Ranged, Magic}

var groups = [[], []]                    #players first, enemies second
var combatants = []
var current_combatant = 0
var turn = 0
var turn_queue = []

@export var combat_UI: Control
@export var controller: GameBoard

var skills_list = [["attack_melee"], ["attack_ranged"], ["attack_magic"]]     #basic attack


func _ready():
	emit_signal("register_combat_start", self)
	randomize()
	
	add_combatant(create_combatant(CombatantData.combatants["Player"], "Player"), 0, Vector2i(3,3))
	add_combatant(create_combatant(CombatantData.combatants["Player"], "Enemy"), 1, Vector2i(6,3))


func create_combatant(definition: CombatantDefinition, override_name = ""):
	
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
		"turn_taken" = false
	}
	
	if override_name != "":
		created.name = override_name
		
	if definition.skills.size() > 0:
		created["skills_list"].append_array(definition.skills)
	
	return created


func add_combatant(combatant: Dictionary, side: int, _position: Vector2i):
	
	combatant["position"] = _position
	combatant["side"] = side
	combatants.append(combatant)
	groups[side].append(combatants.size() - 1)
	
	var new_combatant_sprite = Sprite2D.new()
	new_combatant_sprite.texture = combatant.map_sprite
	$"../../Background Tiles".add_child(new_combatant_sprite)
	new_combatant_sprite.position = Vector2(_position * 32) + Vector2(16,0)
	new_combatant_sprite.z_index = 1
	
	if side == 0:
		new_combatant_sprite.flip_h = false
	
	elif side == 1:
		new_combatant_sprite.flip_h = true
	
	else:
		combatant["initiative"] -= 1
	
	combatant["sprite"] = new_combatant_sprite
	
	turn_queue.append(combatants.size() - 1)
	turn_queue.sort_custom(sort_turn_queue)
	
	emit_signal("combatant_added", combatant)


func sort_turn_queue(a, b):
	
	if combatants[b].initiative < combatants[a].initiative:
		return true
	else:
		return false

func get_current_combatant():
	return combatants[current_combatant]

func get_distance(attacker: Dictionary, target: Dictionary):
	var point1 = attacker.position
	var point2 = target.position
	return absi(point1.x - point2.x) + absi(point1.y - point2.y)

func attack_melee(attacker: Dictionary, target: Dictionary):
	attack(attacker, target, "attack_melee")

func attack_ranged(attacker: Dictionary, target: Dictionary):
	attack(attacker, target, "attack_ranged")

func attack_magic(attacker: Dictionary, target: Dictionary):
	attack(attacker, target, "attack_magic")
	var skill = SkillData.skills["attack_magic"]
	do_damage(attacker, target, skill)
	advance_turn()

func attack(attacker: Dictionary, target: Dictionary, _attack: String):
	var distance = get_distance(attacker, target)
	var skill = SkillData.skills[_attack]
	var valid = distance <= skill.max_range and distance >= skill.min_range
	
	if valid:
		var prob = calc_skill_hitchance(skill, distance)
		var random_number = randi() % 100
		
		if random_number < prob:
			do_damage(attacker, target, skill)
		
		else:
			update_information.emit("Missed. \n\n")
		
		if groups[Group.Enemies].size() < 1:
			combat_finish()
		
		advance_turn()

func set_next_combatant():
	turn += 1
	if turn >= turn_queue.size():
		for combamount in combatants:
			combamount.turn_taken = false
		turn = 0
	current_combatant = turn_queue[turn]

func advance_turn():
	combatants[current_combatant].turn_taken = true
	set_next_combatant()
	
	while !combatants[current_combatant].alive:
		set_next_combatant()
	var comb = combatants[current_combatant]
	emit_signal("turn_advance", comb)
	emit_signal("update_combatants", combatants)
	
	if comb.side == 1:
		await get_tree().create_timer(1).timeout
		ai_process(comb)

func combat_finish():
	emit_signal("combat_finished")
	pass

func do_damage(_attacker: Dictionary, target: Dictionary, skill: skillDefinitions):
	var damage = randi_range(skill.min_damage, skill.max_damage)
	target.hp -= damage
	update_combatants.emit(combatants)
	update_information.emit("Damage Taken by {0} for {1}. \n\n".format([target.name, damage]))
	
	if target.hp <= 0:
		combatant_goes_down(target)

func combatant_goes_down(combatant: Dictionary):
	var comb_id = combatants.find(combatant)
	
	if comb_id != -1:
		combatant.alive = false
		groups[combatant.side].erase(comb_id)
		update_information.emit("{0} is down. \n\n".format([combatant.name]))
		combatant_down.emit(combatant)

func calc_skill_hitchance(skill: skillDefinitions, distance: int) -> int:
	var min_range = skill.min_range
	var max_range = skill.max_range
	
	if distance > max_range:
		return skill.max_prob
	
	if distance < min_range:
		return skill.min_prob
	
	if distance <= max_range and distance >= min_range:
		return 90 - 10 * (distance - 1)
	return 0

func calc_prob(_attack: String, distance: int):
	if _attack == "melee" or _attack == "magic":
		return 90 - 10 * (distance - 1)
	
	if _attack == "ranged":
		return 25 if distance == 1 or distance == 5 else 90

																	# enemy AI
func sort_weight_array(a, b):
	if a[0] > b[0]:
		return true
	else:
		return false

func ai_process(comb : Dictionary):
	var nearest_target: Dictionary
	
	if comb.class == UnitClass.Melee:
		var l = INF
		
		for target_comb_index in groups[Group.Players]:
			var target = combatants[target_comb_index]
			var distance = get_distance(comb, target)
			
			if distance < l:
				l = distance
				nearest_target = target
				print(nearest_target.name)
		
		if get_distance(comb, nearest_target) == 1:
			attack(comb, nearest_target, "attack_melee")
			return
			
	await controller.ai_process(nearest_target.position)
	attack(comb, nearest_target, "attack_melee")


func ai_pick_target(weights):
	var rand_num = randf()
	var full_weight = 1.0
	for w in weights:
		var weight = w[0]
		full_weight -= weight
		
		if rand_num > full_weight - 0.001:             #full_weight - 0.001 due to float inaccuracy
			return w[1]
