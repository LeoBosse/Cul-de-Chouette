extends Control
class_name Statistics

var nb_players:int

var player_names:Array

var player_scores:Array[Array]
var current_player_list:Array = [0]

@export var graph_colors:Array = ['RED', 'GREEN', 'BLUE', 'CYAN', 'ORANGE', 'GOLD', 'TEAL', 'PURPLE']
@export var graph_size:Vector2 = Vector2(343, 343)
@export var graph_origin:Vector2 = Vector2(0, graph_size.y)

signal undoing_turn(point_correction:Array)

func Setup(player_names_list:Array):
	nb_players = len(player_names_list)
	%ScoreTableGrid.columns = nb_players
	
	player_names = player_names_list.duplicate()
	player_scores.resize(nb_players)
	for i in range(nb_players):
		player_scores[i] = [0]
		AddEntryToScoreTable(player_names[i])
	for i in range(nb_players):
		AddEntryToScoreTable(player_scores[i][0])
	
	InitGraph()
	
func AddScores(new_scores:Array, current_player:int):
	current_player_list.append(current_player)
	for i in range(nb_players):
		player_scores[i].append(new_scores[i])
		AddEntryToScoreTable(new_scores[i])
		AddScoreToGraph(i, new_scores[i])
	%GraphScore.AdaptScalingToLines(true, false)
	
	#print(player_scores)

func SortPlayers() -> Array:
	var sorted_player_list = range(nb_players)
	sorted_player_list.sort_custom(func (a, b): return player_scores[a][-1] < player_scores[b][-1])
	prints("sorted players", sorted_player_list)
	return sorted_player_list
	
func GetExport() -> Dictionary:
	return {"names":player_names,
			"scores":player_scores,
			"current_player_list":current_player_list}
func Import(data:Dictionary):
	Setup(data["names"])
	current_player_list = []
	var new_scores:Array = []
	new_scores.resize(nb_players)
	for i in len(data["scores"][0]):
		for p in range(nb_players):
			new_scores[p] = data["scores"][p][i]
		AddScores(new_scores, data["current_player_list"][i])

func GetWinnerName() -> String:
	print(player_names)
	return player_names[SortPlayers()[-1]]
func GetWinnerScore() -> int:
	return player_scores[SortPlayers()[-1]][-1]

func InitGraph():
	var line_points:Array = []
	for i in range(nb_players):
		line_points.append([Vector2.ZERO])
		
	%GraphScore.Initialize(line_points, player_names)

func AddScoreToGraph(player_id:int, new_score:int):
	%GraphScore.AddPointToLine(player_id, Vector2(len(player_scores[player_id])-1, new_score), false)


func UpdateEntryToScoreTable(col:int, row:int, new_text:String):
	var id:int = nb_players * row + col
	#prints(col, row, id)
	%ScoreTableGrid.get_child(id).text = new_text

func AddEntryToScoreTable(entry_text):
	var entry = Label.new()
	entry.set_anchors_preset(Control.PRESET_CENTER)
	entry.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	entry.text = str(entry_text)
	%ScoreTableGrid.add_child(entry)


func UndoTurn():
	if len(player_scores[0]) < 2:
		return
	
	var correction:Array = []
	
	for i in range(nb_players):
		correction.append(player_scores[i][-2] - player_scores[i][-1])
		player_scores[i].pop_back()
		%ScoreTableGrid.get_child(%ScoreTableGrid.get_child_count() - i - 1).queue_free()
		%GraphScore.RemovePointFromLine(i, -1, false)
	%GraphScore.AdaptScalingToLines(true, false)
	
	undoing_turn.emit(correction, current_player_list[-1])
	
	current_player_list.pop_back()

func _on_undo_button_pressed() -> void:
	UndoTurn()
