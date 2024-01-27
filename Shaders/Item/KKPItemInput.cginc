#ifndef KKP_ITEM_INPUT
#define KKP_ITEM_INPUT

#include "../KKPDeclarations.cginc"
#define SAMPLERTEX _MainTex

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
	bool _UseRampForShadows;
	bool _UseLightColorSpecular;
	int _AlphaOptionCutoff;
	bool _OutlineOn;
	bool _UseDetailRAsSpecularMap;
	bool _UseKKPRim;
	int _CullOption;
	float _UseKKMetal;

	float _NormalMapScale;
	float _DetailNormalMapScale;

	float4 _OutlineColor;

	float4 _KKPRimColor;
	float _KKPRimSoft;
	float _KKPRimIntensity;
	float _KKPRimAsDiffuse;
	float _KKPRimRotateX;
	float _KKPRimRotateY;

	//Input Textures
	DECLARE_TEX2D(_MainTex);
	DECLARE_TEX2D_NOSAMPLER(_AlphaMask);
	DECLARE_TEX2D_NOSAMPLER(_NormalMap);
	DECLARE_TEX2D_NOSAMPLER(_NormalMapDetail);
	DECLARE_TEX2D_NOSAMPLER(_liquidmask);
	DECLARE_TEX2D_NOSAMPLER(_Texture2); //Liquid Tex
	DECLARE_TEX2D_NOSAMPLER(_Texture3); //Liquid Normal
	DECLARE_TEX2D_NOSAMPLER(_ColorMask);
	DECLARE_TEX2D(_LineMask);
	sampler2D _DetailMask;
	sampler2D _NormalMask;
	sampler2D _AnotherRamp;
	sampler2D _RampG;
	
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
	float4 _ShadowHSV;
	float _SpecularNormalScale;
	float _SpecularDetailNormalScale;
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
	
	float _DisablePointLights;
	float _AdjustBackfaceNormals;
	float _rimReflectMode;
	
#ifdef STUDIO_SHADER
	float _ambientshadowOFF;
	float _EmissionPower;
#ifdef ALPHA_SHADER
	float _alpha;
	float _AlphaOptionZWrite;
#endif

	DECLARE_TEX2D(_PatternMask1);
	DECLARE_TEX2D_NOSAMPLER(_PatternMask2);
	DECLARE_TEX2D_NOSAMPLER(_PatternMask3);
	float4 _PatternMask1_ST;
	float4 _PatternMask2_ST;
	float4 _PatternMask3_ST;
	float4 _Patternuv1;
	float4 _Patternuv2;
	float4 _Patternuv3;
	float _patternrotator1;
	float _patternrotator2;
	float _patternrotator3;
	float _patternclamp1;
	float _patternclamp2;
	float _patternclamp3;
	
	float4 _Color1_2;
	float4 _Color2_2;
	float4 _Color3_2;
#endif
	
#ifndef DEFINED_CLOCK
	#ifndef STUDIO_SHADER
		#define DEFINED_CLOCK
		float4 _Clock;
	#endif
#endif

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