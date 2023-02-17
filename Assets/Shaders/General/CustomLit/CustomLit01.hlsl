#ifndef CUSTOM_LIT_01
#define CUSTOM_LIT_01

float circledist(float2 uv)
{
    float RADIUS = 1.0;
    float l = length(uv);
    return l - RADIUS;
}

void CustomLit01_float(
    float2 UV,
    out float4 Out)
{
    Out = float4(UV.x, UV.y, 0.0f, 1.0f);
    
}

#endif