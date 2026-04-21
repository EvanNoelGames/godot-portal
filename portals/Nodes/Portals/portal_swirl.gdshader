shader_type spatial;

render_mode blend_mix;

uniform sampler2D depth_texture : hint_depth_texture, repeat_disable, filter_nearest;

uniform sampler2D viewport_texture; 

float saturate(float a)
{
	return clamp(a, 0.0, 1.0);
}

void vertex() {
	// Called for every vertex the material is visible on.
	//v_world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	// Called for every pixel the material is visible on.
	
	// need the uv
	vec2 portalUV = (SCREEN_UV - 0.5) * vec2(8.0, 2.5);
	
	float ring1 = saturate((1.0 - length(portalUV)) * 20.0);
	
	float ring2 = saturate((length(portalUV * vec2(1.15, 1.125)) -1.025) * 20.0);
	
	float ring = min(ring1, ring2);
	
	vec3 tex = texture(depth_texture, SCREEN_UV).rgb;
	
	ALPHA = ring;
	ALBEDO = ring * vec3(0.15, 0.75, 1.0);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
