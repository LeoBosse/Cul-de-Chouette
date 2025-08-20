extends Control
class_name Graph2D


@export var line_colors:Array = []
@export var line_legends:Array[String] = []

@export var graph_size:Vector2 = Vector2(343, 343)
@export var graph_origin:Vector2 = Vector2(0, graph_size.y)

@export var reverse_y_axis:bool = true
@export var axes_scaling:Vector2 = Vector2.ONE:
	set(new_scaling):
		_SetScaling(new_scaling)
		axes_scaling = new_scaling

var default_line_colors:Array[Color] = ['RED', 'GREEN', 'BLUE', 'CYAN', 'ORANGE', 'GOLD', 'TEAL', 'PURPLE']
var nb_lines:int = 0

func Initialize(lines:Array = [], legend:Array=[]):
	%Xaxis.add_point(CoordsToPosition(Vector2.ZERO))
	%Xaxis.add_point(CoordsToPosition(Vector2(graph_size.x, 0)))
	%Yaxis.add_point(CoordsToPosition(Vector2.ZERO))
	%Yaxis.add_point(CoordsToPosition(Vector2(0, graph_size.y)))
	
	print(%Xaxis.points)
	print(%Yaxis.points)
	print(CoordsToPosition(Vector2.ZERO))
	print(PositionToCoords(graph_origin))
	
	if not lines:
		return
	
	if legend.size() < lines.size():
		legend.resize(lines.size())

	for i in lines.size():
		AddLine(lines[i], legend[i])
	
	GetGraphLimits()


func AddLine(points:Array, legend:String="", width:int = 2, color:Color=Color(0,0,0,0)):
	
	var new_line:Line2D = Line2D.new()
	new_line.width = width
	if color.a == 0:
		line_colors.append(Color(default_line_colors[nb_lines % len(default_line_colors)]))
		new_line.default_color = line_colors[-1]
	else:
		new_line.default_color = color
		line_colors.append(color)
	for p in points:
		new_line.add_point(CoordsToPosition(p))
	%Lines.add_child(new_line)
	nb_lines += 1

func CoordsToPosition(point_coord:Vector2):
	"""Transform a point coordinates (in the reference frame of the graph) to its position (in the ref frame of the Line2D node)"""
	if reverse_y_axis:
		point_coord.y *= -1
	point_coord += graph_origin
	return point_coord * axes_scaling

func PositionToCoords(point_pos:Vector2):
	"""Transform a point position (in the ref frame of the Line2D node) to its coordinates (in the reference frame of the graph)"""
	if reverse_y_axis:
		point_pos.y *= -1
	point_pos += graph_origin
	return point_pos / axes_scaling

func CheckLineExists(line_id:int) -> bool:
	if line_id >= 0 and line_id < %Lines.get_child_count():
		return true
	push_error("Incorrect Line id ({0}): Graph {1} has {2} lines".format([line_id, self, nb_lines]))
	return false

func AddPointToLine(line:int, point:Vector2, adapt_scaling:bool = true):
	CheckLineExists(line)
	
	%Lines.get_child(line).add_point(CoordsToPosition(point))
	if adapt_scaling:
		AdaptScalingToLines()

func ChangePointFromLine(line:int, new_position:Vector2, point_id:int = -1, adapt_scaling:bool = true):
	CheckLineExists(line)
	%Lines.get_child(line).set_point_position(point_id, CoordsToPosition(new_position))
	if adapt_scaling:
		AdaptScalingToLines()

func RemovePointFromLine(line:int, point_id:int = -1, adapt_scaling:bool = true):
	CheckLineExists(line)
	%Lines.get_child(line).remove_point(point_id)
	if adapt_scaling:
		AdaptScalingToLines()

func EraseLine(line:int, adapt_scaling:bool = true):
	CheckLineExists(line)
	%Lines.get_child(line).queue_free()
	line_legends.pop_at(line)
	line_colors.pop_at(line)

	nb_lines -= 1
	
	if adapt_scaling:
		AdaptScalingToLines()

func GetPointCoords(line_id:int, point_id:int) -> Vector2:
	return PositionToCoords(%Lines.get_child(line_id).get_point_position(point_id))
	
func GetLineCoords(line_id:int) -> Array:
	"""Return the coordinates of all the points of the line (in the ref frame of the graph axes)"""
	var coords:Array = []
	var line:Line2D = %Lines.get_child(line_id)
	coords.resize(line.get_point_count())
	for i in line.get_point_count():
		coords[i] = GetPointCoords(line_id, i)
	return coords
func GetLineXCoords(line_id:int) -> Array:
	var coords:Array = GetLineCoords(line_id)
	coords = coords.map(func(c):return c.x)
	return coords
func GetLineYCoords(line_id:int) -> Array:
	var coords:Array = GetLineCoords(line_id)
	coords = coords.map(func(c):return c.y)
	return coords

func GetLineLimits(line_id:int) -> Array:
	"""Return an array with two Vector2 for the position of the min corner and max corner of the minimum rectangle containing the line. (In graph coordinates)"""
	var min_x = GetLineXCoords(line_id).min()
	var max_x = GetLineXCoords(line_id).max()
	var min_y = GetLineYCoords(line_id).min()
	var max_y = GetLineYCoords(line_id).max()
	prints("line_limits", line_id, Vector2(min_x, min_y), Vector2(max_x, max_y))
	return [Vector2(min_x, min_y), Vector2(max_x, max_y)]

func GetGraphLimits() -> Array:
	"""Return an array with two Vector2 for the position of the min corner and max corner of the minimum rectangle containing all the lines of graph line. (In graph coordinates)"""
	var limits:Array = []
	for i in range(nb_lines):
		limits.append(GetLineLimits(i))
	var graph_min_x = limits.map(func(v): return v[0].x).min()
	var graph_max_x = limits.map(func(v): return v[1].x).max()
	var graph_min_y = limits.map(func(v): return v[0].y).min()
	var graph_max_y = limits.map(func(v): return v[1].y).max()
	
	prints("graph_limits", Vector2(graph_min_x, graph_min_y), Vector2(graph_max_x, graph_max_y))
	return [Vector2(graph_min_x, graph_min_y), Vector2(graph_max_x, graph_max_y)]

func AdaptScalingToLines(adapt_x_axis:bool = true, adapt_y_axis:bool = true):
	var bounding_limits:Array = GetGraphLimits()
	prints("bounding_limits", bounding_limits)
	var bounding_size:Vector2 = Vector2(bounding_limits[1].x - bounding_limits[0].x, bounding_limits[1].y - bounding_limits[0].y)
	prints("bounding_size", bounding_size)
	
	var new_scaling:Vector2 = Vector2.ONE
	
	new_scaling = graph_size / bounding_size
	prints("new_scaling", new_scaling)
	
	if adapt_x_axis:
		axes_scaling.x = new_scaling.x
	if adapt_y_axis:
		axes_scaling.y = new_scaling.y
		
		
func _SetScaling(new_scaling:Vector2):
	var scale_multiplier:Vector2 = new_scaling / axes_scaling
	for line in %Lines.get_children():
		for i in range(line.get_point_count()):
			line.set_point_position(i, line.get_point_position(i) * scale_multiplier)

func Clean():
	for l in %Lines.get_children():
		l.queue_free()
	nb_lines = 0
	line_colors = []
	line_legends = []
