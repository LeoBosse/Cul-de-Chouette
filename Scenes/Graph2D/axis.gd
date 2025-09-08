extends Line2D
class_name GraphAxis2D

@export var show_ticks:bool = true:
	set(new_value):
		show_ticks = new_value
		$Ticks.visible = show_ticks

var direction:Vector2:
	set(new_dir):
		direction = new_dir.normalized()

var origin_pos:float = 0

var limits:Array = [0, 1]
var pos_limits:Array = [Vector2.ZERO, Vector2.RIGHT]

var value_range:float:
	get():
		return limits[1] - limits[0]
		
var length:float:
	get():
		return (pos_limits[1] - pos_limits[0]).length()

var pix_to_unit:float = 1.:
	set(new_value):
		pix_to_unit = new_value
		if is_node_ready():
			SetTicks("auto", 0, 10, 50)
		
var unit_to_pix:float:
	get():
		return 1. / pix_to_unit
	set(new_value):
		pix_to_unit = 1. / new_value
		unit_to_pix = new_value
		
var scaling:float:
	set(new_value):
		pix_to_unit = new_value
		scaling = new_value
	get():
		return pix_to_unit


var main_tick_values:Array = []
var secondary_tick_values:Array = []

func Setup(dir:Vector2, origin:float, min_value:float, max_value:float, graph_size:float):
	"""
	dir:Vector2, : direction of the axis
	origin:float, : position of the origin along that axis (== position of the Axis Node)
	min_value:int, : minimum value of the axis (in graph coordinates)
	max_value:int, : maximum value of the axis (in graph coordinates)
	graph_size:int : size of the axis in pixel from the min_value to the max_value."""
	
	direction = dir
	origin_pos = origin
	
	limits = [min_value, max_value]
	
	pix_to_unit = (limits[1] - limits[0]) / graph_size
	
	pos_limits = [GetPointPosition(limits[0]), GetPointPosition(limits[1])]
	
	prints("limits", pix_to_unit, limits, pos_limits)
	
	width = 2
	default_color = Color(1, 1, 1)
	
	clear_points()
	add_point(pos_limits[0])
	add_point(pos_limits[1])
	
	prints(limits, pos_limits)
	prints(pix_to_unit)
	
	SetTicks("auto", 0, 10, 50)

func SetLimits(min_value:float, max_value:float, min_pos:Vector2 = Vector2.ZERO, max_pos:Vector2 = Vector2.ZERO):
	if min_pos == Vector2.ZERO:
		min_pos = get_point_position(0)
	if max_pos == Vector2.ZERO:
		max_pos = get_point_position(1)
	
	limits = [min_value, max_value]
	pos_limits = [min_pos, max_pos]
	
	pix_to_unit = (limits[1] - limits[0]) / length
	
	set_point_position(0, direction * min_pos)
	set_point_position(1, direction * max_pos)
	
	
	
	

func SetTicks(mode:String = "auto", order:int = 0, multiplier:float = 10, tick_length:int = 10):
	var ticks_power:int = order
	if mode.to_lower() == "auto":
		ticks_power = int(log(value_range) / log(multiplier)) - order
		multiplier = 10
	else:
		ticks_power = order
		
		
	var min_tick_value:float = multiplier**ticks_power * int(limits[0] / multiplier**ticks_power)
	var nb_main_ticks:int = int(value_range / multiplier**ticks_power) + 1
	var nb_seco_ticks:int = int(value_range / multiplier**(ticks_power-1))
	#var max_tick_value:float = floor(limits[1] / 10**main_ticks)
	
	prints("main ticks params: ", name, order, ticks_power, min_tick_value, nb_main_ticks)
	
	main_tick_values = range(1, nb_main_ticks).map(func(x):return min_tick_value + x * multiplier**ticks_power)
	secondary_tick_values = range(1, nb_seco_ticks).map(func(x):return min_tick_value + x * multiplier**(ticks_power - 1))
	
	
	print(limits)
	print(pos_limits, pos_limits[1] - pos_limits[0])
	
	print(main_tick_values)
	_DrawTicks(main_tick_values, order, tick_length, Color(1, 0, 0))
	print(secondary_tick_values)
	_DrawTicks(secondary_tick_values, order+1, tick_length/2., Color(0, 1, 0))
	
func _DrawTicks(tick_values:Array, order:int, tick_length:int = 10, color:Color = Color(1, 1, 1, 0)):
	var tick_node:Node2D = %MainTicks
	if order > 0:
		tick_node = %SecondTicks
		
	for t in tick_node.get_children():
		t.queue_free()
	for l in %MainTicksLabels.get_children():
		l.queue_free()
	
	#var axis_length:float = (get_point_position(1) - get_point_position(0)).length()
	
	if color.a == 0:
		color = default_color
	
	var axis_perp:Vector2 = direction.rotated(PI/2).normalized()
	
	for i in range(len(tick_values)):
		var new_tick:Line2D = Line2D.new()
		new_tick.width = 1
		new_tick.default_color = color
		new_tick.position = GetPointPosition(tick_values[i])
		new_tick.add_point(+ axis_perp * tick_length/2.)
		new_tick.add_point(- axis_perp * tick_length/2.)
		prints("ticks", name, order, tick_values[i], new_tick.position)
		tick_node.add_child(new_tick)
		
	if order == 0:
		var last_label:Label = Label.new()
		last_label.text = str(tick_values[-1])
		last_label.position = tick_node.get_child(-1).position - axis_perp  * (last_label.get_line_height() - tick_length/2.)
		%MainTicksLabels.add_child(last_label)

func GetPointCoords(pos:Vector2) -> float:
	"""Return the value of a point along this axis given it's position on the graph."""
	pos = pos.project(direction)
	var coords:float = (pos.length() - origin_pos) * pix_to_unit
	return coords

func GetPointPosition(value:float) -> Vector2:
	"""Return the local position on the axis of a point given it's value along this axis."""
	var pos:float = value * unit_to_pix
	#prints("value to pos", name, value, unit_to_pix, limits[0], pos)
	return pos * direction
	
func GetGlobalPointPosition(value:float) -> Vector2:
	"""Return the global position on the axis of a point given it's value along this axis."""
	var pos:float = value * unit_to_pix + origin_pos
	#prints("value to pos", name, value, unit_to_pix, limits[0], pos)
	return pos * direction
