extends Control
class_name Statistics

var nb_players:int

var player_names:Array

var player_scores:Array[Array]

@export var graph_colors:Array = ['RED', 'GREEN', 'BLUE', 'CYAN', 'ORANGE', 'GOLD', 'TEAL', 'PURPLE']
@export var graph_size:Vector2 = Vector2(343, 343)
@export var graph_origin:Vector2 = Vector2(0, graph_size.y)

func Setup(player_names_list:Array):
	nb_players = len(player_names_list)
	%ScoreTable.columns = nb_players
	
	player_names = player_names_list.duplicate()
	player_scores.resize(nb_players)
	for i in range(nb_players):
		player_scores[i] = [0]
		AddEntryToScoreTable(player_names[i])
	for i in range(nb_players):
		AddEntryToScoreTable(player_scores[i][0])
	
	InitGraph()
	
func UpdateScore(new_scores:Array):
	
	for i in range(nb_players):
		player_scores[i].append(new_scores[i])
		AddEntryToScoreTable(player_scores[i][-1])
		UpdateEntryToScoreGraph(i, new_scores[i])
	AddEntryToScoreGraph()
			
	print(player_scores)

func SortPlayers() -> Array:
	var sorted_player_list = range(nb_players)
	sorted_player_list.sort_custom(func (a, b): return player_scores[a][-1] < player_scores[b][-1])
	prints("sorted players", sorted_player_list)
	return sorted_player_list
	
func GetExport() -> Dictionary:
	return {"names":player_names,
			"scores":player_scores}
func Import(data:Dictionary):
	Setup(data["names"])
	var new_scores:Array = []
	new_scores.resize(nb_players)
	for i in len(data["scores"][0]):
		for p in range(nb_players):
			new_scores[p] = data["scores"][p][i]
		UpdateScore(new_scores)

func GetWinnerName() -> String:
	print(player_names)
	return player_names[SortPlayers()[-1]]
func GetWinnerScore() -> int:
	return player_scores[SortPlayers()[-1]][-1]

func InitGraph():
	
	%GraphScore/Xaxis.add_point(graph_origin)
	%GraphScore/Xaxis.add_point(graph_origin + Vector2(graph_size.x, 0))
	%GraphScore/Yaxis.add_point(graph_origin)
	%GraphScore/Yaxis.add_point(graph_origin + Vector2(0, -graph_size.y))
	
	for i in range(nb_players):
		var graph_line:Line2D = Line2D.new()
		graph_line.width = 3
		graph_line.default_color = Color(graph_colors[i % len(graph_colors)])
		graph_line.add_point(graph_origin)
		graph_line.add_point(graph_origin)
		%GraphScore.add_child(graph_line)
	
func GetGraphDeltaX(line:Line2D):
	#prints("deltaX", int(graph_size.x / (line.get_point_count() - 1)))
	return int(graph_size.x / (line.get_point_count() - 1))
	
func GetPointXPos(line:Line2D, point_id:int):
	if point_id < 0:
		point_id = line.get_point_count() + point_id
	#prints("xpos", GetGraphDeltaX(line) * point_id)
	return GetGraphDeltaX(line) * point_id
	
func GetPlayerLine(player_id:int):
	return %GraphScore.get_child(player_id + 2)
	
func UpdateEntryToScoreGraph(player_id:int, new_score:int):
	var line:Line2D = GetPlayerLine(player_id)
	var new_pos:Vector2 = graph_origin + Vector2(GetPointXPos(line, -1), -new_score)
	line.set_point_position(line.get_point_count()-1, new_pos)

func AddEntryToScoreGraph():
	for i in range(nb_players):
		var player_line:Line2D = GetPlayerLine(i)
		player_line.add_point(Vector2(GetPointXPos(player_line, -1), player_line.get_point_position(len(player_scores[i])-1).y))
		for ip in range(player_line.get_point_count()):
			player_line.set_point_position(ip, Vector2(GetPointXPos(player_line, ip), player_line.get_point_position(ip).y))
		
func UpdateEntryToScoreTable(col:int, row:int, new_text:String):
	var id:int = nb_players * row + col
	#prints(col, row, id)
	%ScoreTable.get_child(id).text = new_text

func AddEntryToScoreTable(entry_text):
	var entry = Label.new()
	entry.set_anchors_preset(Control.PRESET_CENTER)
	entry.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	entry.text = str(entry_text)
	%ScoreTable.add_child(entry)


func _on_close_button_pressed() -> void:
	visible = false
