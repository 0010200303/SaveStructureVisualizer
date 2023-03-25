extends Tree

@onready var AddItemBeforeBtn := $"../HBoxContainer/AddItemBeforeBtn"
@onready var AddItemAfterBtn := $"../HBoxContainer/AddItemAfterBtn"
@onready var AddItemBelowBtn := $"../HBoxContainer/AddItemBelowBtn"
@onready var RemoveItemBtn := $"../HBoxContainer/RemoveItemBtn"

@onready var UnsavedFileDialog := $"../FileDialogs/UnsavedFileDialog"
@onready var SaveFileDialog := $"../FileDialogs/SaveFileDialog"
@onready var LoadFileDialog := $"../FileDialogs/LoadFileDialog"
@onready var CreateDataTypeDialog := $"../DataTypeDialogs/CreateDataTypeDialog"
@onready var RemoveDataTypeDialog := $"../DataTypeDialogs/RemoveDataTypeDialog"
@onready var EditDataTypeDialog := $"../DataTypeDialogs/EditDataType"

var data_types := { "create new data type":"-1",
					"[bool]":"1",
					"[byte]":"1",
					"[int]":"4",
					"[float]":"4",
					"[string]":"n*1" }

var data_types_string := ",".join(data_types.keys())

var saved := true
var open_new_file := false

func _ready():
	AddItemBeforeBtn.connect("pressed", on_add_item_before_pressed)
	AddItemAfterBtn.connect("pressed", on_add_item_after_pressed)
	AddItemBelowBtn.connect("pressed", on_add_item_below_pressed)
	RemoveItemBtn.connect("pressed", on_remove_item_pressed)
	
	UnsavedFileDialog.connect("confirmed", on_unsaved_file_yes)
	UnsavedFileDialog.connect("cancelled", on_unsaved_file_no)
	SaveFileDialog.connect("file_selected", on_save_file_dialog_file_selected)
	SaveFileDialog.connect("cancelled", on_save_file_dialog_file_cancelled)
	LoadFileDialog.connect("file_selected", on_load_file_dialog_file_selected)
	CreateDataTypeDialog.connect("finished", on_finish_create_data_type)
	RemoveDataTypeDialog.connect("finished", on_finish_remove_data_type)
	EditDataTypeDialog.connect("finished", on_finish_edit_data_type)
	
	set_column_title(0, "byte_size")
	set_column_title(1, "data_type")
	set_column_title(2, "name")
	set_column_title(3, "description")
	
	connect("cell_selected", display_data_types)
	connect("item_edited", on_item_edited)
	
	new_file()
	
#	save_file("C:/Users/jonas/Desktop/KEKwww.ssv")
#	load_file("C:/Users/jonas/Desktop/KEKwww.ssv")

func add_item(root_item:TreeItem, data_type_index:int = 0, item_name:String = "", description = "") -> TreeItem:
	var item := create_item(root_item)
	item.set_text(0, data_types[data_types.keys()[0]])
	
	item.set_cell_mode(1, TreeItem.CELL_MODE_RANGE)
	item.set_editable(1, true)
	item.set_text(1, data_types_string)
	
	item.set_editable(2, true)
	item.set_editable(3, true)
	
	select_data_type(item, data_type_index)
	item.set_text(2, item_name)
	item.set_text(3, description)
	
	return item

func select_data_type(item:TreeItem, index:int):
	item.set_range(1, index)
	item.set_text(0, data_types.values()[index])

func update_data_types_string():
	data_types_string = ",".join(data_types.keys())
	
	saved = false

func new_file() -> TreeItem:
	clear()
	
	var root := create_item(null)
	root.set_text(0, "0")
	root.set_text(1, "root")
	
	open_new_file = false
	
	return root

func load_tree_from_file(file:FileAccess, root:TreeItem):
	var count := file.get_32()
	
	var item := add_item(root)
	select_data_type(item, file.get_32())
	item.set_text(2, file.get_pascal_string())
	item.set_text(3, file.get_pascal_string())
	
	for i in count:
		load_tree_from_file(file, item)

func load_file(path:String):
	var file := FileAccess.open(path, FileAccess.READ)
	var count := file.get_32()
	
	data_types = { "create new data type":"-1" }
	
	for i in count:
		var key := file.get_pascal_string()
		var value := file.get_pascal_string()
		
		data_types[key] = value
	update_data_types_string()
	
	var root := new_file()
	
	count = file.get_32()
	for i in count:
		load_tree_from_file(file, root)
	
	saved = true

func save_tree_item_to_file(file:FileAccess, item:TreeItem):
	var children := item.get_children()
	
	file.store_32(children.size())
	
	file.store_32(int(item.get_range(1)))
	file.store_pascal_string(item.get_text(2))
	file.store_pascal_string(item.get_text(3))
	
	for child in children:
		save_tree_item_to_file(file, child)

