extends Resource
class_name Enemy

@export var enemy_id: String
@export var enemy_name: String
@export_multiline var enemy_description: String
@export var enemy_scene: PackedScene

# STATS
@export var health: float = 100.0
# PLAYER ATTACKS THAT DEAL MORE DAMAGE - use weakness_modifier
@export_enum('blunt', 'slice', 'pierce', 'fire', 'ice', 'shock', 'wind', 'none') var weakness_type: String = 'none'
# PLAYER ATTACKS THAT DEALS LESS DAMAGE - use resistance_modifier
@export_enum('blunt', 'slice', 'pierce', 'fire', 'ice', 'shock', 'wind', 'none') var resistance_type: String = 'none'
@export var weakness_modifier: float = 0.0
@export var resistance_modifier: float = 0.0
