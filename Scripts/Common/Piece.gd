extends Node2D

class_name Piece

signal _on_piece_grabbed(piece)
signal _on_piece_taken(piece)

onready var sprite = $Sprite/Sprite

export var pieceSet = "StandardCards"
export var tilesetName = "StandardDeckv2"

export var faceUp = true
export var suit : int = 0
export var value : int = 0

export var backIX : int = 1

func _ready():
	update_sprite()

func init(suit, value, cardBack = 1, faceUp = true, pieceSet = "StandardCards", tilesetName = "StandardDeckv2"):
	self.suit = suit
	self.value = value
	self.backIX = cardBack
	self.faceUp = faceUp
	self.pieceSet = pieceSet
	self.tilesetName = tilesetName
	GameController.pieceGfx.set_piece(self)

func update_sprite():
	if faceUp:
		sprite.frame_coords = Vector2(value, suit)
	else:
		sprite.frame_coords = Vector2(backIX, 0)

func flip(customSpeed = 1):
	$Animator.stop()
	faceUp = !faceUp
	$Animator.play("Turn", -1, abs(customSpeed), customSpeed<0)

func get_pile():
	return get_parent()

func get_texture_path():
	return pieceSet + "/" + tilesetName
