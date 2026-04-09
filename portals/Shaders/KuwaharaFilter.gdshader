shader_type spatial;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D NORMAL_TEXTURE : hint_normal_roughness_texture, filter_linear;
uniform sampler2D DEPTH_TEXTURE : source_color, hint_depth_texture;

uniform int blurRadius = 5;
uniform vec3 offset = vec3(0.0);

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
	
	vec2 screenSize = VIEWPORT_SIZE;
	float n = float((blurRadius + 1) * (blurRadius + 1));
	vec3 m0 = offset; 
	vec3 m1 = offset;
	vec3 m2 = offset;
	vec3 m3 = offset;
	vec3 s0 = offset;
	vec3 s1 = offset;
	vec3 s2 = offset;
	vec3 s3 = offset;
	
	vec3 c;
	
	
	//Iterate through kernel
	{
		for (int j = -blurRadius; j <= 0; ++j){
		for (int i = -blurRadius; i <= 0; ++i){
			c = texture(SCREEN_TEXTURE, uv + vec2(float(i), float(j)) * screenSize).rgb;
			m0 += c;
			s0 += c * c;
		}
		}
	
		for (int j = -blurRadius; j <= 0; ++j){
		for (int i = 0; i <= blurRadius; ++i){
			c = texture(SCREEN_TEXTURE, uv + vec2(float(i), float(j)) * screenSize).rgb;
			m1 += c;
			s1 += c * c;
		}
		}
	
		for (int j = 0; j <= blurRadius; ++j){
		for (int i = 0; i <= blurRadius; ++i){
			c = texture(SCREEN_TEXTURE, uv + vec2(float(i), float(j)) * screenSize).rgb;
			m2 += c;
			s2 += c * c;
		}
		}
	
		for (int j = 0; j <= blurRadius; ++j){
		for (int i = -blurRadius; i <= 0; ++i){
			c = texture(SCREEN_TEXTURE, uv + vec2(float(i), float(j)) * screenSize).rgb;
			m3 += c;
			s3 += c * c;
		}
		}
	}
	
	float minSigma2 = 1e+2;
	m0 /= n;
	s0 = abs(s0 / n - m0 * m0);
	
	//Get color average
	float sigma2 = s0.r + s0.g + s0.g;
	if (sigma2 < minSigma2){
		minSigma2 = sigma2;
		ALBEDO = vec3(m0);
	}
	
	
	
}