Shader "xukmi/MainItemStudioAlphaPlusTess"
{
	Properties
	{
		// Vanilla textures
		_AnotherRamp ("Another Ramp(LineR)", 2D) = "white" {}
		_ColorMask ("Color Mask", 2D) = "black" {}
		_DetailMask ("Detail Mask", 2D) = "black" {}
		_LineMask ("Line Mask", 2D) = "black" {}
		_MainTex ("MainTex", 2D) = "white" {}
		_NormalMap ("Normal Map", 2D) = "bump" {}
		_PatternMask1 ("Pattern 1", 2D) = "white" {}
		_PatternMask2 ("Pattern 2", 2D) = "white" {}
		_PatternMask3 ("Pattern 3", 2D) = "white" {}
		
		// Additional textures
		_NormalMapDetail ("Normal Map Detail", 2D) = "bump" {}
		_EmissionMask ("Emission Mask", 2D) = "black" {}
		
		// Vanilla colors and vectors
		[Gamma]_Color ("Color", Color) = (1,1,1,1)
		[Gamma]_Color1_2 ("Col1 Pattern Color", Color) = (1,1,1,1)
		[Gamma]_Color2 ("Color2", Color) = (1,1,1,1)
		[Gamma]_Color2_2 ("Col2 Pattern Color", Color) = (1,1,1,1)
		[Gamma]_Color3 ("Color3", Color) = (1,1,1,1)
		[Gamma]_Color3_2 ("Col3 Pattern Color", Color) = (1,1,1,1)
		[Gamma]_ShadowColor ("Shadow Color", Vector) = (0.628,0.628,0.628,1)
		
		_Patternuv1 ("Pattern 1 additional ST", Vector) = (0,0,1,1)
		_Patternuv2 ("Pattern 2 additional ST", Vector) = (0,0,1,1)
		_Patternuv3 ("Pattern 3 additional ST", Vector) = (0,0,1,1)
		
		// Additional colors and vectors
		[Gamma]_EmissionColor("Emission Color", Color) = (1,1,1,1)
		[Gamma]_SpecularColor ("Specular Color", Color) = (1,1,1,1)
		[Gamma]_CustomAmbient("Custom Ambient", Color) = (0.666666666, 0.666666666, 0.666666666, 1)
		[Gamma]_OutlineColor ("Outline Color", Color) = (0,0,0,0)
		
		// Vanilla toggles and floats
		[MaterialToggle] _ambientshadowOFF ("Ambient Shadow OFF", Float) = 0
		[MaterialToggle] _AnotherRampFull ("Another Ramp Full", Float) = 0
		[MaterialToggle] _DetailBLineG ("DetailB LineG", Float) = 0
		[MaterialToggle] _DetailRLineR ("DetailR LineR", Float) = 0
		[MaterialToggle] _notusetexspecular ("not use tex specular", Float) = 0
		[MaterialToggle] _patternclamp1 ("Pattern 1 tile clamp", Float) = 0
		[MaterialToggle] _patternclamp2 ("Pattern 2 tile clamp", Float) = 0
		[MaterialToggle] _patternclamp3 ("Pattern 3 tile clamp", Float) = 0
		
		_alpha ("Alpha", Float) = 1.0
		_EmissionPower("Emission Power", Float) = 1
		_LineWidthS ("LineWidthS", Float) = 1
		_patternrotator1 ("Pattern 1 rotation", Range(-1,1)) = 0
		_patternrotator2 ("Pattern 2 rotation", Range(-1,1)) = 0
		_patternrotator3 ("Pattern 3 rotation", Range(-1,1)) = 0
		_rimpower ("Rim Width", Range(0, 1)) = 0.5
		_rimV ("Rim Strength", Range(0, 1)) = 0.5
		_ShadowExtend ("Shadow Extend", Range(0, 1)) = 1
		_ShadowExtendAnother ("Shadow Extend Another", Range(0, 1)) = 1
		_SpeclarHeight ("Speclar Height", Range(0, 1)) = 0.98
		_SpecularPower ("Specular Power", Range(0, 1)) = 0
		
		// Additional toggles and floats
		[Enum(Off,0,On,1)] _AlphaOptionCutoff ("Cutoff On", Float) = 1.0
		[Enum(Off,0,On,1)] _AlphaOptionZWrite ("ZWrite", Float) = 1.0
		[Enum(Off,0,Front,1,Back,2)] _CullOption ("Cull Option", Range(0, 2)) = 2
		[Enum(Off,0,On,1)] _OutlineOn ("Outline On", Float) = 1.0
		[MaterialToggle] _UseRampForLights ("Use Ramp For Light", Float) = 1
		[MaterialToggle] _UseRampForSpecular ("Use Ramp For Specular", Float) = 0
		[MaterialToggle] _UseLightColorSpecular ("Use Light Color Specular", Float) = 1
		[MaterialToggle] _UseDetailRAsSpecularMap ("Use DetailR as Specular Map", Float) = 0
		
		_Cutoff ("Alpha cutoff", Range(0, 1)) = 0.0
		_DetailNormalMapScale ("Detail Normal Scale", Float) = 1
		_EmissionIntensity ("Emission Intensity", Float) = 0
		_NormalMapScale ("NormalMapScale", Float) = 1
		
		// KKPrim properties
		[Gamma]_KKPRimColor ("Body Rim Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_UseKKPRim ("Use KKP Rim", Range(0 ,1)) = 0
		_KKPRimSoft ("Body Rim Softness", Float) = 1.5
		_KKPRimIntensity ("Body Rim Intensity", Float) = 0.75
		_KKPRimAsDiffuse ("Body Rim As Diffuse", Range(0, 1)) = 0.0
		_KKPRimRotateX("Body Rim Rotate X", Float) = 0.0
		_KKPRimRotateY("Body Rim Rotate Y", Float) = 0.0
		
		// Matcap properties
 		_ReflectionMapCap("Mat Cap", 2D) = "black" {}
		_ReflectMapDetail ("Reflect Body Mask/Map", 2D) = "white" {}
		[Gamma]_ReflectCol("Reflection Color", Color) = (1, 1, 1, 1)
		_ReflectColMix ("Reflection Color Mix Amount", Range(0,1)) = 1
		_Reflective("Reflective", Range(0, 1)) = 0.75
		_ReflectiveBlend("Reflective Blend", Range(0, 1)) = 0.05
		_ReflectiveMulOrAdd("Mul Or Add", Range(0, 1)) = 1
		[Enum(Off,0,On,1)]_ReflectiveOverlayed ("Reflections Overlayed", Float) = 0.0
		_ReflectRotation ("Matcap Rotation", Range(0, 360)) = 0
		_UseKKMetal("Use KK Metal", Range(0, 1)) = 1
		_UseMatCapReflection("Use Mat Cap", Range(0, 1)) = 1
		
		// Tess properties
		_TessTex ("Tess Tex", 2D) = "white" {}
		_TessMax("Tess Max", Range(1, 25)) = 4
		_TessMin("Tess Min", Range(1, 25)) = 1
		_TessBias("Tess Distance Bias", Range(1, 100)) = 75
		_TessSmooth("Tess Smooth", Range(0, 1)) = 0
		_Tolerance("Tolerance", Range(0.0, 0.05)) = 0.0005
		_DisplaceTex("DisplacementTex", 2D) = "gray" {}
		_DisplaceMultiplier("DisplaceMultiplier", float) = 0
		_DisplaceNormalMultiplier("DisplaceNormalMultiplier", float) = 1
		_DisplaceFull("Displace Full", Range(-1, 1)) = 0
		
		_ShrinkVal("ShrinkVal", Range(0, 1)) = 1
		_ShrinkVerticalAdjust("Vertical Pos", Range(-1, 1)) = 0
		_Clock ("W is for displacement multiplier for animation", Vector) = (0,0,0,1)
		
		// Stuff added post-1.3.1
		_ShadowHSV ("Shadow HSV", Vector) = (0, 0, 0, 0)
		[MaterialToggle] _AdjustBackfaceNormals ("Adjust Backface Normals", Float) = 0.0
		_DisablePointLights ("Disable Point Lights", Range(0,1)) = 0.0
		_DisableShadowedMatcap ("Disable Shadowed Matcap", Range(0,1)) = 0.0
		_rimReflectMode ("Rimlight Placement", Float) = 0.0
		
		_SpecularNormalScale ("Specular Normal Map Relative Scale", Float) = 1
		_SpecularDetailNormalScale ("Specular Detail Normal Map Relative Scale", Float) = 1
	}
	SubShader
	{
		LOD 600
		Tags { "Queue" = "Transparent+1907" "RenderType" = "TransparentCutout" }

		//Main Pass
		Pass
		{
			Name "Forward"
			LOD 600
			Tags { "LightMode" = "ForwardBase" "Queue" = "Transparent+1907" "RenderType" = "TransparentCutout" "ShadowSupport" = "true" }
			Blend SrcAlpha OneMinusSrcAlpha, SrcAlpha OneMinusSrcAlpha
			Cull [_CullOption]
			ZWrite [_AlphaOptionZWrite]

			CGPROGRAM
			#pragma target 5.0

			#pragma vertex TessVert
			#pragma fragment frag
			#pragma hull hull
			#pragma domain domain
			#pragma only_renderers d3d11 glcore gles gles3 metal d3d11_9x xboxone ps4 psp2 n3ds wiiu 
			#pragma multi_compile _ VERTEXLIGHT_ON
			#pragma multi_compile _ SHADOWS_SCREEN
			
			#define STUDIO_SHADER
			#define ALPHA_SHADER
			
			//Unity Includes
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
			#include "Lighting.cginc"

			#define KKP_EXPENSIVE_RAMP

			#include "KKPItemInput.cginc"
			#include "KKPItemDiffuse.cginc"
			#include "KKPItemNormals.cginc"
			#include "../KKPDisplace.cginc"
			#include "../KKPCoom.cginc"
			#include "../KKPVertexLights.cginc"
			#include "../KKPVertexLightsSpecular.cginc"
			#include "../KKPEmission.cginc"
			#include "../KKPReflect.cginc"

			Varyings vert (VertexData v)
			{
				Varyings o;
				
				float4 vertex = v.vertex;
				float3 normal = v.normal;
				DisplacementValues(v, vertex, normal);
				v.vertex = vertex;
				v.normal = normal;
				
				o.posWS = mul(unity_ObjectToWorld, v.vertex);
				o.posCS = mul(UNITY_MATRIX_VP, o.posWS);
				o.normalWS = UnityObjectToWorldNormal(v.normal);
				o.tanWS = float4(UnityObjectToWorldDir(v.tangent.xyz), v.tangent.w);
				float3 biTan = cross(o.tanWS, o.normalWS);
				o.bitanWS = normalize(biTan);
				o.uv0 = v.uv0;
				
			#ifdef SHADOWS_SCREEN
				float4 projPos = o.posCS;
				projPos.y *= _ProjectionParams.x;
				float4 projbiTan;
				projbiTan.xyz = biTan;
				projbiTan.xzw = projPos.xwy * 0.5;
				o.shadowCoordinate.zw = projPos.zw;
				o.shadowCoordinate.xy = projbiTan.zz + projbiTan.xw;
			#endif
				1;
				return o;
			}

			#include "KKPItemTess.cginc"
			#include "KKPStudioItemFrag.cginc"

			ENDCG
		}
		
		//ShadowCaster
		Pass
		{
			Name "ShadowCaster"
			LOD 600
			Tags { "LightMode" = "ShadowCaster" "Queue" = "Transparent+1907" "RenderType" = "TransparentCutout" "ShadowSupport" = "true" }
			Offset 1, 1
			Cull Off

			CGPROGRAM
			#pragma target 5.0
			
			#pragma vertex TessVert
			#pragma fragment frag
			#pragma hull hull
			#pragma domain domain
			#pragma multi_compile_shadowcaster
			#pragma only_renderers d3d11 glcore gles gles3 metal d3d11_9x xboxone ps4 psp2 n3ds wiiu 
			
			#define SHADOW_CASTER_PASS
			#define STUDIO_SHADER
			#define ALPHA_SHADER
			#define TESS_LOW

			#include "UnityCG.cginc"

			#include "KKPItemInput.cginc"
			#include "../KKPDisplace.cginc"

            struct v2f { 
				float2 uv0 : TEXCOORD1;
                V2F_SHADOW_CASTER;
            };

            v2f vert(VertexData v)
            {
                v2f o;
				
				float4 vertex = v.vertex;
				float3 normal = v.normal;
				DisplacementValues(v, vertex, normal);
				v.vertex = vertex;
				v.normal = normal;
				
				o.uv0 = v.uv0;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
				float mainTexAlpha = SAMPLE_TEX2D_SAMPLER(_MainTex, SAMPLERTEX, i.uv0 * _MainTex_ST.xy + _MainTex_ST.zw).a;
				if(mainTexAlpha * _alpha <= _Cutoff)
					discard;
                SHADOW_CASTER_FRAGMENT(i)
            }
			
			#include "KKPItemTess.cginc"
			
			ENDCG
		}
	}
	Fallback "Unlit/Texture"
}
