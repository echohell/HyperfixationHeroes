extends Control

class_name UIHolder

func _on_game_board_update_information(info: String):
	var information = $CombatInfo/Text.bbcode_text("[color=white]info[/color]")
	$CombatInfo/Text.append_text(information)
