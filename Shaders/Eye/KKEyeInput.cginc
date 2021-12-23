#ifndef KK_EYE_INPUT
#define KK_EYE_INPUT
	struct VertexData
	{
		float4 vertex : POSITION;
		float3 normal : NORMAL;
		float4 tangent : TANGENT;
		float2 uv0 : TEXCOORD0;
		float2 uv1 : TEXCOORD1;
		float2 uv2 : TEXCOORD2;
	};

	struct Varyings
	{
		float4 posCS : SV_POSITION;
		float2 uv0 : TEXCOORD0;
		float2 uv1 : TEXCOORD1;
		float2 uv2 : TEXCOORD2;
        float4 posWS    : TEXCOORD3;
		float3 normalWS : TEXCOORD4;
		float4 tanWS    : TEXCOORD5;
		float3 bitanWS  : TEXCOORD6;
	};





	//Input Textures
	sampler2D _MainTex;
	sampler2D _overtex1;
	sampler2D _overtex2;
	sampler2D _expression;

	sampler2D _RampG;

	//UV Offsets
	float4 _MainTex_ST;
	float4 _overtex1_ST;
	float4 _overtex2_ST;
	float4 _expression_ST;
	float4 _RampG_ST;
	float4 _overcolor1;
	float4 _overcolor2;
	float4 _Color;

	float4 _shadowcolor;
	float _isHighLight;
	float _exppower;
	float _rotation;

	//Global light params set by KK
	float4 _ambientshadowG;
	

#endif