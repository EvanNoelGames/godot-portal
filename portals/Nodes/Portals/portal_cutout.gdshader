shader_type spatial;
render_mode unshaded, blend_mix;

uniform sampler2D screen_texture : hint_screen_texture;
uniform sampler2D portal_texture;

void fragment() {
	ALPHA = step(distance(UV, vec2(0.5, 0.5)), 0.5);
	ALBEDO = texture(portal_texture, SCREEN_UV).rgb;
}