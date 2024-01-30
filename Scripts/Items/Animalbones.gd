extends CharacterBody2D

@export var item: inventoryItem
var player = null


func _ready():
	pass


func _process(_delta):
	for index in get_slide_collision_count():
		var collision := get_slide_collision(index)
		var body := collision.get_collider()
		print("Collided with: ", body.name)
		if (body.name == "Player"): player.collect(item)
