#ifndef INTERIORMAP_00
#define INTERIORMAP_00

float GetIntersectLength(float3 rayPos, float3 rayDir, float3 planePos, float3 planeNormal)
{
    return dot(planePos - rayPos, planeNormal) / dot(rayDir, planeNormal);
}

float GetRandomNumber(float2 texCoord, float Seed)
{
    return frac(sin(dot(texCoord.xy, float2(12.9898, 78.233)) + Seed) * 43758.5453);
}

//---------------------------------------------------

float2 GetCeilUV(float3 uvw, float4 _CeilTexSizeAndOffset)
{
    uvw.x = (uvw.x - 1.0) * _CeilTexSizeAndOffset.x - _CeilTexSizeAndOffset.z;
    uvw.y = (uvw.y) * _CeilTexSizeAndOffset.y - _CeilTexSizeAndOffset.w;
    return float2(-uvw.x, uvw.y);
}

float2 GetFloorUV(float3 uvw, float4 _FloorTexSizeAndOffset)
{
    uvw.x = (uvw.x) * _FloorTexSizeAndOffset.x + _FloorTexSizeAndOffset.z;
    uvw.y = (uvw.y) * _FloorTexSizeAndOffset.y + _FloorTexSizeAndOffset.w;
    return uvw.xy;
}

float2 GetLeftWallUV(float3 uvw, float4 _WallTexSizeAndOffset)
{
    uvw.x = (uvw.x) * _WallTexSizeAndOffset.x + _WallTexSizeAndOffset.z;
    uvw.y = (uvw.y) * _WallTexSizeAndOffset.y + _WallTexSizeAndOffset.w;
    return uvw.xy;
}

float2 GetRightWallUV(float3 uvw, float4 _WallTexSizeAndOffset)
{
    uvw.x = (uvw.x - 1.0) * _WallTexSizeAndOffset.x - _WallTexSizeAndOffset.z;
    uvw.y = (uvw.y) * _WallTexSizeAndOffset.y + _WallTexSizeAndOffset.w;
    return float2(-uvw.x, uvw.y);
}

float2 GetFrontWallUV(float3 uvw, float4 _WallTexSizeAndOffset)
{
    uvw.x = (uvw.x) * _WallTexSizeAndOffset.x + _WallTexSizeAndOffset.z;
    uvw.y = (uvw.y) * _WallTexSizeAndOffset.y + _WallTexSizeAndOffset.w;
    return uvw.xy;
}

float2 GetBackWallUV(float3 uvw, float4 _WallTexSizeAndOffset)
{
    uvw.x = (uvw.x - 1.0) * _WallTexSizeAndOffset.x - _WallTexSizeAndOffset.z;
    uvw.y = (uvw.y) * _WallTexSizeAndOffset.y + _WallTexSizeAndOffset.w;
    return float2(-uvw.x, uvw.y);
}

//---------------------------------------------------

void InteriorMap_float(
    UnityTexture2D AlbedoTexture,
    float4 Color,
    float2 UV,
    float3 CameraPos,
    float3 WorldPos,
    float3 ObjectPos,
    float Depth,
    float LightIntensity,
    float DistanceBetweenFloors,
    float DistanceBetweenWalls,
    float4 FloorTexSizeAndOffset,
    float4 CeilTexSizeAndOffset,
    float4 WallTexSizeAndOffset,
    float3 XYZOffset,
    
    out float4 Out)
{
    
    float3 Albedo = float3(0.0, 0.0, 0.0);
    float2 uv = UV * 2. - 1.;
    
    ///////////////////////////////
    
    float3 offset = XYZOffset - float3(0.0,0.0,0.001);
    float3 objectFragPos = WorldPos;
    float3 cameraPos = CameraPos + offset;
    float3 rayPos    = objectFragPos.xyz + offset;
    float3 rayDir    = rayPos.xyz - cameraPos.xyz;
    
    ///////////////////////////////
   
    float3 planePos     = float3(0.0, 0.0, 0.0);
    float3 planeNormal  = float3(0.0, 0.0, 0.0);
    float3 UpVec        = float3(0, 1., 0);
    float3 RightVec     = float3(1., 0, 0);
    float3 FrontVec     = float3(0, 0, 1.);
    
    
    /////////////////////////////
    
    float  len = 99999999.;
    float3 uvw;
    float3 IntersectPos;
    
    // float2 randUV = float2(round((rayPos.x) / DistanceBetweenWalls), round((rayPos.y) / DistanceBetweenFloors));
    // float  randValue = GetRandomNumber(randUV, 1.0f);
    
    planePos = float3(0.0, 0.0, 0.0);
    // ceil and floor
    {
        float which = step(0.0, dot(rayDir, UpVec));
        planeNormal = float3(0, lerp(1., -1., which), 0);
        
        planePos.y = round((rayPos.y) / DistanceBetweenFloors);
        planePos.y -= lerp(0.5, -0.5, which);
        planePos.y *= DistanceBetweenFloors;
        
        // planePos.y += XYOffset.y;
        
        float l = GetIntersectLength(rayPos, rayDir, planePos, planeNormal);
        if (l < len)
        {
            len = l;
            IntersectPos = rayPos + rayDir * l;
            uvw.xy = lerp(GetFloorUV(IntersectPos.xzy, FloorTexSizeAndOffset), GetCeilUV(IntersectPos.xzy, CeilTexSizeAndOffset), which);
            Albedo = SAMPLE_TEXTURE2D(AlbedoTexture, AlbedoTexture.samplerstate, uvw.xy);
            // Albedo = float3(1.0, which, 0.0);
        }
    }
    
    // side wall
    {
        float which = step(0.0, dot(rayDir, RightVec));
        planeNormal = float3(lerp(1., -1., which), 0, 0);
        
        planePos.x = round((rayPos.x) / DistanceBetweenWalls);
        planePos.x -= lerp(0.5, -0.5, which);
        planePos.x *= DistanceBetweenWalls;
        
        float l = GetIntersectLength(rayPos, rayDir, planePos, planeNormal);
        if (l < len)
        {
            len = l;
            IntersectPos = rayPos + rayDir * l;
            uvw.xy = lerp(GetLeftWallUV(IntersectPos.zyx, WallTexSizeAndOffset), GetRightWallUV(IntersectPos.zyx, WallTexSizeAndOffset), which);
            Albedo = SAMPLE_TEXTURE2D(AlbedoTexture, AlbedoTexture.samplerstate, uvw.xy);
            // Albedo = float3(0.0, which, 1.0);
        }
    }
    
    // depth wall
    {
        float which = step(0.0, dot(rayDir, FrontVec));
        planeNormal = float3(0.0, 0.0, lerp(1., -1., which));
        float depth = Depth;
        
        planePos = ((rayPos.z + depth));
        planePos.z -= lerp(0.5, 0.5, which);
        
        float l = GetIntersectLength(rayPos, rayDir, planePos, planeNormal);
        if (l <= len)
        {
            len = l;
            IntersectPos = rayPos + rayDir * l;
            uvw.xy = lerp(GetBackWallUV(IntersectPos.xyz, WallTexSizeAndOffset), GetFrontWallUV(IntersectPos.xyz, WallTexSizeAndOffset), which);
            Albedo = SAMPLE_TEXTURE2D(AlbedoTexture, AlbedoTexture.samplerstate, uvw.xy);
            // Albedo = float3(1.0, 0.0, 1.0);
        }
        
    }
    
    // float d = IntersectPos.z / Depth * Depth;
    float3 Light = Albedo.xyz * Color.xyz * LightIntensity;
    Out = float4(Light.xyz, 1.0);
    
}

#endif