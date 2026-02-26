shader_type canvas_item;

uniform vec2 player_pos = vec2(0.5, 0.5);
uniform float radius = 200.0;
uniform float softness = 30.0;
uniform vec4 fog_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

void fragment() {
    vec2 frag = FRAGCOORD.xy;
    float d = distance(frag, player_pos);

    float a = smoothstep(radius, radius + softness, d);

    COLOR = vec4(fog_color.rgb, fog_color.a * a);
}