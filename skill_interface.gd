extends Control

var description: String = "BRUH"

func _on_fire_1_pressed():
	description = str("Burn the target with a small ball of fire")
	update_description(description)

func _on_fire_2_pressed():
	description = str("A medium ball of fire scorches the enemy")
	update_description(description)

func _on_fire_3_pressed():
	description = str("Trogdor Mode Engaged")
	update_description(description)

func update_description(description):
	$SkillWindow/ColorRect2/Description.text = str(description)
