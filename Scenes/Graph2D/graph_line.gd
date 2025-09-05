extends Line2D
class_name  Graph2DLine

var point_values:Array = []

signal changed(node)

func Redraw(rescaling:Vector2) -> void:
	for i in range(get_point_count()):
		prints("line move point from ", get_point_position(i), "to", get_point_position(i) * rescaling)
		set_point_position(i, get_point_position(i) * rescaling)
		

func GetXCoords() -> Array:
	return point_values.map(func(v): return v.x)
func GetYCoords() -> Array:
	return point_values.map(func(v): return v.y)

func GetMinimums() -> Vector2:
	return Vector2(GetXCoords().min(), GetYCoords().min())
func GetMaximums() -> Vector2:
	return Vector2(GetXCoords().max(), GetYCoords().max())

func GetPointValue(index:int) -> Vector2:
	return point_values[index]

func SetPointValue(index:int, new_value:Vector2) -> void:
	point_values[index] = new_value
	changed.emit(self)


func AddPoint(pos: Vector2, value: Vector2, index: int = -1) -> void:
	add_point(pos, index)
	if index < 0:
		index += get_point_count()
	point_values.insert(index, value)
	changed.emit(self)

func RemovePoint(index: int = -1) -> void:
	if index < 0:
		index += get_point_count()
	remove_point(index)
	point_values.remove_at(index)
	changed.emit(self)
