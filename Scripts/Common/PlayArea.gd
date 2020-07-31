extends ReferenceRect

class_name PlayArea

func _ready():
	GameController.set_zoom(self.get_rect())
	self.visible = false
