#ifndef CUSTOM_LIT_NOISETILING
#define CUSTOM_LIT_NOISETILING

#include "Assets/Shaders/Util/CommonShaderFunction.hlsl"

void CustomNoiseTiling_float(
    float2 UV,
    float2 Tile,
    float  Rot,
    out float2 Out)
{
    float t = Rot;
    float2 TILENUM = Tile;
    
    // Tiling and Normalize
    float2 mUV = fmod(UV * TILENUM, 1.0) * 2.0f - 1.0f;
    float2 index = floor(UV * TILENUM);
    
    // RandomValue per Tile
    float randValue = UvRand(index) - 0.5;
    
    //Å@Rotation
    
    float2 st0 = mUV;
    float2 st1 = mul(st0, Rotate2D(t * randValue));

    /*
    float px = 2.0 * TILENUM/ 1000.0;
    float4 tex0 = SAMPLE_TEXTURE2D_GRAD(Texture,Texture.samplerstate, st0.xy, float2(px, 0), float2(0, px));
    float4 tex1 = SAMPLE_TEXTURE2D_GRAD(Texture,Texture.samplerstate, st1.xy, float2(px, 0), float2(0, px));
    float4 tex = lerp(tex1, tex0, smoothstep(-px, px, CircleDist(st0)));
    */
    float edge = step(0.0, CircleDist(st0));
    float2 sto = st1 * (1 - edge) + st0 * edge;
    Out = sto;
}

#endif