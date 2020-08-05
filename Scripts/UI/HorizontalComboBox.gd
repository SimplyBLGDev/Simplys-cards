extends MarginContainer

export var options = {
	"Option1":1,
	"Option2":2,
	"Option3":3
}
export var currentIx = 0
export var wrapOptions = false

func _ready():
	updateUI()

func getSelectedValue():
	return options[options.keys()[currentIx]]

func updateUI():
	$Margin/HBox/Label/Label.text = options.keys()[currentIx]
	$Margin/HBox/LeftArrow/Center/LeftArrow.disabled = not wrapOptions and currentIx <= 0
	$Margin/HBox/RightArrow/Center/RightArrow.disabled = not wrapOptions and currentIx >= len(options) - 1

func _on_RightArrow_pressed():
	if currentIx >= len(options) and not wrapOptions or $AnimationPlayer.is_playing():
		return
	currentIx += 1
	if currentIx >= len(options):
		currentIx = 0
	$AnimationPlayer.play("UI_HorizontalComboBox_Right")

func _on_LeftArrow_pressed():
	if currentIx < 0 and not wrapOptions or $AnimationPlayer.is_playing():
		return
	currentIx -= 1
	if currentIx < 0:
		currentIx = len(options) - 1
	$AnimationPlayer.play("UI_HorizontalComboBox_Left")
