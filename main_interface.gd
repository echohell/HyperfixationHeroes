extends Control

class_name UIElement

var is_open = false

func _on_stats_pressed():
	$StatsPane.visible = !$StatsPane.visible
	$SkillPane.visible = !$SkillPane.visible
	
func _on_menu_button_pressed():
	if is_open:
		close()
		is_open = false
	else:
		is_open = true
		$StatsPane.visible = true
		$SkillPane.visible = false
		$Toggle.visible = !$Toggle.visible
	
func close():
	$StatsPane.visible = false
	$SkillPane.visible = false
	$Toggle.visible = false

	
