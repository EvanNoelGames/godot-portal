shader_type spatial;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture;
uniform sampler2D portal_texture;

void fragment() {
    ALBEDO = texture(portal_texture, SCREEN_UV).rgb;
}