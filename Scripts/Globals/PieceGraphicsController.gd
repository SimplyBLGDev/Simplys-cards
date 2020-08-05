extends Node

const setsPath = "res://PieceSets/"
const deckSizeDic = { # Cards unit dimensions by set
	"StandardCards":Vector2(38, 63),
	"SpanishCards":Vector2(148, 232)
}
const deckFrameDic = { # Amount of Tiles in each set
	"StandardCards":Vector2(17, 5),
	"SpanishCards":Vector2(12, 5)
}

var allocatedMaterials = {}

func get_texture(texturePath):
	if not texturePath in allocatedMaterials.keys():
		allocatedMaterials[texturePath] = ResourceLoader.load(setsPath + texturePath + ".png")
	
	return allocatedMaterials[texturePath]

func set_piece(piece):
	var tileSet = piece.pieceSet
	var sprite = piece.get_node("Sprite/Sprite")
	sprite.texture = get_texture(piece.get_texture_path())
	sprite.hframes = deckFrameDic[tileSet].x
	sprite.vframes = deckFrameDic[tileSet].y
	
	sprite.scale = deckSizeDic[tileSet] / (sprite.texture.get_size() / deckFrameDic[tileSet])