func save_file(path:String):
	var file := FileAccess.open(path, FileAccess.WRITE)
	var keys := data_types.keys()
	
	file.store_32(keys.size() - 1)
	for i in range(1, keys.size()):
		var key := keys[i] as String

		file.store_pascal_string(key)
		file.store_pascal_string(data_types[key])
	
	var children := get_root().get_children()
	file.store_32(children.size())
	
	for child in children:
		save_tree_item_to_file(file, child)
	
	saved = true

func display_data_types():
	var selected_item := get_selected()
	var selected_column := get_selected_column()
	
	if selected_item == null or selected_column != 1:
		return
	
	if selected_item.get_cell_mode(1) == TreeItem.CELL_MODE_RANGE:
		selected_item.set_text(1, data_types_string)

func remove_data_type_in_tree(item:TreeItem, data_type:String):
	if data_types.keys()[item.get_range(1)] == data_type:
		item.set_range(1, 0)
		item.set_text(0, data_types[data_types.keys()[0]])
	
	for child in item.get_children():
		remove_data_type_in_tree(child, data_type)

func edit_data_type_in_tree(item:TreeItem, data_type:String):
	if data_types.keys()[item.get_range(1)] == data_type:
		item.set_text(0, data_types[data_type])
	
	for child in item.get_children():
		edit_data_type_in_tree(child, data_type)

func on_item_edited():
	var edited_item := get_edited()
	var edited_column := get_edited_column()
	
	saved = false
	
	if edited_item.get_cell_mode(1) != TreeItem.CELL_MODE_RANGE or edited_column != 1:
		return
	
	if edited_item.get_range(1) == 0:
		create_new_data_type()
	
	var byte_size := data_types.values()[edited_item.get_range(1)] as String
	edited_item.set_text(0, byte_size)

func new_file_if_saved():
	if saved == false:
		UnsavedFileDialog.popup_centered()
	else:
		new_file()

func save_file_dialog():
	SaveFileDialog.popup_centered_ratio(0.75)

func load_file_dialog():
	LoadFileDialog.popup_centered_ratio(0.75)

func create_new_data_type():
	CreateDataTypeDialog.popup_centered()

func remove_data_type():
	RemoveDataTypeDialog.popup_centered()
	RemoveDataTypeDialog.update_data_types()

func edit_data_type():
	EditDataTypeDialog.popup_centered()
	EditDataTypeDialog.update_data_types()

func on_add_item_before_pressed():
	var selected := get_selected()
	
	if selected == null or selected == get_root():
		return
	
	var item := add_item(selected.get_parent())
	item.move_before(selected)

func on_add_item_after_pressed():
	var selected := get_selected()
	
	if selected == null or selected == get_root():
		return
	
	add_item(selected.get_parent())

func on_add_item_below_pressed():
	var selected := get_selected()
	
	if selected == null:
		return
	
	add_item(selected)

func on_remove_item_pressed():
	var selected := get_selected()
	
	if selected == null or selected == get_root():
		return
	
	selected.free()

func on_unsaved_file_yes():
	open_new_file = true
	save_file_dialog()

func on_unsaved_file_no():
	new_file()

func on_save_file_dialog_file_selected(path:String):
	save_file(path)
	
	if open_new_file == true:
		new_file()

func on_load_file_dialog_file_selected(path:String):
	load_file(path)

func on_save_file_dialog_file_cancelled():
	open_new_file = false

func on_finish_create_data_type():
	if CreateDataTypeDialog.data_type == "" or CreateDataTypeDialog.byte_size == "":
		return
	
	if data_types.has(CreateDataTypeDialog.data_type):
		create_new_data_type()
		CreateDataTypeDialog.DataType.text = CreateDataTypeDialog.data_type
	
	data_types[CreateDataTypeDialog.data_type] = CreateDataTypeDialog.byte_size
	data_types_string = ",".join(data_types.keys())
	
	display_data_types()

func on_finish_remove_data_type():
	if RemoveDataTypeDialog.data_type == "":
		return
	
	data_types_string = data_types_string.replace("," + RemoveDataTypeDialog.data_type, "")
	
	remove_data_type_in_tree(get_root(), RemoveDataTypeDialog.data_type)
	
	data_types.erase(RemoveDataTypeDialog.data_type)
	display_data_types()

func on_finish_edit_data_type():
	if EditDataTypeDialog.data_type == "" or EditDataTypeDialog.byte_size == "":
		return
	
	data_types[EditDataTypeDialog.data_type] = EditDataTypeDialog.byte_size
	
	edit_data_type_in_tree(get_root(), EditDataTypeDialog.data_type)
	display_data_types()
