extends Node

const setsPath = "res://PieceSets/"
const pilesPath = "res://Sprites/Piles/"
const pileIconsPath = "res://Sprites/Piles/icons/"

const pileColliderMargin = 0.125 # Ratio compared to normal size

## Pile 9 Patch texture = res://Sprites/Piles/[0].png
## 9 Patch texture margin = [1] (Left, top, right, bottom)
## Pile default margin (compared to piece) = [2]
## Pile icons addresses array [3]
const deckPileDic = {
	"StandardCards/StandardDeckv2":["PileMarker", Rect2(2, 2, 2, 2), Vector2(4, 4), ["SuitPileIcon"]],
	"SpanishCards/SpanishPlayingCards":["PileMarkerR", Rect2(8, 8, 8, 8), Vector2(10, 10), []]
}
const deckSizeDic = { # Cards unit dimensions by set
	"StandardCards":Vector2(40, 64), # While the cards are 32x63 even numbers work better for pixelated margins
	"SpanishCards":Vector2(148, 232)
}
const deckFrameDic = { # Amount of Tiles in each set
	"StandardCards":Vector2(17, 5),
	"SpanishCards":Vector2(12, 5)
}

var allocatedPile9Patchs = {}
var allocatedPileIcons = {}
var allocatedMaterials = {}
var allocatedCollisionShapes = {}

func get_texture(texturePath):
	if not texturePath in allocatedMaterials.keys():
		allocatedMaterials[texturePath] = ResourceLoader.load(setsPath + texturePath + ".png")
	
	return allocatedMaterials[texturePath]

func get_shape(size):
	if not size in allocatedCollisionShapes:
		allocatedCollisionShapes[size] = RectangleShape2D.new()
		allocatedCollisionShapes[size].extents = size/2;
	
	return allocatedCollisionShapes[size]

func get_9_patch_texture(texturePath):
	if not texturePath in allocatedPile9Patchs.keys():
		allocatedPile9Patchs[texturePath] = ResourceLoader.load(pilesPath + texturePath + ".png")
	
	return allocatedPile9Patchs[texturePath]

func get_pile_icon_texture(texturePath):
	if not texturePath in allocatedPileIcons.keys():
		allocatedPileIcons[texturePath] = ResourceLoader.load(pileIconsPath + texturePath + ".png")
	
	return allocatedPileIcons[texturePath]

func set_piece(piece):
	var tileSet = piece.pieceSet
	var sprite = piece.get_node("Sprite/Sprite")
	sprite.texture = get_texture(piece.get_texture_path())
	sprite.hframes = deckFrameDic[tileSet].x
	sprite.vframes = deckFrameDic[tileSet].y
	
	sprite.scale = deckSizeDic[tileSet] / (sprite.texture.get_size() / deckFrameDic[tileSet])
	piece.get_node("Area2D/CollisionShape").shape = get_shape(deckSizeDic[tileSet])

func set_pile(pile):
	set_pile_sprite(pile)
	
	if pile.perPieceCollider:
		set_pile_per_piece_collider(pile)
	else:
		set_pile_collider(pile)

func set_pile_sprite(pile):
	var patch = pile.get_node("Pile9Patch")
	var collider = pile.get_node("Area2D/CollisionShape")
	var dicResults = deckPileDic[pile.get_texture_path()]
	patch.texture = get_9_patch_texture(dicResults[0])
	patch.patch_margin_left = dicResults[1].position.x
	patch.patch_margin_top = dicResults[1].position.y
	patch.patch_margin_right = dicResults[1].size.x
	patch.patch_margin_bottom = dicResults[1].size.y
	
	var size = deckSizeDic[pile.pieceSet] + dicResults[2]
	
	patch.rect_position = -size/2
	patch.rect_size = size
	patch.self_modulate = pile.color
	
	if pile.pileIcon >= 0: # -1 is no icon other negatives are invalid
		pile.get_node("PileIcon").modulate = pile.color
		pile.get_node("PileIcon/Sprite").texture = get_pile_icon_texture(dicResults[3][pile.pileIcon])

## Both pile collider method are pretty messy, cleanup required
func set_pile_collider(pile):
	var dicResults = deckPileDic[pile.get_texture_path()]
	
	var colShape = pile.get_node("Area2D/CollisionShape")
	var colSize = pile.size + deckSizeDic[pile.pieceSet] + dicResults[2]
	var colOff = pile.size/2
	## Add collider margin, same margin in both directions regardless of aspect ratio
	colSize += Vector2(1, 1) * (max(deckSizeDic[pile.pieceSet].x, deckSizeDic[pile.pieceSet].y) * pileColliderMargin)
	
	if pile.overrideColliderSize != Vector2(0, 0):
		colSize = pile.overrideColliderSize
	if pile.useOverrideColliderOffset:
		colOff = pile.overrideColliderOffset
	
	colShape.shape = get_shape(colSize)
	colShape.position = colOff

func set_pile_per_piece_collider(pile):
	var dicResults = deckPileDic[pile.get_texture_path()]
	var colSize = deckSizeDic[pile.pieceSet] + dicResults[2]
	colSize += Vector2(1, 1) * (max(deckSizeDic[pile.pieceSet].x, deckSizeDic[pile.pieceSet].y) * pileColliderMargin)
	var shape = get_shape(colSize)
	pile.get_node("Area2D/CollisionShape").shape = shape
	
	var pos = pile.maxCardSeparation
	while abs(pos.x) < abs(pile.size.x) or abs(pos.y) < abs(pile.size.y):
		var newCol = CollisionShape2D.new()
		newCol.shape = shape
		pile.get_node("Area2D").add_child(newCol)
		newCol.position = pos
		pos += pile.maxCardSeparation
