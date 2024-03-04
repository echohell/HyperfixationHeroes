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
	var turn_queue_icon = $TurnQueue/Queue.find_child(combatant.name, false, false) # finc the icon
	if turn_queue_icon != null:                                           # if its not already null
		turn_queue_icon.queue_free()                                         # remove it from scene

func _on_combat_processing_combatant_added(combatant: Dictionary):
	if combatant.side == 0:                                                       # if its a player
		var new_status = StatusIcon.instantiate()                                   # update status
		$StatusHolder.add_child(new_status)                                  # add to status holder
		new_status.set_icon(combatant.icon)                                          # set the icon
		new_status.set_health(combatant.hp, combatant.max_hp)                  # set the health bar
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
	var actions_grid_children = $"../ActionButtons/HolderPanel/VBoxContainer/Special".get_children()
	pass
	
	# FINISH THIS
	# FINISH THIS
	# FINISH THIS
	# FINISH THIS
	# FINISH THIS
	# FINISH THIS


func clear_action_buttons(action: Button):
	var connections = action.pressed.get_connections()                            # get the buttons
	for connection in connections:
		action.press.disconnect(connection.callable)                       # disconnect the buttons

func _on_combat_processing_update_combatants(combatants: Dictionary):
	for combatant in combatants:                                          # for combatants in array
		if combatant.side == 0:                                                   # if its a player
			var status = StatusIcon.find_child(combatant.name, false, false)      # find the status
			if status != null:
				status.set_health(combatant.hp, combatant.max_hp)                  # set the health
			var turn_queue_icon = $TurnQueue/Queue.get_node(combatant.name)         # get turn icon
			if turn_queue_icon != null:
				turn_queue_icon.set_side(combatant.side)                             # set the side
				turn_queue_icon.set_turn_taken(combatant.turn_taken)               # set turn taken
