shader_type spatial;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D DEPTH_TEXTURE : source_color, hint_depth_texture;

uniform int blurRadius = 5;
uniform uint kernelSize = 5;
uniform vec3 offset = vec3(0.0);

const int Sectors = 8;

float calculateLuminance(vec3 color){
	return 0.2126 * color.r + 0.7152 * color.g + 0.0722 * color.b;
}

float gaussian(float sigma, vec2 position){
	return (1.0 / (2.0 * PI * sigma * sigma)) * exp(-((position.x * position.x + position.y * position.y) / (2.0 * sigma * sigma)));
}

vec4 sampleQuadrant(vec2 uv, vec2 pixelSize, int x1, int x2, int y1, int y2, float n){
	float luminanceSum = 0.0;
	float luminanceSum2 = 0.0;
	vec3 colorSum = vec3(0.0);
	
	for (int x = x1; x <= x2; ++x){
		for (int y = y1; y <= y2; ++y){
			vec3 c = texture(SCREEN_TEXTURE, uv + vec2(float(x),float(y)) * pixelSize).rgb;
			float l = calculateLuminance(c);
			luminanceSum += l;
			luminanceSum2 += l * l;
			colorSum += c;
		}
	}
	
	float average = luminanceSum / n;
	
	float standardDeviation = abs(luminanceSum2 / n - average * average);
	
	return vec4(colorSum / n, standardDeviation);
}

vec4 generalizedKuwahara(vec2 uv, float depth){
	vec4 m[8];
	vec3 s[8];
	int radius = int(kernelSize) / 2;
	
	//Number of sectors our circle filter will have 
	int n = Sectors;
	
	for (int k = 0; k < n; ++k){
		m[k] = vec4(0.0);
		s[k] = vec3(0.0);
	}
	
	float piN = 2.0 * PI / float(n);
	mat2 x = mat2(1.0);
	
	x[0][0] = cos(piN);
	x[0][1] = sin(piN);
	x[1][0] = -sin(piN);
	x[1][1] = cos(piN);
	
	for (int x = -radius; x <= radius; ++x){
		for (int y = -radius; y <= radius; ++y){
			vec2 v = 0.5 * vec2(float(x),float(y)) / float(radius);
			//Sample screen texture
			vec3 c = texture(SCREEN_TEXTURE, uv + vec2(float(x),float(y))).rgb;
			for (int k = 0; k < n; ++k){
				//Todo
			}
		}
	}
	
	return vec4(1.0);
}

void vertex(){
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment(){
	vec2 uv = SCREEN_UV;
	
	vec3 screen_color = texture(SCREEN_TEXTURE, uv).rgb;
	
	vec2 pixelSize = 1.0 / vec2(textureSize(SCREEN_TEXTURE, 0));
	
	float depth = texture(DEPTH_TEXTURE, uv).x;
	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
	
	//Get view projection
	vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	
	//Convert to Normalized device coordinates
	view.xyz / view.x;
	
	int radius = int(kernelSize) / 2;
	
	float windowSize = 2.0 * float(radius) + 1.0;
	
	int quadrantSize = int(ceil(windowSize / 2.0));
	
	int numSamples = quadrantSize * quadrantSize;
	
	vec4 q1 = sampleQuadrant(uv, pixelSize, -radius, 0, -radius, 0, float(numSamples));
	vec4 q2 = sampleQuadrant(uv, pixelSize, 0, radius, -radius, 0, float(numSamples));
	vec4 q3 = sampleQuadrant(uv, pixelSize, 0, radius, 0, radius, float(numSamples));
	vec4 q4 = sampleQuadrant(uv, pixelSize, -radius, 0, 0, radius, float(numSamples));
	
	//Get the quadrant with the smallest amount of standard deviation
	float minimumDeviation = min(q1.a, min(q2.a, min(q3.a, q4.a)));
	ivec4 q = ivec4(equal(vec4(q1.a, q2.a, q3.a, q4.a), vec4(minimumDeviation)));
	
	if (dot(vec4(q), vec4(1.0)) > 1.0){
		ALBEDO = vec3((q1.rgb + q2.rgb + q3.rgb + q4.rgb) / 4.0);
	}
	else{
		ALBEDO = vec3(q1.rgb * float(q.x) + q2.rgb * float(q.y) + q3.rgb * float(q.z) + q4.rgb * float(q.w));
	}
}