extends Node2D

class_name Pile

# Signals are only sent while the pile is not blocked (so user provoked, shifting
# pieces programatically will not throw a signal)
signal _piece_grabbed
signal _piece_released
signal _piece_taken
signal _piece_placed
signal _pile_clicked
signal _pile_doubleClicked
signal _pile_emptied
signal _shuffle_over

export var cardPosAnimationLength = 0.5

export var maxCardSeparation = Vector2(0, -5)
export var size = Vector2(50, 50)
export var disableSorting = false

export var overrideColliderSize = Vector2(0, 0)
export var useOverrideColliderOffset = false
export var overrideColliderOffset = Vector2(0, 0)
export var perPieceCollider = false

export var pieceSet = "StandardCards"
export var tilesetName = "StandardDeckv2"
export var color = Color.white
export var pileIcon = 0

var pieces = []

func _ready(): # Ready is not overridable
	GameController.pieceGfx.set_pile(self)
	connect("ready", self, "_on_ready")

func _on_ready():
	pass

func shuffle():
	pieces.shuffle()
	for piece in pieces:
		remove_child(piece)
		add_child(piece) # Re-add children so that their tree order reflects list
	sort_pieces()
	yield($Tween, "tween_all_completed")
	emit_signal("_shuffle_over")

func blocked():
	return GameController.currentGameMaster.isPileBlocked(self)

func add_piece(piece):
	pieces.append(piece)
	var gp
	if piece.is_inside_tree():
		gp = piece.global_position # Relativise position to this node
		piece.get_parent().remove_child(piece)
	add_child(piece)
	if gp != null:
		piece.global_position = gp
	piece.set_owner(self)
	piece.emit_signal("_on_piece_taken", piece)
	piece.connect("_on_piece_taken", self, "_on_piece_taken")
	piece.connect("_on_piece_grabbed", self, "_on_piece_grabbed")
	sort_pieces()
	
	if not blocked():
		emit_signal("_piece_placed", self)

func add_pieces(newPieces):
	for piece in newPieces:
		pieces.append(piece)
		var gp
		if piece.is_inside_tree():
			gp = piece.global_position # Relativise position to this node
			piece.get_parent().remove_child(piece)
		add_child(piece)
		if gp != null:
			piece.global_position = gp
		piece.set_owner(self)
		piece.emit_signal("_on_piece_taken", piece)
		piece.connect("_on_piece_taken", self, "_on_piece_taken")
		piece.connect("_on_piece_grabbed", self, "_on_piece_grabbed")
	sort_pieces()
	
	if not blocked():
		emit_signal("_piece_placed", self)

func add_piece_instantaneous(piece):
	pieces.append(piece)
	if piece.is_inside_tree():
		piece.get_parent().remove_child(piece)
	add_child(piece)
	piece.set_owner(self)
	piece.emit_signal("_on_piece_taken", piece)
	piece.connect("_on_piece_taken", self, "_on_piece_taken")
	piece.connect("_on_piece_grabbed", self, "_on_piece_grabbed")
	piece.position = get_next_piece_position()
	
	# add_piece_istantaneous can only be called programatically so no need to check
	#if not blocked():
	#	emit_signal("_piece_placed")
	return

func _on_piece_taken(piece):
	remove_piece(piece)
	sort_pieces()
	
	if not blocked():
		emit_signal("_piece_taken", self)

func _on_piece_grabbed(piece):
	$Tween.remove(piece, "position")
	
	if not blocked():
		emit_signal("_piece_grabbed")

func get_next_piece_position():
	var separation = maxCardSeparation
	
	if abs(size.x/len(pieces)) < abs(maxCardSeparation.x):
		separation.x = size.x/len(pieces)
	if abs(size.y/len(pieces)) < abs(maxCardSeparation.y):
		separation.y = size.y/len(pieces)
	
	return separation * len(pieces)

func remove_piece(piece):
	pieces.erase(piece)
	piece.disconnect("_on_piece_taken", self, "_on_piece_taken")
	piece.disconnect("_on_piece_grabbed", self, "_on_piece_grabbed")
	sort_pieces()
	
	if not blocked() and len(pieces) == 0:
		emit_signal("_pile_emptied")

func sort_pieces():
	if disableSorting:
		return
	$Tween.stop_all()
	if len(pieces) == 0:
		return
	var separation = maxCardSeparation
	
	if abs(size.x/len(pieces)) < abs(maxCardSeparation.x):
		separation.x = size.x/len(pieces)
	if abs(size.y/len(pieces)) < abs(maxCardSeparation.y):
		separation.y = size.y/len(pieces)
	
	for i in len(pieces):
		var p = separation * i
		$Tween.interpolate_property(pieces[i], "position", pieces[i].position,
			p, cardPosAnimationLength, Tween.TRANS_BACK, Tween.EASE_OUT)
	$Tween.start()

func top():
	return pieces[-1]

func isEmpty():
	return len(pieces) == 0

func positionInPile(piece):
	if not piece in pieces:
		return -1
	
	return pieces.find(piece)

func _on_Area2D_input_event(viewport, event, shape_idx):
	if blocked():
		return
	if event is InputEventMouseButton:
		if event.pressed:
			emit_signal("_pile_clicked", self)
		if event.doubleclick:
			emit_signal("_pile_doubleClicked", self)

func get_texture_path():
	return pieceSet + "/" + tilesetName
