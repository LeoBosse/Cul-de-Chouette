@tool
extends Control

@onready var rule_list_container_node:Node = $VBoxContainer/ScrollContainer/VBoxContainer

func Setup(rules_list:Array):
	Clean()
	for r in rules_list:
		AddRule(r)

func AddRule(rule:Rule):
	#prints("rule min size: ", rule.rule_name, rule.get_combined_minimum_size().y, rule.get_minimum_size().y)
	
	rule_list_container_node.add_child(rule)
	rule_list_container_node.get_child(-1).current_state = rule.State.DOCUMENTATION
	rule_list_container_node.get_child(-1).visible = true
	
	#prints("rule min size: ", rule_list_container_node.get_child(-1).rule_name, rule_list_container_node.get_child(-1).get_combined_minimum_size().y, rule_list_container_node.get_child(-1).get_minimum_size().y)


func Clean():
	for c in rule_list_container_node.get_children():
		c.queue_free()
