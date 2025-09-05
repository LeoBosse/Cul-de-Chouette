extends Control
class_name Graph2D


@export var line_colors:Array = []
@export var line_legends:Array[String] = []

@export var graph_size:Vector2 = Vector2(343, 343) ##In pixels
@export var graph_origin:Vector2 = Vector2(50, graph_size.y - 50): ## In pixels
	set(new_origin):
		graph_origin = new_origin
		%Axes.position = graph_origin
		%Lines.position = graph_origin

@export var reverse_y_axis:bool = true
@export var auto_adapt_x_axis:bool = true
@export var auto_adapt_y_axis:bool = true

#@export var axis_min:Vector2:
	#get():
		#return PositionToCoords(Vector2(0, graph_size.y))
#@export var axis_max:Vector2:
	#get():
		#return PositionToCoords(Vector2(graph_size.x, 0))
		
@export var axes_scaling:Vector2 = Vector2.ONE:
	set(new_scaling):
		SetScaling(new_scaling.x, new_scaling.y)
	get():
		return Vector2(%XAxis.scaling, %YAxis.scaling)
		
@export var show_ticks:bool = true


var default_line_colors:Array[Color] = ['RED', 'GREEN', 'BLUE', 'CYAN', 'ORANGE', 'GOLD', 'TEAL', 'PURPLE']
var nb_lines:int = 0

func Initialize(lines:Array = [], legend:Array=[], x_min=null, x_max=null, y_min=null, y_max=null):
	"""Initialize the graph.
	lines:Array[Array[Vector2]] = [] : Array of arrays containing the coordonates of the points on each line.
	legend:Array=[] : Array of Strings with the line legends.
	x_min=null, x_max=null, y_min=null, y_max=null : min and max values (coordinates) of the axes.
	"""
	
	%Axes.position = graph_origin
	%Lines.position = graph_origin
	
	%XAxis.Setup(Vector2.RIGHT, graph_origin.x, -20, 343, graph_size.x)
	%YAxis.Setup(Vector2.UP,    graph_size.y - graph_origin.y, -20, 343, graph_size.y)
	
	
	SetAxisLimits(x_min, x_max, y_min, y_max)
	
	if not lines:
		return
	
	if legend.size() < lines.size():
		legend.resize(lines.size())

	for i in lines.size():
		AddLine(lines[i], legend[i])
	
	GetGraphLimits()


#region AXES METHODS

func CoordsToPosition(point_coord:Vector2, scaling=null):
	"""Transform a point values (in the reference frame of the graph) to its position (in the ref frame of the Line node)"""
	if scaling == null:
		scaling = axes_scaling

	var point_pos:Vector2 = %XAxis.GetPointPosition(point_coord.x) + %YAxis.GetPointPosition(point_coord.y)
	
	#prints("coords to pos", graph_origin, scaling, point_coord, point_pos)
	return point_pos

func PositionToCoords(point_pos:Vector2, scaling=null):
	"""Transform a point position (in the ref frame of the Line node) to its coordinates  (values in the reference frame of the graph)"""
	if scaling == null:
		scaling = axes_scaling
	var point_coords:Vector2 = Vector2(%XAxis.GetPointCoords(point_pos), %YAxis.GetPointCoords(point_pos))
	#prints("pos to coords ", graph_origin, scaling, point_pos, point_coords)
	return point_coords 

#endregion

#region LINES METHODS

func AddLine(points:Array, _legend:String="", width:int = 2, color:Color=Color(0,0,0,0)):
	"""Add a line to the graph.
	points:Array : Array of the line points
	_legend:String="" :  
	width:int = 2, 
	color:Color=Color(0,0,0,0)
	"""
	var new_line:Graph2DLine = Graph2DLine.new()
	new_line.width = width
	if color.a == 0:
		line_colors.append(Color(default_line_colors[nb_lines % len(default_line_colors)]))
		new_line.default_color = line_colors[-1]
	else:
		new_line.default_color = color
		line_colors.append(color)
	for p in points:
		new_line.AddPoint(CoordsToPosition(p), p)
		#prints("adding line ", p, CoordsToPosition(p))
	new_line.changed.connect(_on_line_changed.bind(%Lines.get_child_count()))
	%Lines.add_child(new_line)
	nb_lines += 1

func _on_line_changed(_line:Graph2DLine, _line_id:int):
	AdaptScalingToLines()

func CheckLineExists(line_id:int) -> bool:
	"""Check if a line exists. Else, send an error"""
	if line_id >= 0 and line_id < %Lines.get_child_count():
		return true
	push_error("Incorrect Line id ({0}): Graph {1} has {2} lines".format([line_id, self, nb_lines]))
	return false

func AddPointToLine(line:int, point:Vector2, _adapt_scaling:bool = true):
	"""
	Add a point to a line.
	line:int  : line ID
	point:Vector2 : Value of the point
	adapt_scaling:bool = true
	"""
	CheckLineExists(line)
	%Lines.get_child(line).AddPoint(CoordsToPosition(point), point)
	#if adapt_scaling:
		#AdaptScalingToLines()

