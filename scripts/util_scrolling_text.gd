extends Panel

signal on_next_panel
signal on_finished

@export_multiline var text_paragraphs: Array[String]
@export var characters_per_second: float = 45.0

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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rich_text_label.text = ""
	if animate_in:
		input_disabled = true
		_hide_panel()
		if delay_animate_in > 0.0:
			await get_tree().create_timer(delay_animate_in).timeout
		
		anim_player.current_animation = 'prompt_enter_anim'
		await anim_player.animation_finished
		input_disabled = false

	if text_paragraphs.size() > 0:
		_start_typing(text_paragraphs[current_paragraph_index])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_typing:
		current_time += delta
		var type_ratio = current_time / type_duration
		if type_ratio >= 1.0:
			_finish_typing()
		else:
			rich_text_label.visible_ratio = type_ratio

func _start_typing(paragraph: String) -> void:
	is_typing = true
	current_time = 0.0
	type_duration = len(paragraph) / characters_per_second
	rich_text_label.visible_ratio = 0.0
	rich_text_label.text = paragraph

func _finish_typing() -> void:
	is_typing = false
	rich_text_label.visible_ratio = 1.0

func _toggle_next_paragraph(event: InputEvent) -> void:
	if input_disabled: return
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		if is_typing:
			_finish_typing()
		else:
			current_paragraph_index += 1
			if current_paragraph_index >= text_paragraphs.size():
				input_disabled = true
				emit_signal("on_finished")
				if animate_out:
					_show_panel()
					anim_player.current_animation = 'prompt_exit_anim'
					await anim_player.animation_finished
					queue_free()
			else: 
				emit_signal("on_next_panel")
				_start_typing(text_paragraphs[current_paragraph_index])

func _hide_panel() -> void:
	modulate.a = 0.0
	panel_background.material.set('main_alpha', 0.0)

func _show_panel() -> void:
	modulate.a = 1.0
	panel_background.material.set('main_alpha', 1.0)
