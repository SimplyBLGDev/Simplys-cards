tool
extends Node2D

signal GameClicked(name)

export var displayName = "Game :)" setget setDisplayName

func setDisplayName(value):
	displayName = value
	$Control/Label.bbcode_text = "[center]" + displayName + "[/center]"

func _on_Area2D2_input_event(_viewport, event, _shape_idx):
	emit_signal("GameClicked", event, displayName)
