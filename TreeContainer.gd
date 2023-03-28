extends TabContainer

var StructureTree := preload("res://Structure Tree/Structure Tree.tscn")

@onready var AddItemBeforeBtn := $"../HBoxContainer/AddItemBeforeBtn"
@onready var AddItemAfterBtn := $"../HBoxContainer/AddItemAfterBtn"
@onready var AddItemBelowBtn := $"../HBoxContainer/AddItemBelowBtn"
@onready var RemoveItemBtn := $"../HBoxContainer/RemoveItemBtn"

func _ready():
	get_tree().get_root().connect("files_dropped", on_files_dropped)
	
	var add_item_before_shortcut := Shortcut.new()
	add_item_before_shortcut.events = InputMap.action_get_events("add_item_before")
	AddItemBeforeBtn.shortcut = add_item_before_shortcut
	
	var add_item_after_shortcut := Shortcut.new()
	add_item_after_shortcut.events = InputMap.action_get_events("add_item_after")
	AddItemAfterBtn.shortcut = add_item_after_shortcut
	
	var add_item_below_shortcut := Shortcut.new()
	add_item_below_shortcut.events = InputMap.action_get_events("add_item_below")
	AddItemBelowBtn.shortcut = add_item_below_shortcut
	
	var remove_item_shortcut := Shortcut.new()
	remove_item_shortcut.events = InputMap.action_get_events("remove_item")
	RemoveItemBtn.shortcut = remove_item_shortcut
	
	AddItemBeforeBtn.connect("pressed", on_add_item_before_pressed)
	AddItemAfterBtn.connect("pressed", on_add_item_after_pressed)
	AddItemBelowBtn.connect("pressed", on_add_item_below_pressed)
	RemoveItemBtn.connect("pressed", on_remove_item_pressed)

func on_files_dropped(files:PackedStringArray):
	for file in files:
		load_file(file)

func on_add_item_before_pressed():
	var tree := get_current_tab_control()
	if tree == null:
		return
	
	tree.add_item_before()

func on_add_item_after_pressed():
	var tree := get_current_tab_control()
	if tree == null:
		return
	
	tree.add_item_after()

func on_add_item_below_pressed():
	var tree := get_current_tab_control()
	if tree == null:
		return
	
	tree.add_item_below()

func on_remove_item_pressed():
	var tree := get_current_tab_control()
	if tree == null:
		return
	
	tree.remove_item()

func new_file():
	var tree := StructureTree.instantiate()
	tree.new_file()
	tree.add_item()
	
	add_child(tree)
	set_tab_title(get_tab_count() - 1, "new")

func save_file(path:String, close_after:bool = false):
	var tree := get_current_tab_control()
	tree.save_file(path)
	
	if close_after == true:
		tree.free()

func load_file(path:String):
	var tree := StructureTree.instantiate()
	tree.load_file(path)
	
	add_child(tree)
	set_tab_title(get_tab_count() - 1, path.get_file().get_basename())

func close_file(tree:Control = null):
	if tree == null:
		tree = get_current_tab_control()
	
	tree.free()
