extends CharacterBody2D

class_name Player

@export var inventory: Inventory = preload("res://Inventory/PlayerInventory.tres")
@export var moveSpeed : float = 300

func _ready():
	resize(1,1)                 #test for resizing individual child nodes

func _physics_process(_delta):
	var inputDir = Vector2(
	Input.get_action_strength("right") - Input.get_action_strength("left"), 
	Input.get_action_strength("down") - Input.get_action_strength("up")
	)
	
	velocity = inputDir * moveSpeed
	move_and_slide()

func resize(x,y):
	get_node("Sprite2D").scale *= Vector2(x, y)               #test to pull node from parent to child

func collect(item):
	inventory.insert(item)
