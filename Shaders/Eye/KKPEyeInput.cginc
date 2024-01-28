#ifndef KKP_EYE_INPUT
#define KKP_EYE_INPUT

#include "../KKPDeclarations.cginc"
#define SAMPLERTEX _MainTex

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
	#ifdef SHADOWS_SCREEN
		float4 shadowCoordinate : TEXCOORD7;
	#endif
	};

	//Input Textures
	DECLARE_TEX2D(_MainTex);
	DECLARE_TEX2D(_expression);
	DECLARE_TEX2D(_overtex1);
	DECLARE_TEX2D(_overtex2);

	sampler2D _RampG;

	bool _UseRampForLights;
	//UV Offsets
	float4 _MainTex_ST;
	float4 _overtex1_ST;
	float4 _overtex2_ST;
	float4 _expression_ST;
	float4 _RampG_ST;
	float4 _overcolor1;
	float4 _overcolor2;
	float4 _Color;
	float4 _CustomAmbient;
	
	float4 _shadowcolor;
	float4 _ShadowHSV;
	float _isHighLight;
	float _exppower;
	float _ExpressionSize;
	float _ExpressionDepth;
	float _rotation;
	float _Cutoff;

	//Global light params set by KK
	float4 _ambientshadowG;
	
	float _DisablePointLights;
	float _DisableShadowedMatcap;
#endif