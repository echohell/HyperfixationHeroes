extends Node2D

signal sendbgtile()
const gameboard = preload("res://game_board.tscn")

func _on_button_pressed():
	var gameboard = gameboard.instantiate()
	$"..".add_child(gameboard)
	
	var bgtiles = get_node("../Background Tiles")
	$"..".remove_child(bgtiles)
	gameboard.add_child(bgtiles)
	
	var map = get_node("../Map")
	$"..".remove_child(map)
	gameboard.add_child(map)
	gameboard.move_child(bgtiles, 0)
	gameboard.move_child(map, 1)
	
	var combat = gameboard.get_node("CombatProcessing")
	combat.begin_combat()
	
	var blocktiles = gameboard.get_node("BlockedTiles")
	blocktiles.confirmtileblock()
	
	gameboard._reinitialize()
