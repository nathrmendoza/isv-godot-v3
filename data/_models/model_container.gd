extends Resource
class_name IngredientContainer

@export var container_texture: CompressedTexture2D
@export_enum("blunt", "slash", "pierce", "fire", "ice", "wind", "shock") var ingredient_id: String
@export var ingredient_scene: PackedScene
@export_range(0, 2, 0.1) var pop_cooldown: float = 0.8
@export_enum("straight", "left", "right") var pop_direction: String = "straight"
@export_range(500, 1250, 10) var pop_strength: int = 750
