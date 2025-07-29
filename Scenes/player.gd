extends Node2D
class_name Player

@export var player_name:String = "joueur"
@export var index:int = 0
@onready var score:int = 0
@onready var state:int = 0

@onready var grelottine:bool = false
