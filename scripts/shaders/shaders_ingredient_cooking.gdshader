shader_type canvas_item;

uniform float cook_progress : hint_range(0.0, 1.0) = 0.0;
uniform float heat_intensity : hint_range(0.0, 1.0) = 0.0;
uniform vec3 raw_color : source_color = vec3(1.0, 1.0, 1.0);
uniform vec3 medium_color : source_color = vec3(1.0, 0.9, 0.7);
uniform vec3 cooked_color : source_color = vec3(0.8, 0.6, 0.4);
uniform bool is_cooking = false;
uniform float fixed_time = 0.0;

float random(vec2 pos) {
   return fract(sin(dot(pos, vec2(12.9898, 78.233))) * 43758.5453123);
}

float value_noise(vec2 pos) {
    vec2 i = floor(pos);
    vec2 f = fract(pos);
    
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));
    
    vec2 u = smoothstep(0.0, 1.0, f);
    
    return mix(mix(a, b, u.x),
              mix(c, d, u.x), u.y);
}

vec2 warp(vec2 uv, float progress, float time_value) {
    vec2 warp_uv = uv;
    warp_uv.x += sin(uv.y * 12.0 + time_value * 3.0) * 0.02 * progress;
    warp_uv.y += cos(uv.x * 12.0 + time_value * 3.0) * 0.02 * progress;
    return warp_uv;
}

float heat_distortion(vec2 uv, float time_value) {
    return sin(uv.y * 50.0 + time_value * 2.50) * cos(uv.x * 50.0 + time_value * 2.50) * 0.004;
}

void fragment() {
    float time_value = is_cooking ? TIME : fixed_time;
    
    float noise_val = value_noise(UV * 50.0);
    float cooking_effect = noise_val * cook_progress;
    
    vec2 warped_uv = warp(UV, cook_progress, time_value);
    warped_uv += heat_distortion(UV, time_value) * heat_intensity;
    vec4 color = texture(TEXTURE, warped_uv);
    
    float local_progress = clamp(cook_progress + cooking_effect * 0.2, 0.0, 1.0);
    
    vec3 cook_tint;
    if(local_progress < 0.5) {
        cook_tint = mix(raw_color, medium_color, local_progress * 2.0);
    } else {
        cook_tint = mix(medium_color, cooked_color, (local_progress - 0.5) * 2.0);
    }
    
    cook_tint *= 1.0 - (cooking_effect * 0.1);
    color.rgb *= cook_tint;
    
    COLOR = color;
}