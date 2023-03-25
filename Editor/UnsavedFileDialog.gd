extends ConfirmationDialog

func _ready():
	add_button("Cancel", true, "cancel")
	
	connect("custom_action", Bruh)

func Bruh(action:StringName):
	if action == "cancel":
		hide()
