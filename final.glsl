float hash( float n ) { return fract(sin(n)*753.5453123); }

//A one-liner seeded random number generator widely used in ShaderToy.
float rand(float co){
    return fract(sin(dot(vec2(co ,co ) ,vec2(12.9898,78.233))) * 43758.5453);
}

float rand_range(float seed, float low, float high) {
    return mix(low, high, rand(seed));
    //return low + (high - low) * rand(seed);
}

vec3 rand_color(float seed, vec3 col, vec3 variation) {
    return vec3(
        col.x + rand_range(seed,-variation.x, +variation.x),
        col.y + rand_range(seed,-variation.y, +variation.y),
        col.z + rand_range(seed,-variation.z, +variation.z));
}
vec4 grass(vec2 p, int i, vec2 q, float r, float grass_width) {
    float height = rand_range(float(i+2),0.1,0.9);
    float max_curve = 1.0 - height + 0.40;
    float curve = rand_range(float(i+1), -max_curve, max_curve);
    vec2 pos = vec2(rand_range(float(i+3),-0.35,0.35 ),0.0);
    
    pos = q + pos;
    pos.y += 0.5; // coordinate y=0 will represent the bottom. 

    r = r * (1.0 - 1.0 * smoothstep(0.8*height, height, pos.y)); 
    float s = sign(curve); // curve value sign. 
    //the grass shape is described by a function on the form
    // x = (c* y)^2, where c is the curve.
    float grass_curve = abs(pos.x - s* pow( curve*( pos.y),2.0));
        // the grass ends at ymax. 

    float width = 0.005 * cos((pos.y - iTime / 25. + rand(float(i+3)) * 10.) * 73.) + 0.025*rand(float(i+3));
    width *= (1.0 - 1.1 * smoothstep(0.8*height, height, pos.y)); 
    float res = smoothstep(r, r + 0.008 + width, grass_curve);
    //float res = smoothstep(r, r+grass_width*(abs(cos((pos.y- iTime * .3 - rand(float(i))) * 10.) )), grass_curve);
    float inner_r = r/20.;
    float width_inner = 0.004 * cos((pos.y) * 17.+ rand(float(i+3)) * 10.);
    width_inner *= (1.0 - 1.1 * smoothstep(0.8*height, height, pos.y));
    float inner_res = smoothstep(inner_r, inner_r+ 0.008 + width_inner, grass_curve);
    //vec3 col = vec3(102./255.,153./255. + rand(float(i-10))/8.,51./255.);

    vec3 col = vec3(102./255., rand_range(float(i-10),0.55,0.65) ,51./255.);
    col = col - vec3(0.0,0.10,0.0)* (1.0-smoothstep(0.0, r,grass_curve));
    if (inner_res <1.) col /= 1.5;
    
    //vec3 col = vec3(1./255.,50./255.,32./255.);
    if (pos.y > height) return vec4(col,1.1);
   return vec4(col, res);
}
/*vec4 grass(vec2 p, int i, vec2 q) {
    float height = rand_range(float(i+2),0.1,0.9);
    float max_curve = 1.0 - height + 0.40;
    float curve = rand_range(float(i+1), -max_curve, max_curve);
    vec2 pos = vec2(rand_range(float(i+3),-0.35,0.35 ),0.0);
    
    pos = q + pos;
    pos.y += 0.5; // coordinate y=0 will represent the bottom. 

    float r = rand_range(float(i+200),0.02,0.04 ); // grass radius 

    
    // the grass gets thinner and thinner, 
    // as it grows to the top of the screen
    r = r * (1.0 - 0.5 * smoothstep(0.0,height, pos.y)); 

    float s = sign(curve); // curve value sign. 
    //the grass shape is described by a function on the form
    // x = (c* y)^2, where c is the curve.
    float grass_curve = abs(pos.x - s* pow( curve*( pos.y),2.0));
    float res = 1.0-(1.0 - smoothstep(r, r+0.006,grass_curve  ));
    vec3 col = vec3(0.40,0.6,0.2);
   return vec4(col, 1.0-res);
}*/
/*
    // the grass ends at ymax. 
    float ymax = height; 
    
    // sligthly blur the edges of the grass blade to decrease
    // aliasing issues
    float res = 1.0-(1.0 - smoothstep(r, r+0.006,grass_curve  ));
        //*(1.0 - smoothstep(ymax-0.1, ymax, pos.y));
   
    
    // grass bottom is dark, but the blade gets gradually brighter as it
    // grows upward.
    //vec3 bottom_color = rand_color(float(i),vec3(0.10,0.3,0.1), vec3(0.0,0.20,0.0));
    //vec3 top_color =  rand_color(float(i),vec3(0.40,0.6,0.2), vec3(0.0,0.20,0.0));
    //vec3 col = mix(bottom_color,top_color,pos.y);
    
    vec3 col = vec3(0.40,0.6,0.2);
   
    // gradually make the grass color lighter as we approach the edges; 
    // makes for a slight 3D effect.
    // col = col + vec3(0.0,0.10,0.0)* (1.0-smoothstep(0.0, r,grass_curve));
    
       
   return vec4(col, 1.0-res);
}*/


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord/iResolution.xy;
    vec2 p = fragCoord/iResolution.xy;
    uv -= 0.5;
    // uv.y *= iResolution.y / iResolution.x;
    
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
    vec2 newp = vec2(x,y);
        int i=4;
    for(int i = 0; i <20; i += 1){

    float radius = rand_range(float(i+200),0.03,0.04 ); // grass radius 
    float grass_width = 0.01;
    vec4 grassouter = grass(newp, i, newp-.5, radius, grass_width);
    // vec4 grass = grass(p, 4, p-.5);
    if (grassouter.w < 1.) {
        col = grassouter.xyz;
    }
    //col = mix(col, grass.xyz, grass.w);
    }
    // Output to screen
    fragColor = vec4(col, 1.0);

}