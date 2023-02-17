Shader "kuwahara"
{

    Properties
    {
        [HideInInspector]_DepthNormalsTexture ("DepthNormals", 2D) = "" {} 
        _MainTex ("Texture", 2D) = "white" {}
        _Size ("Filter Size", Range(1, 25)) = 5
    }
    SubShader
    {
        Name "Pass"
        Tags { "QUEUE"="Geometry" "RenderType"="Opaque" "RenderPipeline"="UniversalPipeline" "UniversalMaterialType"="Unlit" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            uniform float4 _MainTex_TexelSize;
            fixed _Size;

            sampler2D _DepthNormalsTexture;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            inline float MyLinear01Depth( float z )
            {
                return 1.0 / (_ZBufferParams.x * z + _ZBufferParams.y);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float uTexel = _MainTex_TexelSize.x;
                float vTexel = _MainTex_TexelSize.y;

                fixed4 rawDepth = tex2D(_DepthNormalsTexture, i.uv);
                fixed depth = LinearEyeDepth(rawDepth.b);  

                int areaSize = floor(_Size / 2);

                if (areaSize == 0) {
                    return tex2D(_MainTex, i.uv);
                }

                fixed3 aavg = fixed3(0,0,0);
                fixed3 avar = fixed3(0,0,0);
                for (int av = 1; av <= areaSize; av++) {
                    for (int au = 1; au <= areaSize; au++) {
                        fixed3 pick = tex2D(_MainTex, i.uv + float2(-au*uTexel, av*vTexel));
                        aavg += pick;
                        avar += pick * pick;
                    }
                }
                aavg /= areaSize * areaSize;
                avar = avar / (areaSize * areaSize) - aavg * aavg;

                fixed3 bavg = fixed3(0,0,0);
                fixed3 bvar = fixed3(0,0,0);
                for (int bv = 1; bv <= areaSize; bv++) {
                    for (int bu = 1; bu <= areaSize; bu++) {
                        fixed3 pick = tex2D(_MainTex, i.uv + float2(bu*uTexel, bv*vTexel));
                        bavg += pick;
                        bvar += pick * pick;
                    }
                }
                bavg /= areaSize * areaSize;
                bvar = bvar / (areaSize * areaSize) - bavg * bavg;

                fixed3 cavg = fixed3(0,0,0);
                fixed3 cvar = fixed3(0,0,0);
                for (int cv = 1; cv <= areaSize; cv++) {
                    for (int cu = 1; cu <= areaSize; cu++) {
                        fixed3 pick = tex2D(_MainTex, i.uv + float2(-cu*uTexel, -cv*vTexel));
                        cavg += pick;
                        cvar += pick * pick;
                    }
                }
                cavg /= areaSize * areaSize;
                cvar = cvar / (areaSize * areaSize) - cavg * cavg;

                fixed3 davg = fixed3(0,0,0);
                fixed3 dvar = fixed3(0,0,0);
                for (int dv = 1; dv <= areaSize; dv++) {
                    for (int du = 1; du <= areaSize; du++) {
                        fixed3 pick = tex2D(_MainTex, i.uv + float2(du*uTexel, -dv*vTexel));
                        davg += pick;
                        dvar += pick * pick;
                    }
                }
                davg /= areaSize * areaSize;
                dvar = dvar / (areaSize * areaSize) - davg * davg;

                fixed r = lerp(aavg.r, bavg.r, step(bvar.r, avar.r));
                r = lerp(r, cavg.r, step(cvar.r, min(avar.r, bvar.r)));
                r = lerp(r, davg.r, step(dvar.r, min(cvar.r, min(avar.r, bvar.r))));

                fixed g = lerp(aavg.g, bavg.g, step(bvar.g, avar.g));
                g = lerp(g, cavg.g, step(cvar.g, min(avar.g, bvar.g)));
                g = lerp(g, davg.g, step(dvar.g, min(cvar.g, min(avar.g, bvar.g))));

                fixed b = lerp(aavg.b, bavg.b, step(bvar.b, avar.b));
                b = lerp(b, cavg.b, step(cvar.b, min(avar.b, bvar.b)));
                b = lerp(b, davg.b, step(dvar.b, min(cvar.b, min(avar.b, bvar.b))));

                fixed4 col = fixed4(r,g,b,1);

                // fixed4 o = lerp(tex2D(_MainTex, i.uv).rgba,col.rgba,clamp(depth.rrrr,0.f,1.f));
                // return o.rgba;

                return col.rgba;
            }
            ENDCG
        }
    }
}
