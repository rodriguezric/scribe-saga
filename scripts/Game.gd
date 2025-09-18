extends Control

@onready var message_window: Node = $MessageWindow
@onready var continue_button: Button = $ContinueButton

func _ready() -> void:
    continue_button.visible = false
    if message_window.has_signal("continue_available"):
        message_window.connect("continue_available", Callable(self, "_on_continue_available"))
    continue_button.pressed.connect(_on_continue_pressed)

func _on_continue_available(available: bool) -> void:
    continue_button.visible = available
    if available:
        # Update label based on whether there is more story or we're done
        var more: bool = false
        if message_window.has_method("has_more"):
            more = bool(message_window.call("has_more"))
        continue_button.text = "Continue" if more else "Enter Town"
        continue_button.grab_focus()

func _on_continue_pressed() -> void:
    _uib().play_select()
    var more: bool = false
    if message_window.has_method("has_more"):
        more = bool(message_window.call("has_more"))
    if more:
        if message_window.has_method("advance"):
            message_window.call("advance")
    else:
        get_tree().change_scene_to_file("res://scenes/Town.tscn")

func _uib() -> Node:
    return get_node("/root/UIBus")
