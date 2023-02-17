#ifndef CUSTOM_LIT_03
#define CUSTOM_LIT_03

void CustomLit03_float(
    UnityTexture2D Texture,
    float2 UV,
    float  iTime,
    float Scale,
    out float4 Out)
{
    float scale = (Scale / 20.0 + 10.0);
    
    float2 bUV = UV * 2.0 - 1.0;
    
    // mUv�̍쐬
    float2 rUv = bUV * scale; // �J��Ԃ�uv
    float2 mUv = frac(rUv) * 2.0 - 1.0; // 0<>1
    float2 cellCenter = floor(rUv) + float2(0.5, 0.5); // ��΍��W���猩���e�Z���̌��_�ʒu
    
    // mCenter�ƌ��_�̋���
    float dist = distance(cellCenter, float2(0.0,0.0)) / scale;
    float4 col = float4(0.0, 0.0, 0.0, 1.0);
    
    // if (dist < 0.5)
    {
        float mdist = distance(mUv, float2(0, 0));
        
        float yellowSize = 0.6 - 0.2 * sin(iTime * 10.0 + rUv.x + rUv.y);
        float p = step(mdist, yellowSize);
        col = float4(p, p, p, 0.0);
    }
    
    Out = float4(col.xyz, 1.0);
    
}

#endif