shader_type canvas_item;

uniform float main_alpha: hint_range(0.0, 1.0) = 1.0;
uniform float lod: hint_range(0.0, 10.0) = 0.0;
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;
uniform float mix_amount: hint_range(0.0, 1.0);
uniform vec4 backdrop_color: source_color;

void fragment() {
	vec4 blurred = texture(SCREEN_TEXTURE, SCREEN_UV, lod);
	vec4 fin = mix(blurred, backdrop_color, mix_amount);
	COLOR = fin;
	COLOR.a = main_alpha;
}