extends Control
class_name Graph2D


@export var line_colors:Array = []
@export var line_legends:Array[String] = []

@export var graph_size:Vector2 = Vector2(343, 343) ##In pixels
@export var graph_origin:Vector2 = Vector2(50, graph_size.y - 50) ## In pixels

@export var reverse_y_axis:bool = true

@export var axis_min:Vector2:
	get():
		return PositionToCoords(Vector2(0, graph_size.y))
@export var axis_max:Vector2:
	get():
		return PositionToCoords(Vector2(graph_size.x, 0))
		
@export var axes_scaling:Vector2 = Vector2.ONE:
	set(new_scaling):
		_SetScaling(axes_scaling, new_scaling)
		axes_scaling = new_scaling
@export var show_ticks:bool = true


var default_line_colors:Array[Color] = ['RED', 'GREEN', 'BLUE', 'CYAN', 'ORANGE', 'GOLD', 'TEAL', 'PURPLE']
var nb_lines:int = 0

func Initialize(lines:Array = [], legend:Array=[], x_min=null, x_max=null, y_min=null, y_max=null):
	#%Xaxis.add_point(Vector2(0, graph_origin.y))
	##%Xaxis.add_point(CoordsToPosition(Vector2(graph_size.x, 0)))
	#%Xaxis.add_point(Vector2(graph_size.x, graph_origin.y))
	##%Yaxis.add_point(CoordsToPosition(Vector2.ZERO))
	#%Yaxis.add_point(Vector2(graph_origin.x, 0))
	##%Yaxis.add_point(CoordsToPosition(Vector2(0, graph_size.y)))
	#%Yaxis.add_point(Vector2(graph_origin.x, graph_size.y))
	
	%Axes.position = graph_origin
	
	%XAxis.Setup(Vector2.RIGHT, graph_origin.x, -20, 343, graph_size.x)
	%YAxis.Setup(Vector2.UP,    graph_size.y - graph_origin.y, -20, 343, graph_size.y)
	%XAxis.SetupTicks(10, 10)
	%YAxis.SetupTicks(10, 10)
	
	
	SetAxisLimits(x_min, x_max, y_min, y_max)
	
	#AddAxisTicks("x")
	#AddAxisTicks("y")
	
	#print(%Xaxis.points)
	#print(%Yaxis.points)
	#print(CoordsToPosition(Vector2.ZERO))
	#print(PositionToCoords(graph_origin))
	
	if not lines:
		return
	
	if legend.size() < lines.size():
		legend.resize(lines.size())

	for i in lines.size():
		AddLine(lines[i], legend[i])
	
	GetGraphLimits()


func EraseTicks():
	for c in $Axes/XaxisTicks.get_children():
		c.queue_free()
	for c in $Axes/YaxisTicks.get_children():
		c.queue_free()
		
func AddAxisTicks(axis_name:String, nb_ticks:int=10, tick_size:int = 10):
	var axis:Line2D = %Xaxis
	var ticks_node:Control = $Axes/XaxisTicks
	var axis_size:int = int(graph_size.x)
	if axis_name[0].to_lower() == "y":
		axis = %Yaxis
		ticks_node = $Axes/YaxisTicks
		axis_size = int(graph_size.y)
	
	var axis_direction:Vector2 = (PositionToCoords(axis.get_point_position(1)) - PositionToCoords(axis.get_point_position(0))).normalized()
	var axis_perp:Vector2 = axis_direction.rotated(PI/2).normalized()
	
	var new_tick_line:Line2D
	for i in range(1, nb_ticks+1):
		new_tick_line = Line2D.new()
		new_tick_line.width = 1
		new_tick_line.default_color = Color(1, 1, 1)
		new_tick_line.add_point(CoordsToPosition(axis_direction * i * axis_size/nb_ticks + axis_perp * tick_size/2))
		new_tick_line.add_point(CoordsToPosition(axis_direction * i * axis_size/nb_ticks - axis_perp * tick_size/2))
		ticks_node.add_child(new_tick_line)

func AddLine(points:Array, _legend:String="", width:int = 2, color:Color=Color(0,0,0,0)):
	
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
		#prints("adding line ", p, CoordsToPosition(p))
	%Lines.add_child(new_line)
	nb_lines += 1

