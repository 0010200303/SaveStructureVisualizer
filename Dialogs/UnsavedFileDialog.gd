extends ConfirmationDialog

signal discarded

func _ready():
	add_button("No", true, "no")
	
	connect("custom_action", Bruh)

func Bruh(action:StringName):
	if action == "no":
		emit_signal("discarded")
		hide()
