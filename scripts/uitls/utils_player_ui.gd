extends Node

@export var catchup_timer: float = 0.6

@onready var healthbar_progress: TextureProgressBar = $PlayerHealth/HealthBarBG/HealthBarProgress
@onready var healthbar_fill: TextureProgressBar = $PlayerHealth/HealthBarBG/HealthBarProgress/HealthBarFill

@onready var armor_progress: TextureProgressBar = $PlayerArmor/ArmorBarBG/ArmorBarProgress
@onready var armor_fill: TextureProgressBar = $PlayerArmor/ArmorBarBG/ArmorBarProgress/ArmorBarFill

var p_health: float = 0
var p_armor: float = 0

func _init_player_ui(new_health: float, new_armor: float) -> void:
	p_health = new_health
	healthbar_progress.max_value = new_health
	healthbar_progress.value = new_health
	healthbar_fill.max_value = new_health
	healthbar_fill.value = new_health
	
	p_armor = new_armor
	armor_progress.max_value = new_armor
	armor_progress.value = new_armor
	armor_fill.max_value = new_armor
	armor_fill.value = new_armor

func _set_health(new_health: float) -> void:
	var prev_health = p_health
	p_health = min(healthbar_fill.max_value, new_health)
	
	var health_fill_tween = create_tween()
	health_fill_tween.tween_property(healthbar_fill, "value", p_health, 0.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	if p_health < prev_health:
		await get_tree().create_timer(catchup_timer).timeout
		var health_progress_tween = create_tween()
		health_progress_tween.tween_property(healthbar_progress, "value", p_health, 0.6).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func _set_armor(new_armor: float) -> void:
	var prev_armor = p_armor
	p_armor = min(armor_fill.max_value, new_armor)
	
	var armor_fill_tween = create_tween()
	armor_fill_tween.tween_property(armor_fill, "value", p_armor, 0.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	if p_armor < prev_armor:
		await get_tree().create_timer(catchup_timer).timeout
		var armor_progress_tween = create_tween()
		armor_progress_tween.tween_property(armor_progress, "value", p_armor, 0.6).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
