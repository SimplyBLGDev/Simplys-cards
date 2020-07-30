tool
extends Polygon2D

class_name SmoothSprite

export var hframes = 1 setget hFrameSet
export var vframes = 1 setget vFrameSet

export var frame_coords = Vector2(0, 0) setget frameCoordSet

func frameCoordSet(value):
	frame_coords = value
	refresh_shape()

func hFrameSet(value):
	hframes = value
	refresh_shape()

func vFrameSet(value):
	vframes = value
	refresh_shape()

func refresh_shape():
	if texture == null:
		return
	var ts = texture.get_size() / Vector2(hframes, vframes)
	var hts = ts/2
	var nPolygons = PoolVector2Array()
	var nUVs = PoolVector2Array()
	
	nPolygons.append(Vector2(-hts.x, -hts.y))
	nPolygons.append(Vector2(hts.x, -hts.y))
	nPolygons.append(Vector2(hts.x, hts.y))
	nPolygons.append(Vector2(-hts.x, hts.y))
	
	nUVs.append(ts * frame_coords)
	nUVs.append(ts * Vector2(frame_coords.x + 1, frame_coords.y))
	nUVs.append(ts * Vector2(frame_coords.x + 1, frame_coords.y + 1))
	nUVs.append(ts * Vector2(frame_coords.x, frame_coords.y + 1))
	
	set_polygon(nPolygons)
	set_uv(nUVs)
