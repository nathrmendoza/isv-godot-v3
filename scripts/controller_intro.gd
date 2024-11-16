extends Node2D

@onready var anim_player: AnimationPlayer = $AnimationPlayer

@onready var main_control: Control = $CanvasLayer/Control
@onready var prompt: TextureRect = $CanvasLayer/Control/TextPrompt
@onready var rich_text: RichTextLabel = $CanvasLayer/Control/TextPrompt/MarginContainer/RichTextLabel
@onready var panels: Array = [
	$CanvasLayer/Control/Panel1,
	$CanvasLayer/Control/Panel2,
	$CanvasLayer/Control/Panel3
]
var current_panel = 0

const CHARACTERS_PER_SECOND: float = 45.0
const STORY_PARAGRAPHS: Array[String] = [
	"Virgilio was just a regular guy, running his street food cart in the lively streets of Manila. Every day, he grilled skewers, served up snacks, and chatted with his customers under the warm glow of string lights. Cooking was his passion, and sharing his food made him happy. Life was simple, and he liked it that way. But one strange night, something happened that would change everything.",
	"A mysterious customer handed him an odd-looking coin, unlike anything he'd seen before. When he flipped it, the coin lit up like a firework, and in an instant, a swirling portal appeared. Before Virgilio could react, he was pulled through it, leaving behind the familiar sounds and smells of his world. When he landed, he found himself in a strange forest full of glowing plants, weird creatures, and a sky that looked nothing like home.",
	"Just as panic set in, Virgilio spotted something familiar—his food cart. But it wasn’t exactly the same. Strange symbols were etched into the wood, and it seemed to hum with a faint magical energy. Confused but relieved, he decided to rely on what he knew best—cooking. Little did he know, this cart might be the key to surviving in this strange new world."
]

var current_time: float = 0.0
var is_typing: bool = false
var type_duration: float = 0.0

func _ready() -> void:
	#disable click interaction
	main_control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	#init scene transition fade in
	anim_player.current_animation = 'scene_fade_in'
	anim_player.play()
	
	for panel in panels:
		panel.visible = false
		panel.modulate = Color(0,0,0,1)
		
	# set first panel as active panel
	panels[0].visible = true	
	panels[0].modulate = Color(1,1,1,1)
	
	await anim_player.animation_finished
	
	#enable click interaction
	main_control.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# set first story paragraph active
	_start_animation(STORY_PARAGRAPHS[0])

func _process(delta: float) -> void:
	if is_typing:
		current_time += delta
		var type_ratio = current_time / type_duration
		if type_ratio >= 1.0:
			_finish_animation()
		else:
			rich_text.visible_ratio = type_ratio

func _next_panel() -> void:
	# disable clicks on control
	main_control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	if current_panel >= (panels.size() - 1): 
		# play fade out scene transition
		anim_player.current_animation = 'scene_fade_out'
		anim_player.play()
		
		#when transition finished load prototype level
		await anim_player.animation_finished
		get_tree().change_scene_to_file("res://scenes/levels/prototype_level.tscn")
		return
	
	current_panel += 1
	
	var bg_tween = create_tween()
	bg_tween.tween_property(panels[current_panel - 1], 'modulate', Color(0,0,0,1), 0.6).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	bg_tween.chain().tween_callback(func(): 
		panels[current_panel - 1].visible = false
		panels[current_panel].visible = true
	)
	bg_tween.chain().tween_property(panels[current_panel], 'modulate', Color(1,1,1,1), 0.6).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	bg_tween.chain().tween_callback(func(): 
		# disable clicks on control
		main_control.mouse_filter = Control.MOUSE_FILTER_STOP	
	)
	
	var prompt_tween = create_tween()
	prompt_tween.tween_property(prompt, 'modulate:a', 0.0, 0.6).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	prompt_tween.chain().tween_callback(func(): 
		_start_animation(STORY_PARAGRAPHS[current_panel])	
	)
	prompt_tween.chain().tween_property(prompt, 'modulate:a', 1.0, 0.6).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

func _start_animation(new_text: String) -> void:
	is_typing = true
	current_time = 0.0
	rich_text.visible_ratio = 0.0
	rich_text.text = new_text
	type_duration = len(new_text) / CHARACTERS_PER_SECOND

func _finish_animation() -> void:
	is_typing = false
	rich_text.visible_ratio = 1.0
	pass

func _on_control_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			if is_typing:
				_finish_animation()
			else:
				_next_panel()
