extends Control

@onready var tavern_btn: Button = $Center/VBox/Tavern
@onready var party_btn: Button = $Center/VBox/Party
@onready var status_btn: Button = $Center/VBox/Status
@onready var shop_btn: Button = $Center/VBox/Shop
@onready var inn_btn: Button = $Center/VBox/Inn
@onready var labyrinth_btn: Button = $Center/VBox/Labyrinth
@onready var guild_btn: Button = $Center/VBox/Guild

func _ready() -> void:
    tavern_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/Tavern.tscn"))
    party_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/Party.tscn"))
    status_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/Status.tscn"))
    shop_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/Shop.tscn"))
    inn_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/Inn.tscn"))
    labyrinth_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/Labyrinth.tscn"))
    guild_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/Guild.tscn"))

