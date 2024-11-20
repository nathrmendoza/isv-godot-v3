extends Node

signal on_ingredient_update(ingredient_name, new_amount)

var _ingredients = {
	"blunt": 26,
	"slash": 20,
	"pierce": 25,
	"wind": 12,
	"ice": 24,
	"shock": 13,
	"fire": 5
}

func _add_ingredient(name: String, amount: int) -> void: 
	if _ingredients.has(name):
		_ingredients[name] += amount
		on_ingredient_update.emit(name, _ingredients[name])

func _remove_ingredient(name: String, amount: int) -> void:
	if _ingredients.has(name) and _ingredients[name] >= amount:
		_ingredients[name] -= amount
		on_ingredient_update.emit(name, _ingredients[name])

func _get_ingredient_amount(name: String) -> int:
	return _ingredients.get(name, 0) 
