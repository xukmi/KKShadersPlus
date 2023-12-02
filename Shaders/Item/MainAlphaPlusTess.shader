Shader "xukmi/MainAlphaPlusTess"
{
	Properties
	{
		_AnotherRamp ("Another Ramp(LineR)", 2D) = "white" {}
		_MainTex ("MainTex", 2D) = "white" {}
		_NormalMap ("Normal Map", 2D) = "bump" {}
		_NormalMapDetail ("Normal Map Detail", 2D) = "bump" {}
		_DetailMask ("Detail Mask", 2D) = "black" {}
		_LineMask ("Line Mask", 2D) = "black" {}
		_AlphaMask ("Alpha Mask", 2D) = "white" {}
		_EmissionMask ("Emission Mask", 2D) = "black" {}
		[Gamma]_EmissionColor("Emission Color", Color) = (1, 1, 1, 1)
		_EmissionIntensity("Emission Intensity", Float) = 1
		[Gamma]_ShadowColor ("Shadow Color", Vector) = (0.628,0.628,0.628,1)
		[Gamma]_SpecularColor ("Specular Color", Vector) = (1,1,1,1)
		_SpeclarHeight ("Speclar Height", Range(0, 1)) = 0.98
		_SpecularPower ("Specular Power", Range(0, 1)) = 0
		_SpecularPowerNail ("Specular Power Nail", Range(0, 1)) = 0
		_ShadowExtend ("Shadow Extend", Range(0, 1)) = 1
		_ShadowExtendAnother ("Shadow Extend Another", Range(0, 1)) = 0
		_rimpower ("Rim Width", Range(0, 1)) = 0.5
		_rimV ("Rim Strength", Range(0, 1)) = 0.5
		[MaterialToggle] _alpha_a ("alpha_a", Float) = 1
		[MaterialToggle] _alpha_b ("alpha_b", Float) = 1
		[MaterialToggle] _DetailBLineG ("DetailB LineG", Float) = 0
		[MaterialToggle] _DetailRLineR ("DetailR LineR", Float) = 0
		[MaterialToggle] _notusetexspecular ("not use tex specular", Float) = 0
		_liquidmask ("Liquid Mask", 2D) = "black" {}
		_Texture2 ("Liquid Tex", 2D) = "black" {}
		_Texture3 ("Liquid Normal", 2D) = "bump" {}
		_LiquidTiling ("Liquid Tiling (u/v/us/vs)", Vector) = (0,0,2,2)
		_liquidftop ("liquidftop", Range(0, 2)) = 0
		_liquidfbot ("liquidfbot", Range(0, 2)) = 0
		_liquidbtop ("liquidbtop", Range(0, 2)) = 0
		_liquidbbot ("liquidbbot", Range(0, 2)) = 0
		_liquidface ("liquidface", Range(0, 2)) = 0
		_Cutoff ("Alpha cutoff", Range(0, 1)) = 0.5
		[Gamma]_CustomAmbient("Custom Ambient", Color) = (0.666666666, 0.666666666, 0.666666666, 1)
		_NormalMapScale ("NormalMapScale", Float) = 1
		_DetailNormalMapScale ("Detail Normal Scale", Float) = 1
		[MaterialToggle] _UseRampForLights ("Use Ramp For Light", Float) = 1
		[MaterialToggle] _UseRampForSpecular ("Use Ramp For Specular", Float) = 0
		[MaterialToggle] _UseRampForShadows ("Use Ramp For Shadows", Float) = 0
		[MaterialToggle] _UseLightColorSpecular ("Use Light Color Specular", Float) = 1
		[MaterialToggle] _UseDetailRAsSpecularMap ("Use DetailR as Specular Map", Float) = 0
		[Enum(Off,0,On,1)]_AlphaOptionZWrite ("ZWrite", Float) = 1.0
		[Enum(Off,0,On,1)]_AlphaOptionCutoff ("Cutoff On", Float) = 1.0
		[Enum(Off,0,On,1)]_OutlineOn ("Outline On", Float) = 0.0
		[Gamma]_OutlineColor ("Outline Color", Color) = (0, 0, 0, 0)
		[Enum(Off,0,Front,1,Back,2)] _CullOption ("Cull Option", Range(0, 2)) = 2
		_LineWidthS ("LineWidthS", Float) = 1
		_Reflective("Reflective", Range(0, 1)) = 0.75
		_ReflectiveBlend("Reflective Blend", Range(0, 1)) = 0.05
		_ReflectiveMulOrAdd("Mul Or Add", Range(0, 1)) = 1
		_UseKKMetal("Use KK Metal", Range(0, 1)) = 1
		_AnotherRampFull("Another Ramp", Range(0, 1)) = 0
		_Alpha ("AlphaValue", Float) = 1
		_UseMatCapReflection("Use Mat Cap", Range(0, 1)) = 1
 		_ReflectionMapCap("Mat Cap", 2D) = "black" {}
		_UseKKPRim ("Use KKP Rim", Range(0 ,1)) = 0
		[Gamma]_KKPRimColor ("Body Rim Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_KKPRimSoft ("Body Rim Softness", Float) = 1.5
		_KKPRimIntensity ("Body Rim Intensity", Float) = 0.75
		_KKPRimAsDiffuse ("Body Rim As Diffuse", Range(0, 1)) = 0.0
		_KKPRimRotateX("Body Rim Rotate X", Float) = 0.0
		_KKPRimRotateY("Body Rim Rotate Y", Float) = 0.0
		
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
		_DisablePointLights ("Disable Point Lights", Float) = 0.0
	}
	SubShader
	{
		LOD 600
		Tags { "Queue" = "Transparent+40" "RenderType" = "TransparentCutout" }
		//Outline
		Pass
		{
			Name "Outline"
			LOD 600
			Tags {"Queue" = "Transparent" "RenderType" = "TransparentCutout" "ShadowSupport" = "true" }
			Cull Front

			CGPROGRAM
			#pragma target 5.0

			#pragma vertex TessVert
			#pragma fragment frag
			#pragma hull hull
			#pragma domain domain

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			#include "KKPItemInput.cginc"
			#include "../KKPDisplace.cginc"
			#include "KKPItemDiffuse.cginc"
			#define TESS_MID
			Varyings vert (VertexData v)
			{
				float4 vertex = v.vertex;
				float3 normal = v.normal;
				DisplacementValues(v, vertex, normal);
				v.vertex = vertex;
				v.normal = normal;

				Varyings o;
				o.posWS = mul(unity_ObjectToWorld, v.vertex);
				float3 viewDir = _WorldSpaceCameraPos.xyz - o.posWS.xyz;
				float viewVal = dot(viewDir, viewDir);
				viewVal = sqrt(viewVal);
				viewVal = viewVal * 0.0999999866 + 0.300000012;
				float lineVal = _linewidthG * 0.00499999989;
				viewVal *= lineVal;
				float2 detailMaskUV = v.uv0 * _DetailMask_ST.xy + _DetailMask_ST.zw;
				float4 detailMask = tex2Dlod(_DetailMask, float4(detailMaskUV, 0, 0));
				float detailB = 1 - detailMask.b;
				viewVal *= detailB * _LineWidthS;
				float3 invertSquare;
				float3 x;
				float3 y;
				float3 z;
				x.x = unity_WorldToObject[0].x;
				x.y = unity_WorldToObject[1].x;
				x.z = unity_WorldToObject[2].x;
				float xLen = rsqrt(dot(x, x));
				y.x = unity_WorldToObject[0].y;
				y.y = unity_WorldToObject[1].y;
				y.z = unity_WorldToObject[2].y;
				float yLen = rsqrt(dot(y, y));
				z.x = unity_WorldToObject[0].z;
				z.y = unity_WorldToObject[1].z;
				z.z = unity_WorldToObject[2].z;
				float zLen = rsqrt(dot(z, z));
				float3 view = viewVal / float3(xLen, yLen,zLen);
				view = v.normal * view + v.vertex;
				o.posCS = UnityObjectToClipPos(view);
				//Big brain place offscreen
				if(!_OutlineOn)
					o.posCS = float4(2,2,2,1);
				o.uv0 = v.uv0;
				return o;
			}
			

			#include "KKPItemTess.cginc"

			fixed4 frag (Varyings i) : SV_Target
			{
				float4 mainTex = tex2D(_MainTex, i.uv0 * _MainTex_ST.xy + _MainTex_ST.zw);
				AlphaClip(i.uv0, _OutlineOn ? mainTex.a * _Alpha : 0);

				float3 diffuse = mainTex.rgb;
				float3 shadingAdjustment = ShadeAdjust(diffuse);


				bool3 compTest = 0.555555582 < shadingAdjustment.xyz;
				float3 diffuseShaded = shadingAdjustment.xyz * 0.899999976 - 0.5;
				diffuseShaded = -diffuseShaded * 2 + 1;
				float4 ambientShadow = 1 - _ambientshadowG.wxyz;
				float3 ambientShadowIntensity = -ambientShadow.x * ambientShadow.yzw + 1;
				float ambientShadowAdjust = _ambientshadowG.w * 0.5 + 0.5;
				float ambientShadowAdjustDoubled = ambientShadowAdjust + ambientShadowAdjust;
				bool ambientShadowAdjustShow = 0.5 < ambientShadowAdjust;
				ambientShadow.rgb = ambientShadowAdjustDoubled * _ambientshadowG.rgb;
				float3 finalAmbientShadow = ambientShadowAdjustShow ? ambientShadowIntensity : ambientShadow.rgb;
				finalAmbientShadow = saturate(finalAmbientShadow);
				float3 invertFinalAmbientShadow = 1 - finalAmbientShadow;

				shadingAdjustment.xyz *= finalAmbientShadow;
				shadingAdjustment.xyz *= 1.79999995;
				diffuseShaded = -diffuseShaded * invertFinalAmbientShadow + 1;
				{
					float3 hlslcc_movcTemp = shadingAdjustment;
					hlslcc_movcTemp.x = (compTest.x) ? diffuseShaded.x : shadingAdjustment.x;
					hlslcc_movcTemp.y = (compTest.y) ? diffuseShaded.y : shadingAdjustment.y;
					hlslcc_movcTemp.z = (compTest.z) ? diffuseShaded.z : shadingAdjustment.z;
					shadingAdjustment = saturate(hlslcc_movcTemp);
				}
				float2 detailMaskUV = i.uv0 * _DetailMask_ST.xy + _DetailMask_ST.zw;
				float4 detailMask = tex2D(_DetailMask, detailMaskUV);

				float specularMap = _UseDetailRAsSpecularMap ? detailMask.r : 1;
				_SpecularPower *= specularMap;
				
				float2 lineMaskUV = i.uv0 * _LineMask_ST.xy + _LineMask_ST.zw;
				float4 lineMask = tex2D(_LineMask, lineMaskUV);

				float detailLine = detailMask.x - lineMask.x;
				detailLine = _DetailRLineR * detailLine + lineMask;
				detailLine = 1 - detailLine;
				float shadowExtendAnother = 1 - _ShadowExtendAnother;
				detailLine = max(detailLine, shadowExtendAnother);

				float3 finalDiffuse = saturate(detailLine * shadingAdjustment) * diffuse; 
				float3 halfDiffuse = finalDiffuse * 0.5;
				finalDiffuse = -finalDiffuse * 0.5 + 1.0;

				float outlineADoubled = _LineColorG.w * 2;
				halfDiffuse *= outlineADoubled;
				float outlineAAdjust = _LineColorG.w - 0.5;
				outlineAAdjust = -outlineAAdjust * 2.0 + 1.0;
				finalDiffuse = -outlineAAdjust * finalDiffuse + 1;

				finalDiffuse = 0.5 < _LineColorG.w ? finalDiffuse : halfDiffuse;
				finalDiffuse = saturate(finalDiffuse);
				float3 outLineCol = _LightColor0.rgb * float3(0.600000024, 0.600000024, 0.600000024) + _CustomAmbient.rgb;

				float3 finalColor = finalDiffuse * outLineCol;
				finalColor = lerp(finalColor, _OutlineColor.rgb, _OutlineColor.a);
				return float4(finalColor, 1.0 * _Alpha);
			}

			
			ENDCG
		}

		//Main Pass
		Pass
		{
			Name "Forward"
			LOD 600
			Tags { "LightMode" = "ForwardBase" "Queue" = "Transparent+40" "RenderType" = "TransparentCutout" "ShadowSupport" = "true" }
			Blend SrcAlpha OneMinusSrcAlpha, SrcAlpha OneMinusSrcAlpha
			Cull [_CullOption]
			ZWrite [_AlphaOptionZWrite]

			CGPROGRAM
			#pragma target 5.0

			#pragma vertex TessVert
			#pragma fragment frag
			#pragma hull hull
			#pragma domain domain
			#pragma multi_compile _ VERTEXLIGHT_ON
			#pragma multi_compile _ SHADOWS_SCREEN

			#define KKP_EXPENSIVE_RAMP
			#define ALPHA_SHADER
			
			//Unity Includes
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
			#include "Lighting.cginc"

			#include "KKPItemInput.cginc"
			#include "../KKPDisplace.cginc"
			#include "KKPItemDiffuse.cginc"
			#include "KKPItemNormals.cginc"
			#include "../KKPCoom.cginc"
			#include "../KKPVertexLights.cginc"
			#include "../KKPVertexLightsSpecular.cginc"
			#include "../KKPEmission.cginc"
			#include "../KKPReflect.cginc"
			#include "KKPItemFrag.cginc"


			Varyings vert (VertexData v)
			{
				float4 vertex = v.vertex;
				float3 normal = v.normal;
				DisplacementValues(v, vertex, normal);
				v.vertex = vertex;
				v.normal = normal;
				

				Varyings o;
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
				return o;
			}

			#include "KKPItemTess.cginc"
			
			ENDCG
		}

		//ShadowCaster
		Pass
		{
			Name "ShadowCaster"
			LOD 600
			Tags { "LightMode" = "ShadowCaster" "Queue" = "Transparent+40" "RenderType" = "TransparentCutout" "ShadowSupport" = "true" }
			Offset 1, 1
			Cull Off
		
			CGPROGRAM
			#pragma target 5.0

			#pragma vertex TessVert
			#pragma fragment frag
			#pragma hull hull
			#pragma domain domain
			#pragma multi_compile_shadowcaster

			#define SHADOW_CASTER_PASS

			#include "UnityCG.cginc"
			#include "KKPItemInput.cginc"
			#include "../KKPDisplace.cginc"
			#define TESS_LOW
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
			#include "KKPItemTess.cginc"
            float4 frag(v2f i) : SV_Target
            {
				float2 alphaUV = i.uv0 * _AlphaMask_ST.xy + _AlphaMask_ST.zw;
				float4 alphaMask = tex2D(_AlphaMask, alphaUV);
				float2 alphaVal = -float2(_alpha_a, _alpha_b) + float2(1.0f, 1.0f);
				float mainTexAlpha = tex2D(_MainTex, i.uv0 * _MainTex_ST.xy + _MainTex_ST.zw).a;
				alphaVal = max(alphaVal, alphaMask.xy);
				alphaVal = min(alphaVal.y, alphaVal.x);
				alphaVal *= mainTexAlpha;
				alphaVal.x -= 0.5f;
				float clipVal = alphaVal.x < _Cutoff;
				if(clipVal * int(0xffffffffu) != 0 && _AlphaOptionCutoff)
					discard;

                SHADOW_CASTER_FRAGMENT(i)
            }

			
			ENDCG
		}

		
	}
	Fallback "Unlit/Texture"
}
