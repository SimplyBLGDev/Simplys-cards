extends Game

const boardPieces = {
	Vector2(0, 2):0,
	Vector2(1, 2):0,
	Vector2(2, 2):0,
	Vector2(3, 2):0,
	Vector2(4, 2):0,
	Vector2(5, 2):0,
	Vector2(6, 2):0,
	Vector2(7, 2):0,
	Vector2(8, 2):0,
	Vector2(1, 1):5,
	Vector2(7, 1):6,
	Vector2(0, 0):1,
	Vector2(1, 0):2,
	Vector2(2, 0):3,
	Vector2(3, 0):4,
	Vector2(4, 0):7,
	Vector2(5, 0):4,
	Vector2(6, 0):3,
	Vector2(7, 0):2,
	Vector2(8, 0):1,
}

var teamTurn = 0
var board
var capturePiles = []
var shogiPiecePrefab

func setupGame():
	shogiPiecePrefab = load("res://Prefabs/GameSpecific/ShogiPiece.tscn")
	board = $BoardController.grid
	capturePiles.append($Captures0)
	capturePiles.append($Captures1)
	
	deal()

func _is_piece_grabbable(piece):
	if piece.team != GameController.teamId or GameController.teamId != teamTurn:
		#return false
		return true # DEBUG
	
	return true

func _are_pieces_placeable(pieces, pile):
	var originPile = pieces[0].get_pile()
	
	if pile == originPile or pile in capturePiles:
		return false
	
	if originPile in capturePiles and len(pile.cards) == 0:
		return true
	
	if pieces[0].value in [1, 5, 6]: # Long-moving pieces
		if is_cell_legal(pieces[0], pile, originPile):
			var checkCoords = []
			
			var p = originPile.coords
			var end = pile.coords
			var direction = end - p
			
			direction.x = clamp(direction.x, -1, 1)
			direction.y = clamp(direction.y, -1, 1)
			end -= direction # Exclude final cell
			while p != end:
				p += direction
				checkCoords.append(p)
				
			if $BoardController._exists_collision(checkCoords):
				return false
		else:
			return false
	else:
		if not is_cell_legal(pieces[0], pile, originPile):
			return false
	
	# All checks clear, movement legal, check target piece
	if len(pile.cards) > 0 and pile.cards[0].team == pieces[0].team:
			return false
	
	return true

func _piece_dependencies(piece):
	return [piece]

func is_cell_legal(piece, pile, originPile):
	
	# Gold or promoted pieces that move like gold
	if piece.value == 4 or (piece.suit == 1 and piece.value in [0, 1, 2, 3]):
		var dif = (originPile.coords - pile.coords)
		if piece.team == 1:
			dif *= -1
		return (dif in
			[Vector2(1, 1), Vector2(0, 1), Vector2(-1, 1),
			Vector2(1, 0), Vector2(-1, 0), Vector2(0, -1)])
	
	match piece.value:
		0:
			if pile.coords.x == originPile.coords.x:
				if piece.team == 0:
					return originPile.coords.y == pile.coords.y+1
				else:
					return originPile.coords.y == pile.coords.y-1
		1:
			if pile.coords.x == originPile.coords.x:
				if piece.team == 0:
					return originPile.coords.y > pile.coords.y
				else:
					return originPile.coords.y < pile.coords.y
		2:
			if abs(originPile.coords.x - pile.coords.x) == 1:
				if piece.team == 0:
					return originPile.coords.y - pile.coords.y == 2
				else:
					return originPile.coords.y - pile.coords.y == -2
		3:
			var dif = (originPile.coords - pile.coords)
			if piece.team == 1:
				dif *= -1
			return (dif in
				[Vector2(1, 1), Vector2(0, 1), Vector2(-1, 1),
				Vector2(1, -1), Vector2(-1, -1)])
		5:
			var dif = (originPile.coords - pile.coords)
			return dif.x == dif.y or -dif.x == dif.y
		6:
			return originPile.coords.x == pile.coords.x or originPile.coords.y == pile.coords.y
		7:
			var dif = (originPile.coords - pile.coords)
			return abs(dif.x) <= 1 and abs(dif.y) <= 1
	
	return false

func _on_piece_placed(pile):
	if pile in capturePiles:
		return
	if len(pile.cards) == 2:
		# Capture Piece
		if pile.cards[0].team == 0:
			pile.cards[0].team = 1
		else:
			pile.cards[0].team = 0
		
		pile.cards[0].update_sprite()
		
		capturePiles[pile.cards[0].team].add_piece(pile.cards[0])

func deal():
	for team in [0, 1]:
		for pos in boardPieces.keys():
			var piece = shogiPiecePrefab.instance()
			var posX = 8 - pos.x
			var posY = pos.y
			if team == 0:
				posX = pos.x
				posY = 8 - pos.y
			piece.team = team
			piece.suit = 0
			piece.value = boardPieces[pos]
			board[posX][posY].add_piece(piece)
