extends Resource
class_name EnemyActions

@export var action_name: String = 'Tail Whip'
@export_multiline var action_description: String
@export var damage_power: int = 25

@export var buff: Buff = null
@export var debuff: Debuff = null
@export_enum('monster', 'player') var debuff_target = 'player'
