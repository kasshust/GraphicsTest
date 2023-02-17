#ifndef CUSTOM_LIT_02
#define CUSTOM_LIT_02

#include "Assets/Shaders/Util/CommonShaderFunction.hlsl"

void ParallaxOffset_float(
    float3x3    TBNmtx,
    float3      ViewDir,
    float       Height,
    out float2 Offset)
{
    float3 viewDirTBN = mul(TBNmtx, ViewDir);
    Offset = GetParallaxOffset(viewDirTBN, Height);
    
}

#endif