Shader "Custom/Test"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Size ("Texture Size", int) = 256
	}
	SubShader
	{
		// No culling or depth
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
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			sampler2D _MainTex;
			float _Size;

			fixed4 frag (v2f i) : SV_Target
			{
				//i.uv = round(i.uv * _Size) / _Size;
				float d = 1 / _Size;

				int tl = tex2D(_MainTex, i.uv + float2(-d, +d)).r > 0.5;
				int tm = tex2D(_MainTex, i.uv + float2(0 , +d)).r > 0.5;
				int tr = tex2D(_MainTex, i.uv + float2(+d, +d)).r > 0.5;

				int ml = tex2D(_MainTex, i.uv + float2(-d, 0 )).r > 0.5;
				int mm = tex2D(_MainTex, i.uv + float2(0 , 0 )).r > 0.5;
				int mr = tex2D(_MainTex, i.uv + float2(+d, 0 )).r > 0.5;

				int bl = tex2D(_MainTex, i.uv + float2(-d, -d)).r > 0.5;
				int bm = tex2D(_MainTex, i.uv + float2(0 , -d)).r > 0.5;
				int br = tex2D(_MainTex, i.uv + float2(+d, -d)).r > 0.5;

				int neighbors = tl + tm + tr + ml + mr + bl + bm + br;

				fixed4 col = mm;
				if (neighbors < 2 || neighbors > 3) col = 0;
				if (neighbors == 3) col = 1;

				col.a = 1;
				return col;
			}
			ENDCG
		}
	}
}