func CoordsToPosition(point_coord:Vector2, scaling=null):
	"""Transform a point coordinates (in the reference frame of the graph) to its position (in the ref frame of the Line2D node)"""
	if scaling == null:
		scaling = axes_scaling
	if reverse_y_axis:
		point_coord.y *= -1
	var point_pos = point_coord * scaling + graph_origin
	#prints("coords to pos", graph_origin, scaling, point_coord, point_pos)
	return point_pos

func PositionToCoords(point_pos:Vector2, scaling=null):
	"""Transform a point position (in the ref frame of the Line2D node) to its coordinates (in the reference frame of the graph)"""
	if scaling == null:
		scaling = axes_scaling
	var point_coords = (point_pos - graph_origin) / scaling
	if reverse_y_axis:
		point_coords.y *= -1
	#prints("pos to coords ", graph_origin, scaling, point_pos, point_coords)
	return point_coords 

func CheckLineExists(line_id:int) -> bool:
	if line_id >= 0 and line_id < %Lines.get_child_count():
		return true
	push_error("Incorrect Line id ({0}): Graph {1} has {2} lines".format([line_id, self, nb_lines]))
	return false

func AddPointToLine(line:int, point:Vector2, adapt_scaling:bool = true):
	#prints("adding point at coords ", point)
	CheckLineExists(line)
	#print("line exists")
	%Lines.get_child(line).add_point(CoordsToPosition(point))
	#print(CoordsToPosition(point))
	if adapt_scaling:
		#print("adapting scaling")
		AdaptScalingToLines()

func ChangePointFromLine(line:int, new_position:Vector2, point_id:int = -1, adapt_scaling:bool = true):
	CheckLineExists(line)
	%Lines.get_child(line).set_point_position(point_id, CoordsToPosition(new_position))
	if adapt_scaling:
		AdaptScalingToLines()

func RemovePointFromLine(line:int, point_id:int = -1, adapt_scaling:bool = true):
	CheckLineExists(line)
	if point_id < 0:
		point_id += %Lines.get_child(line).get_point_count()
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
	#prints("line_limits", line_id, Vector2(min_x, min_y), Vector2(max_x, max_y))
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
	
	#prints("graph_limits", Vector2(graph_min_x, graph_min_y), Vector2(graph_max_x, graph_max_y))
	return [Vector2(graph_min_x, graph_min_y), Vector2(graph_max_x, graph_max_y)]

func SetAxisLimits(x_min=null, x_max=null, y_min=null, y_max=null):
	if x_min == null: x_min = PositionToCoords(Vector2(0, 0)).x
	if x_max == null: x_max = PositionToCoords(Vector2(graph_size.x, 0)).x
	if y_min == null: y_min = PositionToCoords(Vector2(0, 0)).y
	if y_max == null: y_max = PositionToCoords(Vector2(0, graph_size.y)).y
	
	SetScalingFromLimits([Vector2(x_min, y_min), Vector2(x_max, y_max)])
	
func SetScalingFromLimits(bounding_limits:Array, adapt_x_axis:bool = true, adapt_y_axis:bool = true):
	
	var bounding_size:Vector2 = Vector2(bounding_limits[1].x - bounding_limits[0].x, bounding_limits[1].y - bounding_limits[0].y)
	#prints("bounding_size", bounding_size)
	
	if adapt_x_axis and bounding_size.x != 0:
		axes_scaling.x = (graph_size.x) / bounding_size.x
		#prints("adapting bounding size X", axes_scaling.x)
	if adapt_y_axis and bounding_size.y != 0:
		axes_scaling.y = (graph_size.y) / bounding_size.y
		#prints("adapting bounding size y", axes_scaling.y)

func AdaptScalingToLines(adapt_x_axis:bool = true, adapt_y_axis:bool = true):
	var bounding_limits:Array = GetGraphLimits() # In graph corrdinates
	#prints("bounding_limits", bounding_limits)
	SetScalingFromLimits(bounding_limits, adapt_x_axis, adapt_y_axis)
		
		
func _SetScaling(old_scaling:Vector2, new_scaling:Vector2):
	for line in %Lines.get_children():
		for i in range(line.get_point_count()):
			var point_coords:Vector2 = PositionToCoords(line.get_point_position(i), old_scaling)
			line.set_point_position(i, CoordsToPosition(point_coords, new_scaling))

func Clean():
	for l in %Lines.get_children():
		l.queue_free()
	nb_lines = 0
	line_colors = []
	line_legends = []
