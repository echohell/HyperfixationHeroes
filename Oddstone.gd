extends StaticBody2D

@export var item: inventoryItem
@export var player: Player;


func _on_interaction_zone_body_entered(body):
	if body.has_method("collect"):
		player = body
		player.collect(item)
		await get_tree().create_timer(0.1).timeout
		self.queue_free()
