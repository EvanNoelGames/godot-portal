shader_type spatial;
render_mode blend_mix;



uniform sampler2D screen_texture : hint_screen_texture;
uniform sampler2D depth_texture : hint_depth_texture, repeat_disable, filter_nearest;

uniform sampler2D noise_texture;
uniform sampler2D viewport_texture; 

uniform vec2 portal_pos;
uniform float portal_distance;

//varying vec2 portal_pos; 


float saturate(float a)
{
	return clamp(a, 0.0, 1.0);
}

void vertex() {
	// Called for every vertex the material is visible on.

		vec4 clip_space = PROJECTION_MATRIX * MODELVIEW_MATRIX * vec4(VERTEX, 1.0);
	
		vec2 ndc = (clip_space.xy / clip_space.w) * 0.5 + 0.5;
		
		mat4 modified_model_view = VIEW_MATRIX * mat4 (
			INV_VIEW_MATRIX[0],
			INV_VIEW_MATRIX[1],
			INV_VIEW_MATRIX[2],
			MODEL_MATRIX[3]
		);
		MODELVIEW_MATRIX = modified_model_view;
		
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, FRAGCOORD.z);
	
	
	// need the uv
	vec2 portalUV = (SCREEN_UV - portal_pos) * vec2(8.0, 2.5) * portal_distance * 0.6;
	
	vec2 remapped_portal_uv = portalUV * 0.5 + 0.5;
	
	vec2 tangent = normalize(portalUV);
	
	float ring1 = saturate((1.0 - length(portalUV)) * 40.0);
	
	float ring2 = saturate((length(portalUV * vec2(1.15, 1.125)) -1.025) * 40.0);
	
	float ring = min(ring1, ring2);
	
	vec2 polar = vec2((atan(portalUV.x, portalUV.y) / PI / 2.0 + 0.5) 
	* 1.0  + TIME * - 0.05 , length(portalUV) * 0.25 + TIME * - 0.01);
	
	
	// this needs to sample noise
	vec2 turbulence = texture(noise_texture, polar).xy * 2.0 - 1.0;
	
	// this samples the ring
	vec3 image = ring * vec3(0.0, 0.0, 0.0); 
	
	
	vec2 offsetUV = portalUV + vec2(tangent.y, -tangent.x) * 0.1 + turbulence * 0.3;
	
	float offset_ring1 = saturate((1.0 - length(offsetUV)) * 20.0);
	
	float offset_ring2 = saturate((length(offsetUV * vec2(1.15, 1.125)) -1.025) * 20.0);
	
	float new_ring = min(offset_ring1, offset_ring2);
	
	vec3 buffer = new_ring * vec3(1.0, 0.4 , 0.0) * vec3(1.0, 0.4 , 0.0);

	vec3 col = mix(image, buffer, 1.0);
	ALPHA = ring;
	ALBEDO = col;

}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
