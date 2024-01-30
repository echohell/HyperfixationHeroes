extends Panel

@onready var item_image: Sprite2D = $CenterContainer/Panel/ItemImage
@onready var amount_text: Label = $CenterContainer/Panel/Label

func update(slot: InventorySlotValue):
	if !slot.item:
		item_image.visible = false
		amount_text.visible = false
	else:
		item_image.visible = true
		item_image.texture = slot.item.texture
		if slot.amount > 1:
			amount_text.visible = true
			amount_text.text = str(slot.amount)
