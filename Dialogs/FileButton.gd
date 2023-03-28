extends MenuButton

var StructureTree := preload("res://Structure Tree/Structure Tree.tscn")

@onready var tab_container := $"../../TabContainer"
@onready var UnsavedFileDialog := $"../../FileDialogs/UnsavedFileDialog"
@onready var SaveFileDialog := $"../../FileDialogs/SaveFileDialog"
@onready var LoadFileDialog := $"../../FileDialogs/LoadFileDialog"

var close_after := false

func _ready():
	var popup := get_popup()
	popup.connect("index_pressed", on_index_pressed)
	
	var new_file_shortcut := Shortcut.new()
	new_file_shortcut.events = InputMap.action_get_events("new_file")
	popup.set_item_shortcut(0, new_file_shortcut)
	
	var save_file_shortcut := Shortcut.new()
	save_file_shortcut.events = InputMap.action_get_events("save_file")
	popup.set_item_shortcut(1, save_file_shortcut)
	
	var load_file_shortcut := Shortcut.new()
	load_file_shortcut.events = InputMap.action_get_events("load_file")
	popup.set_item_shortcut(2, load_file_shortcut)
	
	var close_file_shortcut := Shortcut.new()
	close_file_shortcut.events = InputMap.action_get_events("close_file")
	popup.set_item_shortcut(4, close_file_shortcut)
	
	UnsavedFileDialog.connect("confirmed", on_unsaved_file_yes)
	UnsavedFileDialog.connect("discarded", on_unsaved_file_no)
	SaveFileDialog.connect("file_selected", on_save_file_dialog_file_selected)
	SaveFileDialog.connect("cancelled", on_save_file_dialog_file_cancelled)
	LoadFileDialog.connect("file_selected", on_load_file_dialog_file_selected)

func on_index_pressed(index:int):
	var action := get_popup().get_item_text(index)
	
	match (action):
		"New": new_file()
		"Save": save_file()
		"Load": load_file()
		"Close": close_file()

func on_unsaved_file_yes():
	close_after = true
	save_file()

func on_unsaved_file_no():
	tab_container.close_file()

func on_save_file_dialog_file_selected(path:String):
	tab_container.save_file(path, close_after)
	close_after = false

func on_save_file_dialog_file_cancelled():
	close_after = false

func on_load_file_dialog_file_selected(path:String):
	tab_container.load_file(path)

func new_file():
	tab_container.new_file()

func save_file():
	var tree := tab_container.get_current_tab_control() as Control
	if tree == null:
		return
	
	if tree.save_path != "":
		tree.save_file(tree.save_path)
		return
	
	var tab_index := tab_container.get_tab_idx_from_control(tree) as int
	var tab_name := tab_container.get_tab_title(tab_index) as String
	
	SaveFileDialog.current_file = tab_name + ".ssv"
	SaveFileDialog.popup_centered_ratio(0.75)

func load_file():
	LoadFileDialog.popup_centered_ratio(0.75)

func close_file():
	var tree := tab_container.get_current_tab_control() as Control
	if tree == null:
		return
	
	if tree.saved == false:
		UnsavedFileDialog.popup_centered()
	else:
		tab_container.close_file(tree)
