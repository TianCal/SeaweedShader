// A one-liner hash function widely used in ShaderToy.
float hash(float n) { 
    return fract(sin(n)*753.5453123);
}

// A one-liner seeded random number generator widely used in ShaderToy.
float rand(float co){
    return fract(sin(dot(vec2(co, co), vec2(12.9898, 78.233))) * 43758.5453);
}

// A one-liner seeded random number generator widely used in ShaderToy.
float randVec2(in vec2 co){
    return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

float rand_range(float seed, float low, float high) {
    return mix(low, high, rand(seed));
}

// From the Book of Shaders https://thebookofshaders.com/13/
float noise (in vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    // Four corners in 2D of a tile
    float a = randVec2(i);
    float b = randVec2(i + vec2(1.0, 0.0));
    float c = randVec2(i + vec2(0.0, 1.0));
    float d = randVec2(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(a, b, u.x) +
            (c - a)* u.y * (1.0 - u.x) +
            (d - b) * u.x * u.y;
}

float fbm (in vec2 st) {
    float ret = 0.0;
    float amplitude = .5;
    float gain = 0.5;
    float lacunarity = 2.0;
    float frequency = 0.;
    int octaves = 5;
    for (int i = 0; i < octaves; i++) {
        ret += amplitude * noise(st);
        st *= lacunarity;
        amplitude *= gain;
    }
    return ret;
}

vec4 grass(vec2 p, int i, vec2 q, float r) {
    float height = rand_range(float(i+17), 0.1, 0.9);
    float max_curve = 1.0 - height + 0.40;
    float curve = rand_range(float(i+1), -max_curve, max_curve);
    vec2 pos = vec2(rand_range(float(i+3),-0.35,0.35 ), 0.0);
    
    pos = q + pos;
    pos.y += 0.5; 

    r = r * (1.0 - 1.0 * smoothstep(0.8*height, height, pos.y)); 
    float s = sign(curve);
    float grass_curve = abs(pos.x - s* pow( curve*( pos.y),2.0));
    float width = 0.005 * cos((pos.y - iTime / 25. + rand(float(i+3)) * 10.) * 73.) + 0.025*rand(float(i+3));
    width *= (1.0 - 1.1 * smoothstep(0.8*height, height, pos.y)); 
    float res = smoothstep(r, r + 0.008 + width, grass_curve);
    float inner_r = r/20.;
    float width_inner = 0.004 * cos((pos.y) * 17.+ rand(float(i+3)) * 10.);
    width_inner *= (1.0 - 1.1 * smoothstep(0.8*height, height, pos.y));
    float inner_res = smoothstep(inner_r, inner_r+ 0.008 + width_inner, grass_curve);

    // Color of the grass
    vec3 col = vec3(102./255., rand_range(float(i-10),0.55,0.65) ,51./255.);
    col = col - vec3(0.0,0.10,0.0)* (1.0-smoothstep(0.0, r,grass_curve));

    // FBM noise. 
    float f = fbm(100. * vec2(p.x * 3., p.y * .2));
    col = mix(col - vec3(0.0,0.03,0.0) , col + vec3(0.0,0.03,0.0) ,f);

    // This part is for the inner grass
    if (inner_res <1.) col /= 1.5;
    // Simply to kill the grass higher than maximum height
    if (pos.y > height) return vec4(col,1.1);
    return vec4(col, res);
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord/iResolution.xy;
    vec2 p = fragCoord/iResolution.xy;
    uv -= 0.5;
    float d = uv.y;
    float c = d;
    float r = -0.15;
    c = smoothstep(r, r - 0.15, d);
    vec3 ground = vec3(c)* vec3(0.76, 0.69, 0.50) * (0.75 + 0.25 * cos(0.5 * iTime));;
    vec3 sky = vec3(1.0 - c)* vec3(0.1, 0.5, 0.90) * (0.75 + 0.25 * cos(0.5 * iTime));
    vec3 col = ground + sky;
    
    float y = p.y;
    float m = sin((y - iTime / 9.0) * 23.);
    float x = (p.x + (m / 120.)) ;
    vec2 newp = vec2(x, y);
    for(int i = 0; i < 25; i ++){
        float radius = rand_range(float(i), 0.03, 0.04);
        vec4 grassouter = grass(newp, i, newp-.5, radius);
        if (grassouter.w < 1.) {
            col = grassouter.xyz;
        }
    }
    fragColor = vec4(col, 1.0);
}