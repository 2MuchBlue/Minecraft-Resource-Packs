#version 150

#moj_import <minecraft:fog.glsl>

in vec3 Position;
in vec4 Color;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform vec3 ModelOffset;
uniform int FogShape;
uniform vec4 ColorModulator;

uniform float GameTime;

out float vertexDistance;
out vec4 vertexColor;

float PI = 3.14159265359;

void main() {
    vec3 pos = Position + ModelOffset;

    gl_Position = ProjMat * ModelViewMat * vec4(pos + vec3(
        0.0, 
        sin((GameTime * 100.0 + Position.x) * 2.0 * PI),
        0.0
    ), 1.0);

    vertexDistance = fog_distance(pos, FogShape);
    vertexColor = Color * ColorModulator;
}