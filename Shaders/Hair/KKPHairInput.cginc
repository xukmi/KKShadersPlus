#ifndef KKP_HAIR_INPUT
#define KKP_HAIR_INPUT
	struct VertexData
	{
		float4 vertex : POSITION;
		float3 normal : NORMAL;
		float4 tangent : TANGENT;
		float2 uv0 : TEXCOORD0;
		float2 uv1 : TEXCOORD1;
	};

	struct Varyings
	{
		float4 posCS : SV_POSITION;
		float2 uv0 : TEXCOORD0;
		float2 uv1 : TEXCOORD1;
        float4 posWS    : TEXCOORD2;
		float3 normalWS : TEXCOORD3;
		float4 tanWS    : TEXCOORD4;
		float3 bitanWS  : TEXCOORD5;
	#ifdef SHADOWS_SCREEN
		float4 shadowCoordinate : TEXCOORD6;
	#endif
	};

	//KKP Include
	float _SpecularHairPower;
	float4 _GlossColor;
	float4 _CustomAmbient;
	bool _SpecularIsHighlights;
	float _SpecularIsHighlightsRange;
	float _SpecularIsHighLightsPow;
	bool _UseRampForLights;
	bool _UseRampForSpecular;
	bool _UseLightColorSpecular;
	float _UseMeshSpecular;
	
	//Input Textures
	sampler2D _MainTex;
	sampler2D _AlphaMask;
	sampler2D _NormalMap;
	sampler2D _ColorMask;
	sampler2D _HairGloss;
	sampler2D _DetailMask;
	sampler2D _RampG;
	sampler2D _AnotherRamp;
	//UV Offsets
	float4 _MainTex_ST;
	float4 _AlphaMask_ST;
	float4 _NormalMap_ST;
	float4 _ColorMask_ST;
	float4 _HairGloss_ST;
	float4 _DetailMask_ST;
	float4 _RampG_ST;
	float4 _AnotherRamp_ST;


	float _rimpower;
	float _rimV;
	
	float4 _Color;
	float4 _Color2;
	float4 _Color3;
	float4 _LineColor;

	float4 _SpecularColor;
	float4 _ShadowColor;
	float _SpeclarHeight;
	float _ShadowExtend;

	float _LineWidthS;

	//Global light params set by KK 
	float _linewidthG; 
	float4 _ambientshadowG;

#endif