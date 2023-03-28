extends Panel

@onready var tab_container := $TabContainer
@onready var SaveBeforeQuitDialog := $FileDialogs/SaveBeforeQuitDialog

func _ready():
	get_tree().auto_accept_quit = false
	
	SaveBeforeQuitDialog.connect("discard", on_save_before_quit_no)

func _notification(what:int):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_all_before_quit()

func save_all_before_quit():
	var children := tab_container.get_children()
	for child in children:
		if child.saved == false:
			SaveBeforeQuitDialog.popup_centered()
			break

func on_save_before_quit_no():
	get_tree().quit()
