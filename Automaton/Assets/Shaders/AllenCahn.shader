Shader "Custom/AllenCahn"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_Size("Texture Size", int) = 256
		_A ("A", int) = 4
		_B ("B", int) = 2
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

	float Sample(float2 uv) {
		return tex2D(_MainTex, uv).r * _A;
	}

	float MaxNeighbor(float2 uv) {
		float d = 1 / _Size;

		float top = Sample(uv + float2(0, d));
		float bottom = Sample(uv + float2(0, -d));
		float left = Sample(uv + float2(-d, 0));
		float right = Sample(uv + float2(d, 0));

		return max(max(top, bottom), max(left, right));
	}

	fixed4 frag(v2f i) : SV_Target
	{
		float Max = MaxNeighbor(i.uv);
		float U = 2 * Max - _B;
		if (Max < _B / 2) U = 0;
		if ((_A + _B) / 2 < Max) U = _A;
		U = round(U);

		fixed4 col = U / _A;
		col.a = 1;
		return col;
	}
		ENDCG
	}
	}
}
