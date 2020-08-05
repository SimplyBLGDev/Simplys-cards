extends Node2D

class_name DeckGenerator # Generates card objects from a suit/number list as
						# children of this object's parent

export var individualCards = PoolVector2Array() # (Suit, Value)
export (Array, int) var suits
export (Array, int) var values
export var faceUp = false
export var pieceSet = "StandardCards"
export var tileset = "StandardDeckv2"
export var backIx = 1

export var cardobj = preload("res://Prefabs/Piece.tscn")

func init(group = ""):
	var p = get_parent()
	
	var cards = PoolVector2Array() # Vector2s (suit, value)
	for s in suits:
		for v in values:
			cards.append(Vector2(s, v))
	
	for i in individualCards:
		cards.append(Vector2(i.x, i.y))
	
	var pCPAL = p.cardPosAnimationLength
	p.cardPosAnimationLength = 0
	for card in cards:
		var instance = cardobj.instance()
		instance.name = "Card " + str(card.x) + "-" + str(card.y)
		instance.init(card.x, card.y, backIx, faceUp, pieceSet, tileset)
		if group != "":
			instance.add_to_group(group)
		p.add_piece(instance)
	p.cardPosAnimationLength = pCPAL
	
	queue_free()
