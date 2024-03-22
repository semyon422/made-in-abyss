uniform sampler2D colormap;
uniform sampler2D heightmap;

uniform vec3 sunPos;
const float shadowBrightness = 0.5;
const int STEPS = 200;
const float height_offset = 128.0 * 256.0 / 255.0;

float get_height(vec4 hm) {
	return hm.r + hm.g * 256.0 - height_offset;
}

vec4 effect(vec4 color, Image texture, vec2 pos, vec2 pixel_coords) {
	float hgt = get_height(texture2D(heightmap, pos));

	vec3 p = vec3(pos, hgt);

	vec3 sunDir = sunPos - vec3(0.5, 0.5, sunPos.z - 1.0);
	// vec3 sunDir = sunPos - p;
	vec3 stepDir = sunDir / float(STEPS);

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

	return mix(col, shadowCol, inShadow);
}

