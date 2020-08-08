## Generates a collisionshape for every placeable piece for precision areas

extends Pile

func _ready():
	generate_per_piece_collider()

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
