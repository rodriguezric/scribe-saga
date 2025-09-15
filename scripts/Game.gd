extends Control

@onready var message_window: Node = $MessageWindow
@onready var continue_button: Button = $ContinueButton
@onready var select_sfx: AudioStreamPlayer = $SelectSFX

func _ready() -> void:
    continue_button.visible = false
    if message_window.has_signal("continue_available"):
        message_window.connect("continue_available", Callable(self, "_on_continue_available"))
    continue_button.pressed.connect(_on_continue_pressed)

func _on_continue_available(available: bool) -> void:
    continue_button.visible = available
    if available:
        continue_button.grab_focus()

func _on_continue_pressed() -> void:
    if is_instance_valid(select_sfx):
        # Restart the select sound for quick repeated clicks
        if select_sfx.playing:
            select_sfx.stop()
        select_sfx.play()
    if message_window.has_method("advance"):
        message_window.call("advance")
