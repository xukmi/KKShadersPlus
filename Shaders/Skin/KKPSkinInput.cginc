#ifndef KKP_MAIN_INPUT
#define KKP_MAIN_INPUT

	struct VertexData
	{
		float4 vertex : POSITION;
		float3 normal : NORMAL;
		float4 tangent : TANGENT;
		float4 color : COLOR;
		float2 uv0 : TEXCOORD0;
		float2 uv1 : TEXCOORD1;
		float2 uv2 : TEXCOORD2;
		float2 uv3 : TEXCOORD3;
	};

	struct Varyings
	{
		float4 posCS : SV_POSITION;
		float4 color : COLOR;
		float2 uv0 : TEXCOORD0;
		float2 uv1 : TEXCOORD1;
		float2 uv2 : TEXCOORD2;
		float2 uv3 : TEXCOORD3;
	#ifdef SHADOWS_SCREEN
		float4 shadowCoordinate : TEXCOORD4;
	#endif
        float4 posWS    : TEXCOORD5;
		float3 normalWS : TEXCOORD6;
		float4 tanWS    : TEXCOORD7;
		float3 bitanWS  : TEXCOORD8;
	};

	//KKP Inputs
	float4 _CustomAmbient;
	bool _UseRampForLights;
	bool _UseRampForSpecular;
	bool _UseLightColorSpecular;

	float _NormalMapScale;

	//KK Inputs

	//Input Textures
	sampler2D _MainTex;
	sampler2D _AlphaMask;
	sampler2D _NormalMap;
	sampler2D _NormalMapDetail;
	sampler2D _liquidmask;
	sampler2D _Texture2; //Liquid Tex
	sampler2D _Texture3; //Liquid Normal
	sampler2D _overtex1;
	sampler2D _overtex2;
	sampler2D _overtex3;
	sampler2D _DetailMask;
	sampler2D _NormalMask;
	sampler2D _RampG;
	sampler2D _LineMask;
	//UV Offsets
	float4 _MainTex_ST;
	float4 _AlphaMask_ST;
	float4 _NormalMap_ST;
	float4 _NormalMapDetail_ST;
	float4 _liquidmask_ST;
	float4 _Texture2_ST; //Liquid Tex
	float4 _Texture3_ST; //Liquid Normal
	float4 _overtex1_ST;
	float4 _overtex2_ST;
	float4 _overtex3_ST;
	float4 _DetailMask_ST;
	float4 _NormalMask_ST;
	float4 _RampG_ST;
	float4 _LineMask_ST;
	float _Cutoff;
	float4 _overcolor1;
	float4 _overcolor2;
	float4 _overcolor3;
	float _rimpower;
	float _rimV;
	float4 _SpecularColor;
	float _SpeclarHeight;
	float _SpecularPower;
	float _SpecularPowerNail;
	float _ShadowExtend;
	float _DetailNormalMapScale;
	float _linetexon;
	float _alpha_a;
	float _alpha_b;
	float _notusetexspecular;
	float _nip_specular;
	float _nipsize;
	float _nip;
	float _liquidftop;
	float _liquidfbot;
	float _liquidface;
	float _liquidbtop;
	float _liquidbbot;
	float4 _LiquidTiling;
	float _tex1mask;

	//Global light params set by KK 
	float4 _LineColorG;
	float _linewidthG; 
	float4 _ambientshadowG; //Shadow color 
	float _FaceShadowG;
	float _FaceNormalG;

#endif