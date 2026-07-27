extends FoldableContainer
class_name ProfileFieldContainer

var field : Field = null :
	set(v):
		disconnectField(field)
		field = v
		clearDataDisplay()
		displayData()
		connectField(v)

@onready var datac : Container = $vb/vb

func disconnectField(f:Field) -> void:
	if !f:
		return
	
	f.dataAdded.disconnect(addData)
	f.dataRemoved.disconnect(removeData)
	f.refreshRequested.disconnect(displayData)

func connectField(f:Field) -> void:
	if !f:
		return
	
	f.refreshRequested.connect(displayData)
	f.dataAdded.connect(addData)
	f.dataRemoved.connect(removeData, ConnectFlags.CONNECT_DEFERRED)

func removeData(_idx:int) -> void:
	#if datac.get_child_count()<=idx:
		#return
	#
	#datac.get_child(idx).free()
	clearDataDisplay()
	displayData()

func displayData() -> void:
	if !field:
		return
	
	for d in field.getData():
		addData(d)

func addData(d:String) -> void:
	var vb := HBoxContainer.new()
	
	var nl = TextEdit.new()
	nl.scroll_fit_content_height = true
	#nl.custom_minimum_size.y = 100
	nl.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	nl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	nl.scroll_horizontal = false
	
	
	nl.placeholder_text = "Data..."
	nl.text = d
	nl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	nl.size_flags_vertical = Control.SIZE_EXPAND_FILL
	nl.text_changed.connect(dataChanged.bind(datac.get_child_count(), nl))
	
	var nb := Button.new()
	nb.text = "Delete"
	nb.pressed.connect(field.removeData.bind(d))
	
	
	vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vb.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	var l2 := Label.new()
	l2.text = "AL%s" % datac.get_child_count()
	l2.tooltip_text = "Access level: %s" % datac.get_child_count()
	l2.mouse_filter = Control.MOUSE_FILTER_STOP
	
	vb.add_child(l2)
	vb.add_child(nl)
	vb.add_child(nb)
	
	datac.add_child(vb)

func clearDataDisplay() -> void:
	for node in datac.get_children():
		node.free()

func setLabel(t:String) -> void:
	title = t

func dataChanged(idx:int, tl:TextEdit) -> void:
	field.setData(idx, tl.text)

func _on_add_pressed() -> void:
	#addData("")
	field.addData("")
