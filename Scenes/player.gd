extends Node2D
class_name Player

@export var player_name:String = "joueur"
@export var index:int = 0
@export var team:int = 0

var score:int = 0
var sirotage_score:int = 0
var grelottine:bool = false
var has_civet:bool = false

var state:int = 0
