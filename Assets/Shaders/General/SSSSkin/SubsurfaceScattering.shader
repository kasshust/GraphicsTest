Shader "Xibanya/Lit/SubsurfaceScattering"
{
    Properties
    {
        _Color              ("Color", Color) = (1,1,1,1)
        _MainTex            ("Albedo (RGB)", 2D) = "white" {}
        [NoScaleOffset]
        _BumpMap            ("Bump Map", 2D) = "bump" {}
        [NoScaleOffset]
        _MetallicGlossMap   ("Spec Map", 2D) = "white" {}
        _Glossiness         ("Smoothness", Range(0,1)) = 0.5
        _Threshold          ("Subsurface Threshold", Range(0.75, 1)) = 0.95
        _ScatterExp         ("Scatter Exponent", float) = 2.2
        _ScatterGain        ("Scatter Gain", float) = 2
        [Toggle(_INVERT_SCATTER)]
        _InvertScatter      ("Invert Scatter", float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Subsurface
        #pragma shader_feature_local _INVERT_SCATTER

        sampler2D   _MainTex;
        sampler2D   _BumpMap;
        sampler2D   _MetallicGlossMap;

        struct Input
        {
            float2 uv_MainTex;
        };

        half            _Glossiness;
        half4           _Color;
        half            _Threshold;
        half            _ScatterExp;
        half            _ScatterGain;

        half4 LightingSubsurface(SurfaceOutput s, float3 lightDir, float3 viewDir, half atten)
        {
            half4 c = 1;
            half nDotL = saturate(dot(s.Normal, lightDir));
            c.rgb = s.Albedo * nDotL * atten * _LightColor0.rgb;

            float3 eyeVec = -viewDir;
            half lDotV = smoothstep(_Threshold, 1, saturate(dot(eyeVec, lightDir)));
            half nDotV = saturate(dot(s.Normal, viewDir));
#ifdef _INVERT_SCATTER
            nDotV = 1 - nDotV;
#endif
            half scatter = lDotV * nDotV;
            c.rgb += pow(_LightColor0.rgb * s.Albedo * scatter, _ScatterExp) * _ScatterGain;
            return c;
        }
        void surf (Input IN, inout SurfaceOutput o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_MainTex));
            o.Gloss = _Glossiness * tex2D(_MetallicGlossMap, IN.uv_MainTex).r;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}