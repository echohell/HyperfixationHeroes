extends RichTextLabel

func _on_game_board_update_information(info: String):
	$".".append_text(info)
