Shader "xukmi/EyePlusTess"
{
	Properties
	{
		_MainTex ("MainTex", 2D) = "white" {}
		[Gamma]_overcolor1 ("overcolor1", Vector) = (1,1,1,1)
		_overtex1 ("overtex1", 2D) = "black" {}
		[Gamma]_overcolor2 ("overcolor2", Vector) = (1,1,1,1)
		_overtex2 ("overtex2", 2D) = "black" {}
		[MaterialToggle] _isHighLight ("isHighLight", Float) = 0
		_expression ("expression", 2D) = "black" {}
		_exppower ("exppower", Range(0, 1)) = 1
		_ExpressionSize ("Expression Size", Range(0, 1)) = 0.35
		_ExpressionDepth ("Expression Depth", Range(0, 2)) = 1
		[Gamma]_shadowcolor ("shadowcolor", Vector) = (0.6298235,0.6403289,0.747,1)
		_rotation ("rotation", Range(0, 1)) = 0
		[HideInInspector] _Cutoff ("Alpha cutoff", Range(0, 1)) = 0.5
		_EmissionMask ("Emission Mask", 2D) = "black" {}
		[Gamma]_EmissionColor("Emission Color", Color) = (1, 1, 1, 1)
		_EmissionIntensity("Emission Intensity", Float) = 1
		[Gamma]_CustomAmbient("Custom Ambient", Color) = (0.666666666, 0.666666666, 0.666666666, 1)
		[MaterialToggle] _UseRampForLights ("Use Ramp For Light", Float) = 1
		_DisablePointLights ("Disable Point Lights", Range(0,1)) = 0.0
		_ShadowHSV ("Shadow HSV", Vector) = (0, 0, 0, 0)
		
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
		_DisableShadowedMatcap ("Disable Shadowed Matcap", Range(0,1)) = 0.0
		
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
		_Clock ("W is for displacement multiplier for animation", Vector) = (0,0,0,1)
	}
	SubShader
	{
		LOD 600
		Tags { "IGNOREPROJECTOR" = "true" "QUEUE" = "Transparent" "RenderType" = "Transparent" }
		
		//Main Pass
		Pass {
			Name "Forward"
			LOD 600
			Tags { "IGNOREPROJECTOR" = "true" "LIGHTMODE" = "FORWARDBASE" "QUEUE" = "Transparent" "RenderType" = "Transparent" "SHADOWSUPPORT" = "true" }
			Blend SrcAlpha OneMinusSrcAlpha, SrcAlpha OneMinusSrcAlpha
			ZWrite Off
			
			Stencil {
				Ref 2
				Comp Always
				Pass Replace
				Fail Keep
				ZFail Keep
			}

			CGPROGRAM
			#pragma target 5.0
			#pragma vertex TessVert
			#pragma fragment frag
			#pragma hull hull
			#pragma domain domain
			
			#pragma multi_compile _ VERTEXLIGHT_ON
			#pragma multi_compile _ SHADOWS_SCREEN
			
			#define KKP_EXPENSIVE_RAMP
			#define MOVE_PUPILS
			
			//Unity Includes
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
			#include "Lighting.cginc"


			#include "KKPEyeInput.cginc"
			#include "KKPEyeDiffuse.cginc"
			#include "../KKPDisplace.cginc"
			#include "../KKPVertexLights.cginc"
			#include "../KKPEmission.cginc"


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
				o.uv1 = v.uv1;
				o.uv2 = v.uv2;
				1;
				return o;
			}
			
			#include "KKPEyeTess.cginc"

			#include "KKPEyePlusFrag.cginc"
			
			ENDCG
		}

		//Reflection Pass
		Pass {
			Name "Reflect"
			LOD 600
			Tags { "IGNOREPROJECTOR" = "true" "LIGHTMODE" = "FORWARDBASE" "QUEUE" = "Transparent" "RenderType" = "Transparent" "SHADOWSUPPORT" = "true" }
			Blend [_ReflBlendSrc] [_ReflBlendDst]
			ZWrite Off
			
			CGPROGRAM
			#pragma target 5.0
			#pragma vertex TessVert
			#pragma fragment reflectfrag
			#pragma hull hull
			#pragma domain domain
			
			#pragma multi_compile _ VERTEXLIGHT_ON
			#pragma multi_compile _ SHADOWS_SCREEN
			
			#define KKP_EXPENSIVE_RAMP
			#define MOVE_PUPILS

			//Unity Includes
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
			#include "Lighting.cginc"
			
			#include "KKPEyeInput.cginc"
			#include "KKPEyeDiffuse.cginc"
			#include "../KKPDisplace.cginc"
			#include "../KKPVertexLights.cginc"
			
			#include "KKPEyeReflect.cginc"

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
			
			#include "KKPEyeTess.cginc"
			
			ENDCG
		}
	}
	Fallback "Diffuse"
}
