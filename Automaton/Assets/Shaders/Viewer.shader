Shader "Custom/Viewer"
{
	Properties
	{
		[PerRendererData]
		_MainTex ("Texture", 2D) = "white" {}
		_Size("Size", int) =128
		[Toggle(USE_HEX_SPACE)]
		_Hex("Use Hex Space", Float) = 0
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue"="Transparent" }
		LOD 100

		Pass
		{
			Cull Off

			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma shader_feature USE_HEX_SPACE
			
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
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

#ifdef USE_HEX_SPACE
				o.uv -= 0.5;
				o.uv.x += o.uv.y / sqrt(3);
				o.uv.y *= 2/sqrt(3);
				o.uv += 0.5;
#endif

				return o;
			}

			float _Size;
			float MinNeighbor(float2 uv) {
				float d = 2 / _Size;

				float top = tex2D(_MainTex, uv + float2(0, d)).b;
				float bottom = tex2D(_MainTex, uv + float2(0, -d)).b;
				float left = tex2D(_MainTex, uv + float2(-d, 0)).b;
				float right = tex2D(_MainTex, uv + float2(d, 0)).b;

				return min(min(top, bottom), min(left, right));
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				clip(col.b - 0.5);
				float Min = MinNeighbor(i.uv);
				col.b = Min;
				col.a = 1;
				return col;
			}
			ENDCG
		}
	}
}
