tool
extends Polygon2D

class_name SlopedPolygon

export var centerV = true setget setCenterV
export var centerH = true setget setCenterH
export var slope = 5 setget setSlope
export var size = Vector2(20, 10) setget setSize

func setSlope(value):
	slope = value
	updatePolygon()

func setSize(value):
	size = value
	updatePolygon()

func setCenterV(value):
	centerV = value
	updatePolygon()

func setCenterH(value):
	centerH = value
	updatePolygon()

func updatePolygon():
	var newPolys = PoolVector2Array()
	var hSize = size / 2
	
	newPolys.append(Vector2(-hSize.x + slope, -hSize.y))
	newPolys.append(Vector2(-hSize.x, hSize.y))
	newPolys.append(Vector2(hSize.x - slope, hSize.y))
	newPolys.append(Vector2(hSize.x, -hSize.y))
	
	polygon = newPolys
