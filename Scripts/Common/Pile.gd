extends Node2D

class_name Pile

signal _piece_grabbed
signal _piece_released
signal _piece_taken
signal _piece_placed
signal _pile_clicked
signal _pile_doubleClicked
signal _pile_emptied
signal _shuffle_over

enum ForceCardFace { DISABLED, FORCE_UP, FORCE_DOWN}

export var cardPosAnimationLength = 0.5

export var maxCardSeparation = Vector2(0, -5)
export var forceCardFace = ForceCardFace.DISABLED
export var size = Vector2(50, 50)
export var disableSorting = false

export var perPieceCollider = false
export var overrideColliderSize = Vector2(0, 0)
export var useOverrideColliderOffset = false
export var overrideColliderOffset = Vector2(0, 0)

var pieces = []

func _ready():
	var colSize = Vector2(size.x/2 + 24, size.y/2 + 38)
	var colOff = size/2
	if perPieceCollider:
		return generate_per_piece_collider()
	if overrideColliderSize != Vector2(0, 0):
		colSize = overrideColliderSize
	if useOverrideColliderOffset:
		colOff = overrideColliderOffset
	
	$Area2D/CollisionShape2D.shape = $Area2D/CollisionShape2D.shape.duplicate()
	$Area2D/CollisionShape2D.shape.extents = colSize
	$Area2D/CollisionShape2D.position = colOff

func shuffle():
	pieces.shuffle()
	for piece in pieces:
		remove_child(piece)
		add_child(piece) # Re-add children so that their tree order reflects list
	sort_pieces()
	yield($Tween, "tween_all_completed")
	emit_signal("_shuffle_over")

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
	
	emit_signal("_piece_placed")

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
	
	if len(pieces) == 0:
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

func _on_piece_taken(piece):
	remove_piece(piece)
	sort_pieces()
	emit_signal("_piece_taken", self)

func _on_piece_grabbed(piece):
	$Tween.remove(piece, "position")
	emit_signal("_piece_grabbed")

func generate_per_piece_collider():
	var pos = maxCardSeparation
	while abs(pos.x) < abs(size.x) or abs(pos.y) < abs(size.y):
		var newCol = CollisionShape2D.new()
		var shape = RectangleShape2D.new()
		var colSize = Vector2(20, 34) # Card size + margin
		shape.extents = colSize
		newCol.shape = shape
		$Area2D.add_child(newCol)
		newCol.position = pos
		pos += maxCardSeparation

func _on_Area2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.pressed:
			emit_signal("_pile_clicked", self)
		if event.doubleclick:
			emit_signal("_pile_doubleClicked", self)
