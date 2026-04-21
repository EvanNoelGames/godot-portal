shader_type spatial;
render_mode blend_mix;
uniform sampler2D depth_texture : hint_depth_texture, repeat_disable, filter_nearest;

uniform sampler2D noise_texture;
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
	
	vec2 tangent = normalize(portalUV);
	
	float ring1 = saturate((1.0 - length(portalUV)) * 20.0);
	
	float ring2 = saturate((length(portalUV * vec2(1.15, 1.125)) -1.025) * 20.0);
	
	float ring = min(ring1, ring2);
	
	vec2 polar = vec2((atan(portalUV.x, portalUV.y) / PI / 2.0 + 0.5) 
	* 1.0  + TIME * - 0.05 , length(portalUV) * 0.25 + TIME * - 0.01);
	
	// this needs to sample noise
	vec2 turbulence = texture(noise_texture, polar).xy * 2.0 - 1.0;
	
	// this samples the ring
	vec3 image = texture(viewport_texture, SCREEN_UV + turbulence * 0.005).rgb * 2.75; 
	
	// this samples what was rendered to the screen the past frame
	// only need this if i want it to distort what has already
	// been rendered to the screen
	//vec3 buffer = texture(viewport_texture, SCREEN_UV + turbulence * 0.0085 + vec2(tangent.y, -tangent.x) * vec2(2.65, 10.0) * 0.01).rgb * vec3(0.7, 0.75, 1.0);
	
	//vec3 col = mix(image, buffer, 0.75);
	ALPHA = ring;
	ALBEDO = image;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
