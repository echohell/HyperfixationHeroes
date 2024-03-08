extends Control

@export var combat: Combat
@export var gameboard: GameBoard

signal turn_ended()                                                          # sends signal from UI

const TQIcon = preload("res://TQIcon.tscn")                                   # const var for icons
const StatusIcon = preload("res://PlayerStatus.tscn")                        # const var for status

func add_turn_queue_icon(combatant: Dictionary):
	var new_icon = TQIcon.instantiate()                             # adds turn queue icons to hbox
	$TurnQueue/Queue.add_child(new_icon)                               # add as child to hbox queue
	new_icon.texture = combatant.icon                                                # set the icon
	new_icon.name = combatant.name                                                   # set the name
	new_icon.set_side(combatant.side)                                        # set the side (color)


func _on_combat_processing_update_turn_queue(combatants: Array, turn_queue: Array):
	for i in turn_queue:                                              # for variables in turn queue
		var comb = combatants[i]                                  # set var comb in combatant array
		add_turn_queue_icon(comb)                                       # call turn queue icon func


func _on_combat_processing_combatant_down(combatant):
	var turn_queue_icon = $TurnQueue/Queue.find_child(combatant.name, false, false) # find the icon
	if turn_queue_icon != null:                                           # if its not already null
		turn_queue_icon.queue_free()                                         # remove it from scene


func _on_combat_processing_combatant_added(combatant: Dictionary):
	if combatant.side == 0:                                                       # if its a player
		var new_status = StatusIcon.instantiate()                                   # update status
		$StatusHolder.add_child(new_status)                                  # add to status holder
		new_status.set_icon(combatant.icon)                                          # set the icon
		new_status.set_health(combatant.hp, combatant.max_hp)                  # set the health bar
		if combatant.hp <= 0:
			combatant.hp = 0
		new_status.name = combatant.name                                             # set the name

func _on_combat_processing_turn_advance(combatant: Dictionary):           # Status main / del later
	set_skill_list(combatant.skills_list)                                     # sets the skill list

func _on_end_turn_button_pressed():
	turn_ended.emit()                                                    # send signal turn is done


func _on_combat_processing_update_information(info: String):
	$CombatInfo/Text.append_text(info)                             # update information to text box

func _on_game_board_update_information(info: String):
	$CombatInfo/Text.append_text(info)                             # update information to text box


func set_skill_list(skill_list: Array):                                            # set skill list
	var single_action = $"../ActionButtons/HolderPanel/VBoxContainer".get_child(0)
	var actions_grid_children = $"../ActionButtons/HolderPanel/VBoxContainer/Special/ActionContainer".get_children()
	var player_turn = gameboard._player_turn
	
	var skill_one = skill_list[0]                   # single action / button refers to basic attack
	var skill_button = SkillData.skills[skill_one]
	
	single_action.text = "Basic ATK"
	single_action.icon = skill_button.icon
	single_action.tooltip_text = str(
				"Skill: ",skill_button.name, 
				"\n Minimum Damage: ", skill_button.min_damage,
				"\n Maximum Damage: ", skill_button.max_damage,
				"\n Hit Chance: ", skill_button.min_hitchance, "% - ", skill_button.max_hitchance, "%"
				)
				
	single_action.pressed.connect(func():
				gameboard.set_selected_skill(skill_button.skill_base, skill_one)
				gameboard.begin_target_selection()
				)
											   # this is where basic attack ends and special starts
	
	for i in range(actions_grid_children.size()):                 # for the size of action grid (4)
		var actions = actions_grid_children[i] as Button    # set the var of the actions as buttons
		
		if player_turn == false:                     # if its not the players turn, disable buttons
			actions.disabled = true                  # right now this is just a failsafe, not setup
			continue
		
		else:
			actions.disabled = false                   # they can press buttons when its their turn
		
		if skill_list.size() > i:
			var skill_key = skill_list[i + 1]          # this line specifically skips the first var
			var skill = SkillData.skills[skill_key]   # it then reads the skill of the key for data
			actions.visible = true
			actions.text = skill.name
			actions.icon = skill.icon
			actions.tooltip_text = str(
				"Skill: ",skill.name, 
				"\n Minimum Damage: ", skill.min_damage,
				"\n Maximum Damage: ", skill.max_damage,
				"\n Hit Chance: ", skill.min_hitchance, "% - ", skill.max_hitchance, "%"
				)
			
			actions.pressed.connect(func():                 # this is where instantiated buttons go
				gameboard.set_selected_skill(skill.skill_base, skill_key)
				gameboard.begin_target_selection()  # set skill and begin target selection on press
				)
		
		else:                 # if no more skills can be assigned, just turns off any extra buttons
			actions.visible = false
			actions.text = ""
			actions.icon = null
			actions.tooltip_text = ""
			clear_action_buttons(actions)


func clear_action_buttons(action: Button):
	var connections = action.pressed.get_connections()                            # get the buttons
	for connection in connections:
		action.press.disconnect(connection.callable)                       # disconnect the buttons

func _on_combat_processing_update_combatants(combatants: Array):
	for combatant in combatants:                                          # for combatants in array
		if combatant.side == 0:                                                   # if its a player
			var status = $StatusHolder.find_child(combatant.name, false, false)   # find the status
			if status != null:
				status.set_health(combatant.hp, combatant.max_hp)                  # set the health
				if combatant.hp <= 0:
					combatant.hp = 0
		var turn_queue_icon = $TurnQueue/Queue.find_child(combatant.name, false, false) # get child
		if turn_queue_icon != null:
			turn_queue_icon.set_side(combatant.side)                                 # set the side
			turn_queue_icon.turn_taken(combatant.turn_taken)                       # set turn taken


func _on_special_toggled(toggled_on: bool):                              # toggles special on / off
	if toggled_on == true:
		$"../ActionButtons/HolderPanel/VBoxContainer/Special/ActionContainer".visible = true
	elif toggled_on == false:
		$"../ActionButtons/HolderPanel/VBoxContainer/Special/ActionContainer".visible = false
