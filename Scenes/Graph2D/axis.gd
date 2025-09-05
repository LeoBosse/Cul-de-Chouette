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
var pos_limits:Array = [0, 100]

var value_range:float:
	get():
		return limits[1] - limits[0]
		
var length:float:
	get():
		return pos_limits[1] - pos_limits[0]

var pix_to_unit:float = 1.:
	set(new_value):
		pix_to_unit = new_value
		AutoTicks(0, 10, 10)
		AutoTicks(1, 10, 5)
		
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


func Setup(dir:Vector2, origin:float, min_value:int, max_value:int, graph_size:int):
	direction = dir
	origin_pos = origin
	
	limits = [min_value, max_value]
	
	pix_to_unit = float(limits[1] - limits[0]) / (graph_size)
	
	pos_limits = [GetPointPosition(limits[0]), GetPointPosition(limits[1])]
	
	prints("limits", pix_to_unit, limits, pos_limits)
	
	width = 2
	default_color = Color(1, 1, 1)
	
	clear_points()
	add_point(pos_limits[0])
	add_point(pos_limits[1])
	
	AutoTicks(0, 10, 10)
	AutoTicks(1, 10, 5)

func AutoTicks(order:int = 0, multiplier:float = 10, tick_length:int = 10):
	
	var ticks_power:int = int(log(value_range) / log(multiplier) - order)
	var min_tick_value:float = multiplier**ticks_power * int(limits[0] / multiplier**ticks_power)
	var nb_ticks:int = int(value_range / multiplier**ticks_power)
	#var max_tick_value:float = floor(limits[1] / 10**main_ticks)
	
	var tick_values:Array = range(nb_ticks + 1).map(func(x):return min_tick_value + x * multiplier**ticks_power)
	
	_SetupTicks(tick_values, order, tick_length)
	
func _SetupTicks(tick_values:Array, order:int, tick_length:int = 10):
	var tick_node:Node2D = %MainTicks
	if order > 0:
		tick_node = %SecondTicks
		
	for t in tick_node.get_children():
		t.queue_free()
	for l in %MainTicksLabels.get_children():
		l.queue_free()
	
	#var axis_length:float = (get_point_position(1) - get_point_position(0)).length()
	
	var axis_perp:Vector2 = direction.rotated(PI/2).normalized()
	
	for i in range(len(tick_values)):
		var new_tick:Line2D = Line2D.new()
		new_tick.width = 1
		new_tick.default_color = default_color
		new_tick.add_point(GetPointPosition(tick_values[i]) + axis_perp * tick_length/2.)
		new_tick.add_point(GetPointPosition(tick_values[i]) - axis_perp * tick_length/2.)
		#prints("ticks", order, tick_values[i], GetPointPosition(tick_values[i]))
		tick_node.add_child(new_tick)
		
	if order == 0:
		var last_label:Label = Label.new()
		last_label.text = str(tick_values[-1])
		last_label.position = tick_node.get_child(-1).get_point_position(1) - axis_perp  * (last_label.get_line_height() - tick_length/2.)
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