func GetLine(line_id:int) -> Graph2DLine:
	CheckLineExists(line_id)
	return %Lines.get_child(line_id)

func ChangePointFromLine(line:int, new_position:Vector2, point_id:int = -1, _adapt_scaling:bool = true):
	GetLine(line).set_point_position(point_id, CoordsToPosition(new_position))
	#if adapt_scaling:
		#AdaptScalingToLines()

func RemovePointFromLine(line:int, point_id:int = -1, _adapt_scaling:bool = true):
	GetLine(line).RemovePoint(point_id)
	#if adapt_scaling:
		#AdaptScalingToLines()

func EraseLine(line:int, _adapt_scaling:bool = true):
	CheckLineExists(line)
	%Lines.get_child(line).queue_free()
	line_legends.pop_at(line)
	line_colors.pop_at(line)

	nb_lines -= 1
	
	#if adapt_scaling:
		#AdaptScalingToLines()
		
func GetLineLimits(line_id:int) -> Array:
	"""Return an array with two Vector2 for the position of the min corner and max corner of the minimum rectangle containing the line. (In graph coordinates)"""
	var line:Graph2DLine = %Lines.get_child(line_id)
	#prints("line_limits", line_id, [line.GetMinimums(), line.GetMaximums()])
	return [line.GetMinimums(), line.GetMaximums()]

func GetPointCoords(line_id:int, point_id:int) -> Vector2:
	"""Return the value of a given point along the given line."""
	return %Lines.get_child(line_id).GetPointValue(point_id)
	
func GetLineCoords(line_id:int) -> Array:
	"""Return the coordinates of all the points of the line (in the ref frame of the graph axes)"""
	return %Lines.get_child(line_id).point_values
	
	
#endregion

#region SCALING AND LIMITS

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
	"""Set the axes limit values (min and max). In graph coordinates, not pixel positions."""
	if x_min == null: x_min = PositionToCoords(Vector2(0, 0)).x
	if x_max == null: x_max = PositionToCoords(Vector2(graph_size.x, 0)).x
	if y_min == null: y_min = PositionToCoords(Vector2(0, 0)).y
	if y_max == null: y_max = PositionToCoords(Vector2(0, graph_size.y)).y
	
	#prints("SetAxisLimits", Vector2(x_min, y_min), Vector2(x_max, y_max))
	
	SetScalingFromLimits([Vector2(x_min, y_min), Vector2(x_max, y_max)])
	
func SetScalingFromLimits(bounding_limits:Array, adapt_x_axis:bool = true, adapt_y_axis:bool = true):
	"""Finds the graph size and the limit values on the axes and set the axes scales so that the limits fit nicely in the graph."""
	var bounding_size:Vector2 = Vector2(bounding_limits[1].x - bounding_limits[0].x, bounding_limits[1].y - bounding_limits[0].y)
	#prints("bounding_size", bounding_size)
	
	if adapt_x_axis and bounding_size.x != 0:
		var new_scaling:float = bounding_size.x / graph_size.x ## pix to coords
		#prints("adapting bounding size X", new_scaling, axes_scaling.x, graph_size.x, bounding_size.x)
		SetScaling(new_scaling / axes_scaling.x , 1.)
	if adapt_y_axis and bounding_size.y != 0:
		var new_scaling:float = bounding_size.y / graph_size.y
		#prints("adapting bounding size y", new_scaling, axes_scaling.y, graph_size.y, bounding_size.y)
		SetScaling(1., new_scaling / axes_scaling.y)

func AdaptScalingToLines():
	"""Adapt the axes scale to the lines min and max values"""
	var bounding_limits:Array = GetGraphLimits() # In graph corrdinates
	#prints("bounding_limits", bounding_limits)
	SetScalingFromLimits(bounding_limits, auto_adapt_x_axis, auto_adapt_y_axis)
		
		
func SetScaling(x_rescaling:float = 1, y_rescaling:float = 1):
	"""Call this function to rescale the graph axes. The axes current scale will be multiplied by the given rescaling factors."""
	%XAxis.scaling = %XAxis.scaling * x_rescaling ## pix to coords
	%YAxis.scaling = %YAxis.scaling * y_rescaling ## pix to coords
	
	for line in %Lines.get_children():
		#prints("line redraw: ", Vector2(x_rescaling, y_rescaling))
		line.Redraw(Vector2(1. / x_rescaling, 1. / y_rescaling)) 
		
		#for i in range(line.get_point_count()):
			#var point_coords:Vector2 = line.GetPointValue(i)
			#line.set_point_position(i, CoordsToPosition(point_coords, new_scaling))

#endregion

func Clean():
	for l in %Lines.get_children():
		l.queue_free()
	nb_lines = 0
	line_colors = []
	line_legends = []
