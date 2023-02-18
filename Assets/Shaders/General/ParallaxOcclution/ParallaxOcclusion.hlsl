void ParallaxOcclusion_float(
    int         SampleLoop,
    UnityTexture2D AlbedoMap,
    UnityTexture2D HeightMap,
    float2      UV,
    float3      ViewDirTBN,
    float3      CameraPos,
    float3      ObjectPos,
    float       HeightScale,
    float2      UVScale,
    out float4 Color)
{
    float3 rayDir                           = normalize(ObjectPos - CameraPos);
    float3 CurrentPos                       = ObjectPos;
	float CurrentRayHeight                  = 0.0;			    // 
    float CurrentCheckPointHeight           = -HeightScale;     // 現在のチェック深度を最深部に
    float2 FetchUV                          = float2(0,0);

    const int HeightSamples = 6;
    const float HeightPerSample = 1.0 / HeightSamples;
    float  rayScale = (-HeightScale / rayDir.y);             // 最低面に衝突する大きいRay
	float3  rayStep = rayDir * rayScale * HeightPerSample;	 // 1回分のRay
    
   
    // 現在のRayの高さがフェッチした深さよりも浅い間はループする
     [unroll]
    for (int i = 0; i < HeightSamples && CurrentCheckPointHeight < CurrentRayHeight; ++i)
	{
        // レイを進める
		CurrentPos += rayStep;
        FetchUV = CurrentPos.xz;

        // 現在位置の下部の深さを求める
        float height = SAMPLE_TEXTURE2D(HeightMap, HeightMap.samplerstate, FetchUV.xy / UVScale).r;
		CurrentCheckPointHeight = lerp(-HeightScale, 0, height); // -Height ~ 0の範囲に
        
        // 現在のRayの高さを更新する
		CurrentRayHeight = CurrentPos.y;
	}

    // 以下ジャギを防ぐための線形補完処理
    
    
    float2 nextObjPoint = FetchUV;
	float2 prevObjPoint = FetchUV - rayStep.xz;
    
    // 前回と今回の深度を求める
    float nextHeight    = CurrentCheckPointHeight;
    float prevHeight    = lerp( -HeightScale, 0, tex2D(HeightMap, prevObjPoint).r); // 値域を-HeightScale ~ 0に
    
    // CurrentRayHeight(深く潜りすぎてしまった地点)を基準(0)とした高さを求める　1次元ベクトルで考えると分かりやすい
    float nH    = nextHeight            - CurrentRayHeight;   
    float pH    = prevHeight + rayStep.y - CurrentRayHeight;
    
	float weight = nH / (nH - pH);                                       // 三角比によって求められる　1 : weight = nH - pH : nH だから
    FetchUV = lerp(nextObjPoint, prevObjPoint, weight);
    
    float4 Albedo = SAMPLE_TEXTURE2D(AlbedoMap, AlbedoMap.samplerstate, FetchUV / UVScale);
    
    Color = Albedo;
    
}