Shader "Test/BlitDepth"
{
  Properties
  {
    _MainTex ("Texture", 2D) = "white" {}
    _CameraDepthTexture ("DepthTexture", 2D) = "white" {}
  }
  SubShader
  {
    Cull Off ZWrite Off ZTest Always

    Pass
    {
      CGPROGRAM
      #pragma vertex vert
      #pragma fragment frag
      
      #include "UnityCG.cginc"

      struct appdata
      {
        float4 vertex : POSITION;
        float2 uv : TEXCOORD0;
      };

      struct v2f
      {
        float2 uv : TEXCOORD0;
        float2 uv_depth : TEXCOORD1;
        float4 vertex : SV_POSITION;
      };

      v2f vert (appdata v)
      {
        v2f o;
        o.vertex = UnityObjectToClipPos(v.vertex);
        o.uv = v.uv;
        o.uv_depth = v.uv;
        return o;
      }
      
      sampler2D _MainTex;
      sampler2D _CameraDepthTexture;


      fixed4 frag (v2f i) : SV_Target
      {
        half rawDepth = tex2D(_CameraDepthTexture, i.uv);
        half depth = Linear01Depth(rawDepth);
        return fixed4(rawDepth, rawDepth, rawDepth, 1);
      }
      ENDCG
    }
  }
}