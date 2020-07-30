extends Node2D

class_name Piece

signal _on_piece_grabbed(piece)
signal _on_piece_taken(piece)

const deckFrameDic = {"Cards/StandardDeckv2":Vector2(17, 5)}
const tilesetsPath = "res://Sprites/Tilesets/"

export var tilesetName = "Cards/StandardDeckv2"

export var faceUp = true
export var suit = 0
export var value = 0

export var backIX = 1

func _ready():
	update_sprite()

func init(suit, value, cardBack = 1, faceUp = true, tilesetName = "Cards/StandardDeckv2"):
	self.suit = suit
	self.value = value
	self.backIX = cardBack
	self.faceUp = faceUp
	self.tilesetName = tilesetName
	$Sprite.texture = $Sprite.texture.duplicate(true)
	#$Sprite.texture.resource_path = "res://Sprites/Tilesets/" + tilesetName + ".png"

func update_sprite():
	$Sprite.texture = load(tilesetsPath + tilesetName + ".png")
	$Sprite.hframes = deckFrameDic[tilesetName].x
	$Sprite.vframes = deckFrameDic[tilesetName].y
	
	if faceUp:
		$Sprite.frame_coords = Vector2(value, suit)
	else:
		$Sprite.frame_coords = Vector2(backIX, 0)

func flip(customSpeed = 1):
	$Animator.stop()
	faceUp = !faceUp
	$Animator.play("Turn", -1, abs(customSpeed), customSpeed<0)

func get_pile():
	return get_parent()
