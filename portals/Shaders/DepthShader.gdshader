shader_type spatial;
// tells godot to keep the fullscreen quad from being affected by lighting and fog
render_mode unshaded, fog_disabled;

// this lets us read from the depth texture
uniform sampler2D depth_texture : hint_depth_texture;

void vertex() {
	// Called for every vertex the material is visible on.
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
	

}

void fragment() {
	// Called for every pixel the material is visible on.
	
	// take our screen space coords
	float depth = texture(depth_texture, SCREEN_UV).x;
	
	// and change them to normalised device coords
	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
	
	// then convert thoose to view space
	vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	view.xyz /= view.w; 
	float linear_depth = -view.z;
	
	vec4 world = INV_VIEW_MATRIX * INV_PROJECTION_MATRIX * vec4(ndc, 1.0); 
	vec3 world_position = world.xyz / world.w; 
	
	//ALBEDO.rgb = vec3(fract(linear_depth));
	// now figure out how to calculate the distance from a pixel to the camera
	
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
