shader_type spatial;
render_mode blend_mix, unshaded;

uniform sampler2D noise_texture;
uniform vec2 portal_size;
uniform vec3 portal_color : source_color;

float saturate(float a)
{
	return clamp(a, 0.0, 1.0);
}

void fragment() {
	// need the uv
	vec2 portalUV = (UV - 0.5) * portal_size;
	
	vec2 tangent = normalize(portalUV);
	
	float ring1 = saturate((1.0 - length(portalUV)) * 40.0);
	
	float ring2 = saturate((length(portalUV * vec2(1.15, 1.125)) -1.025) * 40.0);
	
	float ring = min(ring1, ring2);
	
	vec2 polar = vec2((atan(portalUV.x, portalUV.y) / PI / 2.0 + 0.5) 
	* 1.0  + TIME * - 0.05 , length(portalUV) * 0.25 + TIME * - 0.01);
	
	// this needs to sample noise
	vec2 turbulence = texture(noise_texture, polar).xy * 2.0 - 1.0;
	
	vec2 offsetUV = portalUV + vec2(tangent.y, -tangent.x) * 0.1 + turbulence * 0.3;
	
	float offset_ring1 = saturate((1.0 - length(offsetUV)) * 20.0);
	float offset_ring2 = saturate((length(offsetUV * vec2(1.15, 1.125)) -1.025) * 20.0);
	
	float new_ring = min(offset_ring1, offset_ring2);
	
	vec3 col = new_ring * vec3(1.0, 1.0, 1.0);
	
	ALPHA = ring;
	ALBEDO = col * portal_color + (portal_color * 0.5);
}
