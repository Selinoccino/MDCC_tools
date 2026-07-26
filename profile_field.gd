extends PanelContainer
class_name ProfileField

@onready var dtree : Tree = $vb/dataTree

func displayData(data:Array[String]) -> void:
	dtree.clear()
	
	dtree.create_item()
	
	for d in data:
		var t : TreeItem = dtree.create_item()
		t.set_text(0, d)
		t.set_editable(0, true)

func setLabel(l:String) -> void:
	$vb/fieldId.text = l
