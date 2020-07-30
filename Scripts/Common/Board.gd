extends Node2D

export var cellPrefab = preload("res://Prefabs/BoardSquare.tscn")
export var gridSize = Vector2(5, 5)
export var cellSize = Vector2(32, 32)

var grid = []

func _ready():
	grid = []
	for x in gridSize.x:
		grid.append([])
		for y in gridSize.y:
			var cell = cellPrefab.instance()
			cell.name = "Cell" + str(x) + str(y)
			add_child(cell)
			cell.position = Vector2(x, y) * cellSize
			cell.coords = Vector2(x, y)
			grid[x].append([])
			grid[x][y] = cell

func _exists_collision(cells):
	for cell in cells:
		if len(grid[cell.x][cell.y].cards) > 0:
			return true
	
	return false
