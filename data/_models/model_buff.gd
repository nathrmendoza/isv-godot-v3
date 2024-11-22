extends Resource
class_name Buff

@export_enum("damage_reduction", "damage_increase", "speed_up", "iron_stomach") var buff_type: String = "dr"
@export var buff_name: String = "Damage Reduction"
@export_range(0, 1, 0.05) var modifier: float = 0.15
