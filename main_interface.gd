extends Control

class_name UIElement

func _on_skills_pressed():
	$SkillPane.visible = !$SkillPane.visible
	$StatsPane.visible = false

func _on_stats_pressed():
	$StatsPane.visible = !$StatsPane.visible
	$SkillPane.visible = false
