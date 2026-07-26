extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$tabs.set_tab_title(0, "Options")
	$tabs.set_tab_title(1, "Plant Editor")
	
	Manager.loadFromConfigFile("user://recent.ini")
	$tabs/pathsEditor.populatePaths()
