extends TextureRect

@export var _animplayer: AnimationPlayer
@onready var inittext = $ColorRect/RichTextLabel
@onready var wavetext = $RichTextLabel

func set_side(side: int):                                      # this is for UI of turn queue icons
	match side:                                                  # sets side colors based on 0 or 1
		0:
			$Border.modulate = Color.LIGHT_SKY_BLUE                        # players get light blue
		1:
			$Border.modulate = Color.CRIMSON                              # enemies get crimson red

func set_text(text: String):
	turn_on_AV()
	wavetext.clear()
	inittext.clear()
	inittext.add_text(text)

func set_wave_text(text: String):
	turn_off_AV()
	wavetext.clear()
	wavetext.set_text("[center] " + text)

func turn_taken(_taken: bool):
	pass #_animplayer.play("reset")        #fadeout         # fade out animation when turn is taken   
													  # this breaks TQIcon for some fucking reason.

func reset():
	_animplayer.play("reset")

func turn_on_AV():
	$ColorRect.visible = true
	
func turn_off_AV():
	$ColorRect.visible = false
