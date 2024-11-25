shader_type canvas_item;

uniform float browning_noise_amount : hint_range(0.0, 1.0, 0.01) = 0.0;
uniform float sizzle_amount : hint_range(0.0, 1.0, 0.01) = 0.0;
uniform float bubble_amount : hint_range(0.0, 1.0, 0.01) = 0.0;
uniform float heat_amount : hint_range(0.0, 1.0, 0.01) = 0.0;
uniform sampler2D noise_texture;
uniform float time;

void fragment() {
	vec2 uv = UV;
	
	if (sizzle_amount > 0.0) {
		vec2 distorted_uv = UV;
	    distorted_uv.x += sin(UV.y * 10.0 + time * 2.0) * 0.01 * sizzle_amount;
	    distorted_uv.y += cos(UV.x * 10.0 + time * 2.0) * 0.01 * sizzle_amount;
	}
	
	if (bubble_amount > 0.0) {
		
	}
	
	vec4 color = texture(TEXTURE, uv);
	
	if (browning_noise_amount > 0.0) {
		vec4 original = texture(TEXTURE, UV);
		vec4 noise = texture(noise_texture, UV);
		
		vec4 cooked_color = vec4(0.4, 0.2, 0.0, original.a);
		vec4 charred_color = vec4(0.1, 0.1, 0.1, original.a);
		
		float cook_noise = noise.r * browning_noise_amount;
		color = mix(original, mix(cooked_color, charred_color, cook_noise), cook_noise);
	}
	
	COLOR = color;
}