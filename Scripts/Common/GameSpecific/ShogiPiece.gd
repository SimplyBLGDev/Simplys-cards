extends Piece

const pieceSizes = {
	0:Vector2(10.5, 13),
	1:Vector2(11, 13.5),
	2:Vector2(11.75, 13.75),
	3:Vector2(12.75, 14),
	4:Vector2(12.75, 14),
	5:Vector2(13, 14.5),
	6:Vector2(13, 14.5),
	7:Vector2(14, 15.5)
}

var owner_id = 0
export var team = 0

func _update_sprite():
	if team == 1:
		$Sprite.rotation_degrees = 180
	else:
		$Sprite.rotation_degrees = 0
	$Sprite.frame_coords.x = value
	if value == 7 and team == 0:
		$Sprite.frame_coords.y = 1 # Non-Champion's King
	else:
		$Sprite.frame_coords.y = suit
	
	$Sprite/Perspective.scale = pieceSizes[value] / pieceSizes[0] # The default polygons have a pawn's dimensions
	$Sprite/Front.scale = pieceSizes[value] / pieceSizes[0]
