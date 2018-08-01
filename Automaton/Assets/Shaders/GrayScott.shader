Shader "Custom/GrayScott"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_Size("Texture Size", int) = 256
		_A("A", int) = -1
		_B("B", int) = 1
		_p("p", int) = 1
		_q("q", int) = 1
		[Toggle(USE_HEX_SPACE)]
		_Hex("Use Hex Space", Float) = 0
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
			float4 vertex : SV_POSITION;
		};

		v2f vert(appdata v)
		{
			v2f o;
			o.vertex = UnityObjectToClipPos(v.vertex);
			o.uv = v.uv;
			return o;
		}

		sampler2D _MainTex;
		float _Size;
		float _A;
		float _B;
		float _p;
		float _q;

		//U:red
		//W:blue
		float2 Sample(float2 uv) {
			float2 ret;
			float4 tex = tex2D(_MainTex, uv);
			ret.x = (tex.r > 0.5) - 1;
			ret.y = (tex.b > 0.5);
			return ret;
		}

		float2 MaxNeighbor(float2 uv) {
			float2 ret;

			float d = _p / _Size;
			float2 top = Sample(uv + float2(0, d));
			float2 bottom = Sample(uv + float2(0, -d));
			float2 left = Sample(uv + float2(-d, 0));
			float2 right = Sample(uv + float2(d, 0));
			ret.x = max(max(top.x, bottom.x), max(left.x, right.x));
#ifdef USE_HEX_SPACE
			float2 tr = Sample(uv + d);
			float2 bl = Sample(uv - d);
			ret.x = max(ret.x, max(tr.x, bl.x));
#endif

			d = _q / _Size;
			top = Sample(uv + float2(0, d));
			bottom = Sample(uv + float2(0, -d));
			left = Sample(uv + float2(-d, 0));
			right = Sample(uv + float2(d, 0));
			ret.y = max(max(top.y, bottom.y), max(left.y, right.y));
#ifdef USE_HEX_SPACE
			tr = Sample(uv + d);
			bl = Sample(uv - d);
			ret.y = max(ret.y, max(tr.y, bl.y));
#endif

			return ret;
		}

		fixed4 frag(v2f i) : SV_Target
		{
			float2 Max = MaxNeighbor(i.uv);

			float W = max(Max.x + 2 * Max.y, _B) - max(Max.x, _B);

			float U = max(Max.x + W, _A) - max(2 * W, _A);

			fixed4 col = fixed4(U + 1, 0, W, 1);
			return col;
		}
			ENDCG
		}
		}
}
