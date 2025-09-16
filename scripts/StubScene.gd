extends Control

@onready var back_button: Button = $Center/VBox/BackButton

func _ready() -> void:
    back_button.pressed.connect(_on_back_pressed)

func _on_back_pressed() -> void:
    get_tree().change_scene_to_file("res://scenes/Town.tscn")

