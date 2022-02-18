#ifndef KKP_ITEM_INPUT
#define KKP_ITEM_INPUT
	struct VertexData
	{
		float4 vertex : POSITION;
		float3 normal : NORMAL;
		float4 tangent : TANGENT;
		float2 uv0 : TEXCOORD0;
	};

	struct Varyings
	{
		float4 posCS : SV_POSITION;
		float2 uv0 : TEXCOORD0;
	#ifdef SHADOWS_SCREEN
		float4 shadowCoordinate : TEXCOORD5;
	#endif
        float4 posWS    : TEXCOORD1;
		float3 normalWS : TEXCOORD2;
		float4 tanWS    : TEXCOORD3;
		float3 bitanWS  : TEXCOORD4;
	};


	float4 _CustomAmbient;
	bool _UseRampForLights;
	bool _UseRampForSpecular;
	bool _UseLightColorSpecular;
	bool _AlphaOptionCutoff;
	bool _OutlineOn;
	bool _UseDetailRAsSpecularMap;

	int _CullOption;
	float _UseKKMetal;

	float _NormalMapScale;
	float _DetailNormalMapScale;

	float4 _OutlineColor;

	//Input Textures
	sampler2D _MainTex;
	sampler2D _AlphaMask;
	sampler2D _NormalMap;
	sampler2D _NormalMapDetail;
	sampler2D _liquidmask;
	sampler2D _Texture2; //Liquid Tex
	sampler2D _Texture3; //Liquid Normal
	sampler2D _DetailMask;
	sampler2D _NormalMask;
	sampler2D _AnotherRamp;

	sampler2D _RampG;
	sampler2D _LineMask;

	sampler2D _ColorMask;

	//UV Offsets
	float4 _MainTex_ST;
	float4 _AlphaMask_ST;
	float4 _NormalMap_ST;
	float4 _NormalMapDetail_ST;

	float4 _liquidmask_ST;
	float4 _Texture2_ST; //Liquid Tex
	float4 _Texture3_ST; //Liquid Normal
	float4 _DetailMask_ST;
	float4 _NormalMask_ST;
	float4 _AnotherRamp_ST;


	float4 _RampG_ST;
	float4 _LineMask_ST;
	
	float4 _ColorMask_ST;
	
	float _Cutoff;
	float4 _ShadowColor;
	float _rimpower;
	float _rimV;
	float4 _SpecularColor;
	float _SpeclarHeight;
	float _SpecularPower;
	float _SpecularPowerNail;
	float _ShadowExtend;
	float _ShadowExtendAnother;
	float _alpha_a;
	float _alpha_b;
	float _notusetexspecular;
	float _liquidftop;
	float _liquidfbot;
	float _liquidface;
	float _liquidbtop;
	float _liquidbbot;
	float4 _LiquidTiling;
	float _DetailRLineR;
	float _DetailBLineG;

	float4 _TimeEditor;
	float4 _Clock;
	float4 _Color;
	float4 _Color2;
	float4 _Color3;
	float _AnotherRampFull;
	float _LineWidthS;
	float _Alpha;
	//Global light params set by KK 
	float4 _LineColorG;
	float _linewidthG; 
	float4 _ambientshadowG;
	float _FaceShadowG;
	float _FaceNormalG;

#endif