﻿Shader "xukmi/HairPlusTessReflect"
{
	Properties
	{
		_AnotherRamp ("Another Ramp(ViewDir)", 2D) = "white" {}
		_MainTex ("MainTex", 2D) = "white" {}
		_NormalMap ("Normal Map", 2D) = "bump" {}
		_AlphaMask ("Alpha Mask", 2D) = "white" {}
		_DetailMask ("Detail Mask", 2D) = "black" {}
		_HairGloss ("Gloss Mask", 2D) = "black" {}
		_SpeclarHeight ("Speclar Height", Range(0, 1)) = 0.85
		_SpecularHairPower ("Specular Power", Range(0, 1)) = 1
		_rimpower ("Rim Width", Range(0, 1)) = 0.5
		_rimV ("Rim Strength", Range(0, 1)) = 0.75
		_ShadowExtend ("Shadow Extend", Range(0, 1)) = 0.5
		_ColorMask ("Color Mask", 2D) = "black" {}
		[Gamma]_Color ("Color", Vector) = (1,1,1,1)
		[Gamma]_Color2 ("Color2", Vector) = (0.7843137,0.7843137,0.7843137,1)
		[Gamma]_Color3 ("Color3", Vector) = (0.5,0.5,0.5,1)
		[Gamma]_GlossColor ("GlossColor", Vector) = (1.0,1.0,1.0,1.0)
		[Gamma]_SpecularColor ("SpecularColor", Vector) = (1.0,1.0,1.0,1.0)
		[Gamma]_LineColor ("LineColor", Vector) = (0.5,0.5,0.5,1)
		[Gamma]_ShadowColor ("Shadow Color", Vector) = (0.628,0.628,0.628,1)
		_ShadowHSV ("Shadow HSV", Vector) = (0, 0, 0, 0)
		[Gamma]_CustomAmbient("Custom Ambient", Color) = (0.666666666, 0.666666666, 0.666666666, 1)
		_NormalMapScale ("NormalMapScale", Float) = 1
		_Cutoff ("Alpha cutoff", Range(0, 1)) = 0.5
		[MaterialToggle] _UseRampForLights ("Use Ramp For Light", Float) = 1
		[MaterialToggle] _UseRampForSpecular ("Use Ramp For Specular", Float) = 0
		[MaterialToggle] _SpecularIsHighlights ("Specular is highlight", Float) = 0
		_SpecularIsHighLightsPow ("Specular is highlight", Range(0,128)) = 64
		_SpecularIsHighlightsRange ("Specular is highlight Range", Range(0, 20)) = 5
		[MaterialToggle] _UseMeshSpecular ("Use Mesh Specular", Float) = 0
		[MaterialToggle] _UseLightColorSpecular ("Use Light Color Specular", Float) = 1
		_EmissionMask ("Emission Mask", 2D) = "black" {}
		[Gamma]_EmissionColor("Emission Color", Color) = (1, 1, 1, 1)
		_EmissionIntensity("Emission Intensity", Float) = 1
		_LineWidthS ("LineWidthS", Float) = 1
		[Enum(Off,0,On,1)]_OutlineOn ("Outline On", Float) = 1.0
		[Enum(Off,0,On,1)]_SpecularHeightInvert ("Specular Height Invert", Float) = 0
		[MaterialToggle] _UseDetailRAsSpecularMap ("Use DetailR as Specular Map", Float) = 0
		
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

		_UseKKPRim ("Use KKP Rim", Range(0 ,1)) = 0
		[Gamma]_KKPRimColor ("Body Rim Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_KKPRimSoft ("Body Rim Softness", Float) = 1.5
		_KKPRimIntensity ("Body Rim Intensity", Float) = 0.75
		_KKPRimAsDiffuse ("Body Rim As Diffuse", Range(0, 1)) = 0.0
		_KKPRimRotateX("Body Rim Rotate X", Float) = 0.0
		_KKPRimRotateY("Body Rim Rotate Y", Float) = 0.0
		
		_ReflectMap ("Reflect Body Map", 2D) = "white" {}
		_Roughness ("Roughness", Range(0, 1)) = 0.75
		_ReflectionVal ("ReflectionVal", Range(0, 1)) = 1.0
		[Gamma]_ReflectCol("Reflection Color", Color) = (1, 1, 1, 1)
		_ReflectionMapCap ("Matcap", 2D) = "white" {}
		_UseMatCapReflection ("Use Matcap or Env", Range(0, 1)) = 1.0
		_ReflBlendSrc ("Reflect Blend Src", Float) = 2.0
		_ReflBlendDst ("Reflect Blend Dst", Float) = 0.0
		_ReflBlendVal ("Reflect Blend Val", Range(0, 1)) = 1.0
		
		_ReflectColMix ("Reflection Color Mix Amount", Range(0,1)) = 1
		_ReflectRotation ("Matcap Rotation", Range(0, 360)) = 0
		_ReflectMask ("Reflect Body Mask", 2D) = "white" {}
		_DisablePointLights ("Disable Point Lights", Range(0,1)) = 0.0
		_DisableShadowedMatcap ("Disable Shadowed Matcap", Range(0,1)) = 0.0
		[MaterialToggle] _AdjustBackfaceNormals ("Adjust Backface Normals", Float) = 0.0
		[Enum(Off,0,Front,1,Back,2)] _CullOption ("Cull Option", Range(0, 2)) = 0
		_rimReflectMode ("Rimlight Placement", Float) = 0.0
		
		_SpecularNormalScale ("Specular Normal Map Relative Scale", Float) = 1
	}
	SubShader
	{
		LOD 600
		Tags {"RenderType" = "Opaque" }
		//Outline
		Pass
		{
			Name "Outline"
			LOD 600
			Tags {"RenderType" = "Opaque" "ShadowSupport" = "true" }
			Cull Front

			CGPROGRAM
			#pragma target 5.0
			#pragma vertex TessVert
			#pragma fragment frag
			#pragma hull hull
			#pragma domain domain
			#pragma only_renderers d3d11 glcore gles gles3 metal d3d11_9x xboxone ps4 psp2 n3ds wiiu 
			
			#define TESS_MID
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			#include "KKPHairInput.cginc"
			#include "KKPHairDiffuse.cginc"
			#include "../KKPDisplace.cginc"

			Varyings vert (VertexData v)
			{
				Varyings o;
				
				float4 vertex = v.vertex;
				float3 normal = v.normal;
				DisplacementValues(v, vertex, normal);
				v.vertex = vertex;
				v.normal = normal;
				
				float alphaMask = SAMPLE_TEX2D_SAMPLER_LOD(_AlphaMask, SAMPLERTEX, v.uv0 * _AlphaMask_ST.xy + _AlphaMask_ST.zw, 0).r;
				float mainAlpha = SAMPLE_TEX2D_LOD(_MainTex, v.uv0 * _MainTex_ST.xy + _MainTex_ST.zw, 0).a;
				float alpha = alphaMask * mainAlpha;
				o.posWS = mul(unity_ObjectToWorld, v.vertex);

				float3 viewDir = o.posWS - _WorldSpaceCameraPos.xyz; //This is inverted?
				float viewVal = dot(viewDir, viewDir);
				viewVal = sqrt(viewVal);
				viewVal = viewVal * 0.0999999866 + 0.300000012;
				float lineVal = _linewidthG * 0.00499999989;
				viewVal *= lineVal * _LineWidthS;
				alpha *= viewVal;

				float4 detailMask = tex2Dlod(_DetailMask, float4(v.uv0 * _DetailMask_ST.xy + _DetailMask_ST.zw, 0, 0));
				float inverseMask = 1 - detailMask.z;
				alpha *= inverseMask;

				//Not too sure what's going on, some viewspace based outlines?
				float4 u_xlat0;
				u_xlat0.xyz = v.normal.xyz * alpha + v.vertex.xyz;
				o.posCS = UnityObjectToClipPos(u_xlat0.xyz);
				o.uv0 = v.uv0;
				1;
				return o;
			}
			
			#include "KKPHairTess.cginc"

			fixed4 frag (Varyings i) : SV_Target
			{
				
				float4 mainTex = SAMPLE_TEX2D_SAMPLER(_MainTex, SAMPLERTEX, i.uv0 * _MainTex_ST.xy + _MainTex_ST.zw);
				float alpha = AlphaClip(i.uv0, _OutlineOn ? mainTex.a : 0);

				float3 diffuse = GetDiffuse(i.uv0);
				float3 diffuseMainTex = -diffuse * mainTex.xyz + 1;
				diffuse = mainTex * diffuse;
				diffuse *= _LineColor.rgb;
				diffuse += diffuse;
				float3 lineColor = _LineColor.rgb - 0.5;
				lineColor = -lineColor * 2 + 1;
				lineColor = -lineColor * diffuseMainTex + 1;
			
				bool3 colCheck = 0.5 < _LineColor.rgb;		
				{
					float3 hlslcc_movcTemp = diffuse;
					hlslcc_movcTemp.x = (colCheck.x) ? lineColor.x : diffuse.x;
					hlslcc_movcTemp.y = (colCheck.y) ? lineColor.y : diffuse.y;
					hlslcc_movcTemp.z = (colCheck.z) ? lineColor.z : diffuse.z;
					diffuse = hlslcc_movcTemp;
				}	
				diffuse = saturate(diffuse);
				float3 lightCol = _LightColor0.xyz * float3(0.600000024, 0.600000024, 0.600000024) + _CustomAmbient.rgb;
				diffuse *= lightCol;

				return float4(diffuse, 1);
			}
			ENDCG
		}
		
		//Main Pass
		Pass
		{
			Name "Forward"
			LOD 600
			Tags { "LightMode" = "ForwardBase" "RenderType" = "Opaque" "ShadowSupport" = "true" }
			Cull [_CullOption]

			CGPROGRAM
			#pragma target 5.0

			#pragma vertex TessVert
			#pragma fragment frag
			#pragma hull hull
			#pragma domain domain
			#pragma only_renderers d3d11 glcore gles gles3 metal d3d11_9x xboxone ps4 psp2 n3ds wiiu 
			#pragma multi_compile _ VERTEXLIGHT_ON
			#pragma multi_compile _ SHADOWS_SCREEN
			
			#define KKP_EXPENSIVE_RAMP
			#define TESS_SHADER

			//Unity Includes
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
			#include "Lighting.cginc"

			#include "KKPHairInput.cginc"
			#include "KKPHairDiffuse.cginc"
			#include "KKPHairNormals.cginc"
			#include "../KKPDisplace.cginc"
			#include "../KKPVertexLights.cginc"
			#include "../KKPVertexLightsSpecular.cginc"
			#include "../KKPEmission.cginc"
			
			#include "KKPHairVertFrag.cginc" //Vert Frag here
			
			#include "KKPHairTess.cginc"

			ENDCG
		}
		
		//Reflection Pass
		Pass{
			Name "Reflect"
			LOD 600
			Tags { "LightMode" = "ForwardBase" "Queue" = "Transparent-100" "RenderType" = "Transparent" "ShadowSupport" = "true" }
			Blend [_ReflBlendSrc] [_ReflBlendDst]
			CGPROGRAM
			#pragma target 5.0
			#pragma vertex TessVert
			#pragma fragment reflectfrag
			#pragma hull hull
			#pragma domain domain
			#pragma only_renderers d3d11 glcore gles gles3 metal d3d11_9x xboxone ps4 psp2 n3ds wiiu 
			
			#pragma multi_compile _ VERTEXLIGHT_ON
			#pragma multi_compile _ SHADOWS_SCREEN

			#define KKP_EXPENSIVE_RAMP

			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
			#include "Lighting.cginc"
			
			#include "KKPHairInput.cginc"
			#include "KKPHairDiffuse.cginc"
			#include "KKPHairNormals.cginc"
			#include "../KKPDisplace.cginc"
			#include "../KKPVertexLights.cginc"
			#include "../KKPVertexLightsSpecular.cginc"
			
			#include "KKPHairReflect.cginc"

			Varyings vert (VertexData v)
			{
				Varyings o;
				
				float4 vertex = v.vertex;
				float3 normal = v.normal;
				DisplacementValues(v, vertex, normal);
				v.vertex = vertex;
				v.normal = normal;

				o.posWS = mul(unity_ObjectToWorld, v.vertex);
				o.posCS = UnityObjectToClipPos(v.vertex);
				o.normalWS = UnityObjectToWorldNormal(v.normal);
				o.tanWS = float4(UnityObjectToWorldDir(v.tangent.xyz), v.tangent.w);
				float3 biTan = cross(o.tanWS, o.normalWS);
				o.bitanWS = normalize(biTan);
				o.uv0 = v.uv0;
				return o;
			}
			
			#include "KKPHairTess.cginc"
			
			ENDCG
		}
		
		//ShadowCaster
		Pass
		{
			Name "ShadowCaster"
			LOD 600
			Tags { "LightMode" = "ShadowCaster" "RenderType" = "Opaque" "ShadowSupport" = "true" }
			Offset 1, 1
			Cull Back

			CGPROGRAM
			#pragma vertex TessVert
			#pragma fragment frag
			#pragma hull hull
			#pragma domain domain
			#pragma multi_compile_shadowcaster
			#pragma only_renderers d3d11 glcore gles gles3 metal d3d11_9x xboxone ps4 psp2 n3ds wiiu 
			
			#define SHADOW_CASTER_PASS
			#define TESS_LOW

			#include "UnityCG.cginc"

			#include "KKPHairInput.cginc"
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
			
			#include "KKPHairTess.cginc"

            float4 frag(v2f i) : SV_Target
            {
				float4 mainTex = SAMPLE_TEX2D_SAMPLER(_MainTex, SAMPLERTEX, i.uv0 * _MainTex_ST.xy + _MainTex_ST.zw);
				float2 alphaUV = i.uv0 * _AlphaMask_ST.xy + _AlphaMask_ST.zw;
				float4 alphaMask = SAMPLE_TEX2D_SAMPLER(_AlphaMask, SAMPLERTEX, alphaUV);
				float alphaVal = alphaMask.x * mainTex.a;
				float clipVal = (alphaVal.x - _Cutoff) < 0.0f;
				if(clipVal * int(0xffffffffu) != 0)
					discard;

                SHADOW_CASTER_FRAGMENT(i)
            }
			ENDCG
		}
	}
	Fallback "Unlit/Texture"
}
