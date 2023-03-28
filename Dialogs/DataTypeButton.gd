extends MenuButton

@onready var tab_container := $"../../TabContainer"
@onready var CreateDataTypeDialog := $"../../DataTypeDialogs/CreateDataTypeDialog"
@onready var RemoveDataTypeDialog := $"../../DataTypeDialogs/RemoveDataTypeDialog"
@onready var EditDataTypeDialog := $"../../DataTypeDialogs/EditDataType"

func _ready():
	var popup := get_popup()
	popup.connect("index_pressed", on_index_pressed)
	
	var add_data_type_shortcut := Shortcut.new()
	add_data_type_shortcut.events = InputMap.action_get_events("add_data_type")
	popup.set_item_shortcut(0, add_data_type_shortcut)
	
	var remove_data_type_shortcut := Shortcut.new()
	remove_data_type_shortcut.events = InputMap.action_get_events("remove_data_type")
	popup.set_item_shortcut(1, remove_data_type_shortcut)
	
	var edit_data_type_shortcut := Shortcut.new()
	edit_data_type_shortcut.events = InputMap.action_get_events("edit_data_type")
	popup.set_item_shortcut(2, edit_data_type_shortcut)
	
	CreateDataTypeDialog.connect("finished", on_finish_create_data_type)
	RemoveDataTypeDialog.connect("finished", on_finish_remove_create_data_type)
	EditDataTypeDialog.connect("finished", on_finish_edit_create_data_type)

func on_index_pressed(index:int):
	var action := get_popup().get_item_text(index)
	
	match (action):
		"Add": create_data_type()
		"Remove": remove_data_type()
		"Edit": edit_data_type()

func on_finish_create_data_type():
	if CreateDataTypeDialog.data_type == "" or CreateDataTypeDialog.byte_size == "":
		return
	
	var tree := tab_container.get_current_tab_control() as Control
	
	if tree.data_types.has(CreateDataTypeDialog.data_type):
		create_data_type()
		CreateDataTypeDialog.DataType.text = CreateDataTypeDialog.data_type
	
	tree.data_types[CreateDataTypeDialog.data_type] = CreateDataTypeDialog.byte_size
	tree.data_types_string = ",".join(tree.data_types.keys())
	
	tree.display_data_types()

func on_finish_remove_create_data_type():
	if RemoveDataTypeDialog.data_type == "":
		return
	
	var tree := tab_container.get_current_tab_control() as Control
	
	tree.data_types_string = tree.data_types_string.replace("," + RemoveDataTypeDialog.data_type, "")
	tree.remove_data_type_in_tree(RemoveDataTypeDialog.data_type)
	
	tree.data_types.erase(RemoveDataTypeDialog.data_type)
	tree.display_data_types()

func on_finish_edit_create_data_type():
	if EditDataTypeDialog.data_type == "" or EditDataTypeDialog.byte_size == "":
		return
		
	var tree := tab_container.get_current_tab_control() as Control
	
	tree.data_types[EditDataTypeDialog.data_type] = EditDataTypeDialog.byte_size
	
	tree.edit_data_type_in_tree(EditDataTypeDialog.data_type)
	tree.display_data_types()

func create_data_type():
	if tab_container.get_current_tab_control() == null:
		return
	
	CreateDataTypeDialog.popup_centered()

func remove_data_type():
	var tree := tab_container.get_current_tab_control() as Control
	if tree == null:
		return
	
	RemoveDataTypeDialog.popup_centered()
	RemoveDataTypeDialog.update_data_types(tree)

func edit_data_type():
	var tree := tab_container.get_current_tab_control() as Control
	if tree == null:
		return
	
	EditDataTypeDialog.popup_centered()
	EditDataTypeDialog.update_data_types(tree)
