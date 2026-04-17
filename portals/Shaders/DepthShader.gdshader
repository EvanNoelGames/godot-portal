shader_type spatial;
// tells godot to keep the fullscreen quad from being affected by lighting and fog
render_mode unshaded, fog_disabled, blend_mix, depth_test_disabled;

#define ITime TIME
#define fragColor COLOR

#define SAMPLES 12
#define ANGLE_SAMPLES (3 * SAMPLES)
#define OFFSET_SAMPLES (1 * SAMPLES)

// this lets us read from the depth texture
uniform sampler2D depth_texture : hint_depth_texture, repeat_disable, filter_nearest;

// access the rendered contents of the screen to measure pixel distance
uniform sampler2D screen_texture : hint_screen_texture, repeat_enable, filter_linear; 

uniform vec3 focus_point; 

// anything below the min will be in focus
const float min_distance = 10.0;

// anything beyond the max will be out focus
const float max_distance = 20.0; 


vec2 rot2D(float offset, float angle)
{
	// convert the angle to radians
	angle = radians(angle);

	return vec2(cos(angle) * offset, sin(angle) * offset);
}

vec3 blur_effect (sampler2D sp, vec2 uv, vec2 scale, vec2 iRes)
{
	vec2 ps = (1.0 / iRes.xy) * scale;
	vec3 col = vec3(0.0);
	float accum = 0.0; 
	
	for (int a = 0; a < 360; a+= 360 / ANGLE_SAMPLES)
	{
		for (int o = 0; o < OFFSET_SAMPLES; ++o)
		{
			col += texture(sp, uv + ps * rot2D(float(o), float(a))).rgb * (float(o * o) + 1.5);
			accum += (float(o * o) + 1.5);
		}
	}
	
	return col / accum;
}


void vertex() {
	// Called for every vertex the material is visible on.
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
	// Called for every pixel the material is visible on.
	
	// take our screen space coords

	float depth = texture(depth_texture, SCREEN_UV, 0.0).r;
	
	// and change them to normalised device coords
	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, FRAGCOORD.z);
	
	// then convert thoose to view space
	vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	view.xyz /= view.w; 
	// the distance of the pixel from the camera 
	float linear_depth = -view.z;
	
	// world camera 
	vec4 world = INV_VIEW_MATRIX * INV_PROJECTION_MATRIX * vec4(ndc, 1.0); 
	vec3 world_position = world.xyz / world.w; 
	
	float unFocusedUV = 2.0;
	vec3 unFocusedTex = texture(depth_texture, UV + vec2(unFocusedUV)).rgb;
	
	float focusedUV = 16.0;
	vec3 focusTex = texture(screen_texture, SCREEN_UV).rgb;

	vec4 focus_in_view = VIEW_MATRIX * vec4(focus_point, 1.0);
	
	float blur = smoothstep( min_distance, max_distance, abs(view.z - focus_in_view.z));

	
	vec2 res = vec2(1.0 / VIEWPORT_SIZE);
	vec3 blured = blur_effect(screen_texture, SCREEN_UV, vec2(1.0, 1.0), VIEWPORT_SIZE);
	
	ALBEDO = mix(focusTex, blured, blur);
}
