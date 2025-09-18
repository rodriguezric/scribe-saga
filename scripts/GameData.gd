extends Node

const CLASS_DEFS := {
    "Warrior": {
        "desc": "Frontline fighter with high HP and Strength.",
        "stats": {
            "HP": 60, "MP": 5,
            "Strength": 14, "Dexterity": 10, "Intelligence": 6,
            "Will": 8, "Vitality": 14, "Agility": 10, "Speed": 9
        }
    },
    "Templar": {
        "desc": "Holy knight balancing melee and blessings.",
        "stats": {
            "HP": 55, "MP": 15,
            "Strength": 12, "Dexterity": 9, "Intelligence": 9,
            "Will": 12, "Vitality": 12, "Agility": 9, "Speed": 8
        }
    },
    "Rogue": {
        "desc": "Agile specialist, excels at accuracy and evasion.",
        "stats": {
            "HP": 45, "MP": 8,
            "Strength": 10, "Dexterity": 14, "Intelligence": 8,
            "Will": 8, "Vitality": 9, "Agility": 14, "Speed": 13
        }
    },
    "Taoist": {
        "desc": "Mystic adept with balanced spiritual power.",
        "stats": {
            "HP": 40, "MP": 30,
            "Strength": 7, "Dexterity": 10, "Intelligence": 13,
            "Will": 13, "Vitality": 8, "Agility": 10, "Speed": 10
        }
    },
    "Mage": {
        "desc": "Glass cannon with powerful magic.",
        "stats": {
            "HP": 35, "MP": 40,
            "Strength": 6, "Dexterity": 9, "Intelligence": 15,
            "Will": 12, "Vitality": 7, "Agility": 10, "Speed": 10
        }
    }
}

var roster: Array = [] # Array[Character]

func create_character(char_name: String, klass: String) -> Resource:
    var defs: Dictionary = CLASS_DEFS.get(klass, {})
    var stats: Dictionary = defs.get("stats", {})
    var c: Resource = load("res://scripts/Character.gd").new()
    c.name = char_name
    c.klass = klass
    c.stats = stats.duplicate(true)
    roster.append(c)
    return c

func get_class_names() -> PackedStringArray:
    return PackedStringArray(CLASS_DEFS.keys())

func get_class_stats(klass: String) -> Dictionary:
    var defs: Dictionary = CLASS_DEFS.get(klass, {})
    return defs.get("stats", {})

func get_class_desc(klass: String) -> String:
    var defs: Dictionary = CLASS_DEFS.get(klass, {})
    return String(defs.get("desc", ""))
