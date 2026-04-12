shader_type spatial;
// tells godot to keep the fullscreen quad from being affected by lighting and fog
render_mode unshaded, fog_disabled;

// this lets us read from the depth texture
uniform sampler2D depth_texture : hint_depth_texture, repeat_disable, filter_nearest;

// access the rendered contents of the screen to measure pixel distance
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest; 

// anything below the min will be in focus
const float min_distance = 1.0;

// anything beyond the max will be out focus
const float max_distance = 50.0; 

void vertex() {
	// Called for every vertex the material is visible on.
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
	

}

void fragment() {
	// Called for every pixel the material is visible on.
	
	// take our screen space coords
	//float depth = texture(depth_texture, SCREEN_UV).x;
	float depth = textureLod(depth_texture, SCREEN_UV, 0.0).r;
	
	
	// and change them to normalised device coords
	//vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, FRAGCOORD.z);
	
	// then convert thoose to view space
	vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	view.xyz /= view.w; 
	// the distance of the pixel from the camera 
	float linear_depth = -view.z;
	
	vec4 world = INV_VIEW_MATRIX * INV_PROJECTION_MATRIX * vec4(ndc, 1.0); 
	vec3 world_position = world.xyz / world.w; 
	
	float unFocusedUV = 2.0;
	vec3 unFocusedTex = texture(depth_texture, UV * unFocusedUV).rgb;
	
	float focusedUV = 16.0;
	vec3 focusTex = texture(depth_texture, UV * focusedUV).rgb;
	
	
	float blur = smoothstep( min_distance, max_distance, distance(view.xyz, world_position));
	
	
	//ALBEDO = vec3(fract(linear_depth));
	// used to make everything blury not based on distance
	//ALBEDO = vec3(linear_depth / 50.0);
	
	ALBEDO = mix(focusTex, unFocusedTex, blur);

}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
