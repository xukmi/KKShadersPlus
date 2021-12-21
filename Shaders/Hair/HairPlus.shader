Shader "xukmi/HairPlus"
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
		[Gamma]_CustomAmbient("Custom Ambient", Color) = (0.666666666, 0.666666666, 0.666666666, 1)
		[HideInInspector] _Cutoff ("Alpha cutoff", Range(0, 1)) = 0.5
		[MaterialToggle] _UseRampForLights ("Use Ramp For Light", Float) = 1
		[MaterialToggle] _SpecularIsHighlights ("Specular is highlight", Float) = 1
		_SpecularIsHighLightsPow ("Specular is highlight", Range(0,128)) = 64
		_SpecularIsHighlightsRange ("Specular is highlight Range", Range(0, 20)) = 5
		[MaterialToggle] _UseMeshSpecular ("Use Mesh Specular", Float) = 0
		[MaterialToggle] _UseLightColorSpecular ("Use Light Color Specular", Float) = 1
		_EmissionMask ("Emission Mask", 2D) = "black" {}
		[Gamma]_EmissionColor("Emission Color", Color) = (1, 1, 1, 1)
		_EmissionIntensity("Emission Intensity", Float) = 1
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
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			#include "KKPHairInput.cginc"
			#include "KKPHairDiffuse.cginc"


			Varyings vert (VertexData v)
			{
				Varyings o;
				
				float alphaMask = tex2Dlod(_AlphaMask, float4(v.uv0 * _AlphaMask_ST.xy + _AlphaMask_ST.zw, 0, 0)).r;
				float mainAlpha = tex2Dlod(_MainTex, float4(v.uv0 * _MainTex_ST.xy + _MainTex_ST.zw, 0, 0)).a;
				float alpha = alphaMask * mainAlpha;
				o.posWS = mul(unity_ObjectToWorld, v.vertex);

				float3 viewDir = o.posWS - _WorldSpaceCameraPos.xyz; //This is inverted?
				float viewVal = dot(viewDir, viewDir);
				viewVal = sqrt(viewVal);
				viewVal = viewVal * 0.0999999866 + 0.300000012;
				float lineVal = _linewidthG * 0.00499999989;
				viewVal *= lineVal;
				alpha *= viewVal;

				float4 detailMask = tex2Dlod(_DetailMask, float4(v.uv0 * _DetailMask_ST.xy + _DetailMask_ST.zw, 0, 0));
				float inverseMask = 1 - detailMask.z;
				alpha *= inverseMask;

				//Not too sure what's going on, some viewspace based outlines?
				float4 u_xlat0;
				u_xlat0.xyz = v.normal.xyz * alpha + v.vertex.xyz;
				o.posCS = UnityObjectToClipPos(u_xlat0.xyz);
				o.uv0 = v.uv0;

				return o;
			}
			

			

			fixed4 frag (Varyings i) : SV_Target
			{
				
				float4 mainTex = tex2D(_MainTex, i.uv0 * _MainTex_ST.xy + _MainTex_ST.zw);
				float alpha = AlphaClip(i.uv0, mainTex.a);

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
				float3 lightCol = _LightColor0.xyz * float3(0.600000024, 0.600000024, 0.600000024) + float3(0.400000006, 0.400000006, 0.400000006);
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
			Cull Off


			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma shader_feature _EXPENSIVE_RAMP_LIGHT
			#pragma multi_compile _ VERTEXLIGHT_ON
			#pragma multi_compile _ SHADOWS_SCREEN
			
			//Unity Includes
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
			#include "Lighting.cginc"

			#include "KKPHairInput.cginc"
			#include "KKPHairDiffuse.cginc"
			#include "../KKPVertexLights.cginc"
			#include "../KKPEmission.cginc"
			
			#include "KKPHairVertFrag.cginc" //Vert Frag here
			

			
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
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_shadowcaster

			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _AlphaMask;
			float4 _AlphaMask_ST;

            struct v2f { 
				float2 uv0 : TEXCOORD1;
                V2F_SHADOW_CASTER;
            };

            v2f vert(appdata_base v)
            {
                v2f o;
				o.uv0 = v.texcoord;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {

				float4 mainTex = tex2D(_MainTex, i.uv0 * _MainTex_ST.xy + _MainTex_ST.zw);
				float2 alphaUV = i.uv0 * _AlphaMask_ST.xy + _AlphaMask_ST.zw;
				float4 alphaMask = tex2D(_AlphaMask, alphaUV);
				float alphaVal = alphaMask.x * mainTex.a;
				float clipVal = (alphaVal.x - 0.5) < 0.0f;
				if(clipVal * int(0xffffffffu) != 0)
					discard;

                SHADOW_CASTER_FRAGMENT(i)
            }

			
			ENDCG
		}
		
	}
	Fallback "Unlit/Texture"
}
