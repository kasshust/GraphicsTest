#ifndef CUSTOM_LIT_02
#define CUSTOM_LIT_02

float uvrand(float2 uv)
{
    return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
}

float2x2 rotate(float angle)
{
    return float2x2(cos(angle), -sin(angle),
        sin(angle), cos(angle));
}

float circledist(float2 uv)
{
    float RADIUS = 1.0;
    float l = length(uv);
    return l - RADIUS;
}

void CustomLit02_float(
    UnityTexture2D Texture,
    float2 UV,
    out float4 Out)
{
    float3 Color = SAMPLE_TEXTURE2D(Texture, Texture.samplerstate, UV);
    Out = float4(Color.xyz, 1.0);
    
}

#endif