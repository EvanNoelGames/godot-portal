shader_type spatial;
render_mode unshaded;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D NORMAL_TEXTURE : hint_normal_roughness_texture, filter_linear;
uniform sampler2D DEPTH_TEXTURE : source_color, hint_depth_texture;

uniform float depth_range:hint_range(0.1, 100, 0.1);
uniform vec3 fog_color:source_color;

void vertex(){
	POSITION = vec4(VERTEX, 1.0);
}

void fragment(){
	vec2 uv = SCREEN_UV;
	
	vec3 screen_color = texture(SCREEN_TEXTURE, uv).rgb;
	vec3 normal = texture(NORMAL_TEXTURE, uv).rgb;
	float roughness = texture(NORMAL_TEXTURE, uv).w;
	
	float depth = texture(DEPTH_TEXTURE, uv).x;
	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
	
	//Get view projection
	vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	
	//Convert to Normalized device coordinates
	view.xyz / view.x;
	
	float linear_depth = -view.z / depth_range;
	
	vec3 fog = vec3(linear_depth);
	
	vec3 finalColor = (fog + screen_color) * fog_color;
	
	ALBEDO = finalColor;
}