extends Panel

signal on_next_panel(index: int)
signal on_just_finished_typing
signal on_finished

@export_multiline var text_paragraphs: Array[String]
@export var characters_per_second: float = 45.0
@export var next_panel_delay: float = 0.0

@export var animate_in: bool = false
@export var delay_animate_in: float = 0.0
@export var animate_out: bool = false
@export var delay_animate_out: float = 0.0

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var rich_text_label: RichTextLabel = $MarginContainer/RichTextLabel
@onready var panel_background: ColorRect = $PanelBackground

var input_disabled: bool = false
var current_paragraph_index: int = 0
var current_time: float = 0.0
var is_typing: bool = false
var type_duration: float = 0.0


func _ready() -> void:
	rich_text_label.text = ""
	if animate_in:
		input_disabled = true
		_toggle_hide_show_panel(false)
		if delay_animate_in > 0.0:
			await get_tree().create_timer(delay_animate_in).timeout
		
		anim_player.current_animation = 'prompt_enter_anim'
		await anim_player.animation_finished
		input_disabled = false

	if text_paragraphs.size() > 0:
		_start_typing(text_paragraphs[current_paragraph_index])


func _process(delta: float) -> void:
	if is_typing:
		current_time += delta
		var type_ratio = current_time / type_duration
		if type_ratio >= 1.0:
			on_just_finished_typing.emit()
			_finish_typing()
		else:
			rich_text_label.visible_ratio = type_ratio


func _start_typing(paragraph: String) -> void:
	is_typing = true
	current_time = 0.0
	type_duration = len(paragraph) / characters_per_second
	rich_text_label.visible_ratio = 0.0
	rich_text_label.text = paragraph
	on_next_panel.emit()


func _finish_typing() -> void:
	is_typing = false
	rich_text_label.visible_ratio = 1.0


func _toggle_next_paragraph(event: InputEvent) -> void:
	if input_disabled: return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		if is_typing:
			on_just_finished_typing.emit()
			_finish_typing()
		else:
			current_paragraph_index += 1
			if current_paragraph_index >= text_paragraphs.size():
				input_disabled = true
				on_finished.emit()
				
				if animate_out:
					_toggle_hide_show_panel(true)
					anim_player.current_animation = 'prompt_exit_anim'
					await anim_player.animation_finished
					queue_free()
			else: 
				_start_typing(text_paragraphs[current_paragraph_index])


func _toggle_hide_show_panel(toggle_bool: bool = true) -> void:
	if toggle_bool:
		modulate.a = 1.0
		panel_background.material.set('main_alpha', 1.0)
	else:
		modulate.a = 0.0
		panel_background.material.set('main_alpha', 0.0)


func _toggle_input(toggle_bool: bool = true) -> void:
	if toggle_bool:
		input_disabled = false
	else:
		input_disabled = true
