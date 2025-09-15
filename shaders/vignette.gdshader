shader_type canvas_item;

// Radial vignette: darkens edges, keeps center brighter.
uniform float strength : hint_range(0.0, 1.0) = 0.5;
uniform float inner : hint_range(0.0, 1.0) = 0.45;
uniform float outer : hint_range(0.0, 1.0) = 0.98;

void fragment() {
    vec2 uv = UV * 2.0 - 1.0; // center at (0,0)
    float r = length(uv);
    float v = smoothstep(inner, outer, r);
    float a = v * strength;
    COLOR = vec4(0.0, 0.0, 0.0, a);
}

