#version 150

uniform sampler2D SourceSampler;
uniform sampler2D ImageSampler;

in vec2 texCoord;
uniform vec2 OutSize;
mat4 DitherMatrix = mat4( 
        0.0, 12.0,  3.0, 15.0, 
        8.0,  4.0, 11.0,  7.0, 
        2.0, 14.0,  1.0, 13.0, 
        10.0, 6.0,  9.0,  5.0
    );

float PI = 3.14159265359;

float ditherPixSize = 0.5; // size of the pixel areas on screen
float N = 4.0; // the width of the dither matrix (2.0 for mat2, 4.0 for mat4, etc)
float Nsquared = N * N; // N^2 precomuted so we don't have to keep doing this.

out vec4 fragColor;

float getBrightnessOfColor(vec4 col ){
    return ((col.r * 0.21) + (col.g * 0.72) + (col.b * 0.07));
}

vec4 posterizeSeprate(vec4 color, float steps){
    return (floor(color * (steps - 1.0) + 0.5) / (steps - 1.0));
}

float crtvFunc(float x, float a){
    return ( ( -sin( (x * PI * 0.4) + (PI * 0.3) ) + 2.0 ) * (a - 0.5) + 0.5);
}

void main() {

    vec2 crtifiedTexCoord = vec2(texCoord.x, crtvFunc( texCoord.x, texCoord.y ) );
    crtifiedTexCoord = vec2(crtifiedTexCoord.y, crtvFunc( texCoord.y, texCoord.x ) ).yx;
    if(crtifiedTexCoord.y > 1.0 || crtifiedTexCoord.y < 0.0 || crtifiedTexCoord.x > 1.0 || crtifiedTexCoord.x < 0.0){
        fragColor = vec4(0.0, 0.0, 0.0, 1.0);
        return;
    }

    //ditherPixSize = ceil( 1600.0 / (OutSize.x * 10) ) * 0.1;
    /*vec2 snapTex = vec2(
        floor(texCoord.x / ditherPixSize) * ditherPixSize,
        floor(texCoord.y / ditherPixSize) * ditherPixSize
    );*/


    float ditherAmount = DitherMatrix[
        int( mod( texCoord.y * OutSize.y * ditherPixSize, N ) )
    ][
        int( mod( texCoord.x * OutSize.x * ditherPixSize, N ) )
    ];

    
    fragColor = posterizeSeprate(
        texture( SourceSampler, crtifiedTexCoord ) +
        1.0 * ((ditherAmount / Nsquared) - 0.5), 
    N );

    /*
    fragColor = 
        posterizeSeprate(
            texture( SourceSampler, texCoord ) +
            ((ditherAmount * (1.0 / n^2)) - 0.5), 
        n.0 );
    */
}