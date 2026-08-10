shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    vec4 c = texture(SCREEN_TEXTURE, SCREEN_UV);
    // Invert colors to turn dark backgrounds light
    vec3 light_mode = vec3(1.0) - c.rgb;
    // Mix with a light tint (0.9) to control maximum brightness
    COLOR = vec4(mix(light_mode, vec3(0.9), 0.5), c.a);
}