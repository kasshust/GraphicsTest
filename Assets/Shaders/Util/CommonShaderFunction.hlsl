#ifndef CUMMON_SHADER_FUNCTION
#define CUMMON_SHADER_FUNCTION

float UvRand(float2 uv)
{
    return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
}

float2x2 Rotate2D(float angle)
{
    return float2x2(cos(angle), -sin(angle),
        sin(angle), cos(angle));
}

float CircleDist(float2 uv)
{
    float RADIUS = 1.0;
    float l = length(uv);
    return l - RADIUS;
}

float2 GetParallaxOffset(float3 viewDirTBN, float height)
{
    float2 v= viewDirTBN.xy / viewDirTBN.z * height;
    // v *= -1;
    return -v;
}

#endif