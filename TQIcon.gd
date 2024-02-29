extends TextureRect

@onready var _animplayer: AnimationPlayer = $AnimationPlayer

func set_side(side: int):
	match side:
		0:
			$Border.modulate = Color.DEEP_SKY_BLUE
		1:
			$Border.modulate = Color.CRIMSON

func turn_taken():
	_animplayer.play("fadeout")
