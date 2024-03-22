precision mediump float;
varying vec2 pos;

uniform sampler2D colormap;
uniform sampler2D heightmap;

uniform vec3 sunPos;
const float shadowBrightness = 0.5;
const int STEPS = 200;
const float height_offset = 128.0 * 256.0 / 255.0;

float get_height(vec4 hm) {
	return hm.r + hm.g * 256.0 - height_offset;
}

void main() {
	float hgt = get_height(texture2D(heightmap, pos));

	vec3 p = vec3(pos, hgt);

	vec3 sunDir = sunPos - vec3(0.5, 0.5, sunPos.z - 1.0);
	// vec3 sunDir = sunPos - p;
	vec3 stepDir = sunDir / STEPS;

	float inShadow = 0.;
	for (int i = 0; i < STEPS; i++) {
		p += stepDir;

		float h = get_height(texture2D(heightmap, p.xy));
		if (h > p.z) {
			inShadow = 1.;
			break;
		}
		if (p.z > 1.) {
			break;
		}
	}

	vec4 col = texture2D(colormap, pos);
	vec4 shadowCol = vec4(col.rgb * shadowBrightness, col.a);

	gl_FragColor = mix(col, shadowCol, inShadow);
}
