shader_type canvas_item;

// Subtle animated wavy lines. Keep alpha low to avoid distraction.
uniform vec4 line_color : source_color = vec4(1.0, 1.0, 1.0, 0.07);
uniform float amplitude = 0.02;   // Wave height in UV space
uniform float frequency = 2.5;    // Number of waves across the screen
uniform float speed = 0.2;        // Animation speed
uniform float thickness = 0.08;   // Stripe thickness (0..1)

void fragment() {
    vec2 uv = UV;
    float t = TIME * speed;
    float wave = sin((uv.x * 6.2831853 * frequency) + t) * amplitude;
    float pos = uv.y + wave;
    float f = abs(fract(pos * 10.0) - 0.5); // 10 stripes vertically
    float d = f * 2.0;
    float line = 1.0 - smoothstep(0.0, thickness, d);
    COLOR = vec4(line_color.rgb, line_color.a * line);
}

