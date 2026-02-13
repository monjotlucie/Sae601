shader_type canvas_item;

uniform float wave_speed = 2.0;
uniform float wave_strength = 5.0;
uniform float wave_frequency = 20.0;
uniform vec4 water_color : source_color = vec4(0.1, 0.4, 0.9, 0.5);

void fragment() {

    vec2 uv = UV;
   
	
	float surface = sin(uv.x * 20.0 + TIME * wave_speed) * 0.02;

    if (uv.y < 0.1 + surface) {
        COLOR = vec4(1.0, 1.0, 1.0, 0.2); // mousse
    } else {
        COLOR = water_color;
    }


}
