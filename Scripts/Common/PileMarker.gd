tool
extends Node2D

enum PileMarkers { None, Standard, SuitPile }

func _ready():
	var pileMarker = get_parent().pileMarker
	
	match pileMarker:
		PileMarkers.Standard:
			add_child(
				load("res://Prefabs/Cosmetic/PileSprite.tscn").instance())
		PileMarkers.SuitPile:
			add_child(
				load("res://Prefabs/Cosmetic/PileSpriteSuitMarker.tscn").instance())
