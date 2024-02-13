extends Node2D


var enemies: Array = []

func _ready():
	enemies = get_children()

