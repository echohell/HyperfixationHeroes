extends PanelContainer

func set_icon(_texture: Texture2D):
	$Player.texture = _texture                                            # set player icon texture

func set_health(hp: int, _hp_max: int):
	$Player/ProgressBG/PlayerHP.value = hp * 10                     # set player progress bar value
