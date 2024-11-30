extends Resource
class_name EnemyActions

@export var action_name: String = 'Tail Whip'
@export_multiline var action_description: String

@export_enum('damage', 'buff') var action_type: String = 'damage'
@export var damage_power: float = 75.0

@export var buff: Buff = null
@export var debuff: Debuff = null
@export_enum('monster', 'player') var debuff_target = 'player'

@export_enum('attacking', 'attacking_alt', 'buffing', 'special') var animation_state = 'attacking'
