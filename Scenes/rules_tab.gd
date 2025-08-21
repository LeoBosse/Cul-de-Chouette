@tool
extends Control

@onready var rule_list_container_node:Node = $VBoxContainer/ScrollContainer/VBoxContainer

func Setup(rules_list:Array):
	Clean()
	for r in rules_list:
		AddRule(r)

func AddRule(rule:Rule):
	rule.current_state = rule.State.DOCUMENTATION
	rule.visible = true
	rule_list_container_node.add_child(rule)


func Clean():
	for c in rule_list_container_node.get_children():
		c.queue_free()
