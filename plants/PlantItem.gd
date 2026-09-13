extends PanelContainer
class_name PlantItem

signal idChanged
signal amountChanged
signal deleted

var amountsb : SpinBox
var idEdit : LineEdit

func _init():
	var vb := VBoxContainer.new()
	vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vb.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	
	var idhb := HBoxContainer.new()
	idhb.name = "id"
	idhb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var l := Label.new()
	l.text = "ID:"
	
	var idedit := LineEdit.new()
	idedit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	idedit.text_changed.connect(idChanged.emit)
	idedit.placeholder_text = "ID..."
	
	
	var amhb := HBoxContainer.new()
	amhb.name = "amount"
	amhb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var l2 := Label.new()
	l2.text = "Amount:"
	
	var amsb := SpinBox.new()
	amsb.allow_greater = true
	amsb.set_value_no_signal(1)
	amsb.apply()
	amsb.value_changed.connect(amountChanged.emit)
	
	
	idhb.add_child(l)
	idhb.add_child(idedit)
	
	vb.add_child(idhb)
	
	amhb.add_child(l2)
	amhb.add_child(amsb)
	
	vb.add_child(amhb)
	
	var delButton : Button = Button.new()
	delButton.text = "Delete"
	delButton.pressed.connect(deleted.emit)
	vb.add_child(delButton)
	
	amountsb = amsb
	idEdit = idedit
	
	add_child(vb)
	

func setAmount(new:int) -> void:
	amountsb.set_value_no_signal(new)

func getAmount() -> int:
	return int(amountsb.value)

func getId() -> String:
	return idEdit.text

func setId(new:String) -> void:
	idEdit.text = new


func onIdChanged(_new_id:String) -> void:
	emit_signal("idChanged")

func onAmountChanged(_new) -> void:
	emit_signal("amountChanged")
