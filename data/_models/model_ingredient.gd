extends Resource
class_name Ingredient

@export var ingredient_id: String
@export var ingredient_name: String
@export_multiline var description: String

# STATS
@export_enum('blunt', 'slice', 'pierce', 'fire', 'ice', 'shock', 'wind', 'heal', 'shield') var effect_type: String = 'blunt'
@export var raw_power: float = 0.0
@export var cooked_power: float = 0.0
@export_range(1.0, 20.0, 0.5) var cook_timer: float = 3.0
