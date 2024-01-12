Shader "xukmi/EyeWPlusTess"
{
	Properties
	{
		[Gamma]_Color ("Color", Vector) = (0.5,0.5,0.5,1)
		_MainTex ("MainTex", 2D) = "white" {}
		[Gamma]_shadowcolor ("shadowcolor", Vector) = (0.6298235,0.6403289,0.747,1)
		[HideInInspector] _Cutoff ("Alpha cutoff", Range(0, 1)) = 0.5
		_EmissionMask ("Emission Mask", 2D) = "black" {}
		[Gamma]_EmissionColor("Emission Color", Color) = (1, 1, 1, 1)
		_EmissionIntensity("Emission Intensity", Float) = 1
		[Gamma]_CustomAmbient("Custom Ambient", Color) = (0.666666666, 0.666666666, 0.666666666, 1)
		[MaterialToggle] _UseRampForLights ("Use Ramp For Light", Float) = 1
		
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
		
		_DisablePointLights ("Disable Point Lights", Range(0,1)) = 0.0
		_ShadowHSV ("Shadow HSV", Vector) = (0, 0, 0, 0)
		
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
		Tags { "IGNOREPROJECTOR" = "true" "QUEUE" = "Transparent-1" "RenderType" = "Transparent" }
		
		//Main Pass
		Pass {
			Name "Forward"
			LOD 600
			Tags { "IGNOREPROJECTOR" = "true" "LIGHTMODE" = "FORWARDBASE" "QUEUE" = "Transparent-1" "RenderType" = "Transparent" "SHADOWSUPPORT" = "true" }
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
			
			#define KKP_EXPENSIVE_RAMP
			
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
				o.uv0 = v.uv0;
				11111;
				return o;
			}
			
			#include "KKPEyeTess.cginc"

			fixed4 frag (Varyings i) : SV_Target
			{

				float4 mainTex = tex2D(_MainTex, i.uv0 * _MainTex_ST.xy + _MainTex_ST.zw);
				float alpha = mainTex.a - 0.5;

				//Because of the stencil the shader needs to alpha cilp otherwise the whole mesh shows over the hair
				float clipVal = alpha < 0.0f;
				if(clipVal * int(0xffffffffu) != 0)
					discard;
				alpha = mainTex.a;

				float4 ambientShadow = 1 - _ambientshadowG.wxyz;
				float3 ambientShadowIntensity = -ambientShadow.x * ambientShadow.yzw + 1;
				float ambientShadowAdjust = _ambientshadowG.w * 0.5 + 0.5;
				float ambientShadowAdjustDoubled = ambientShadowAdjust + ambientShadowAdjust;
				bool ambientShadowAdjustShow = 0.5 < ambientShadowAdjust;
				ambientShadow.rgb = ambientShadowAdjustDoubled * _ambientshadowG.rgb;
				float3 finalAmbientShadow = ambientShadowAdjustShow ? ambientShadowIntensity : ambientShadow.rgb;
				finalAmbientShadow = saturate(finalAmbientShadow);
				float3 invertFinalAmbientShadow = 1 - finalAmbientShadow;

				finalAmbientShadow *= _shadowcolor.xyz;
				finalAmbientShadow = finalAmbientShadow + finalAmbientShadow;

				//This gives a /slightly/ different color than just a one minus for whatever reason
				//The KK shader does this so it's staying in
				float3 shadowColor = _shadowcolor.xyz - 0.5;
				shadowColor = -shadowColor * 2 + 1;
				invertFinalAmbientShadow = -shadowColor * invertFinalAmbientShadow + 1;
				bool3 shadowCheck = 0.5 < _shadowcolor;
				{
					float3 hlslcc_movcTemp = finalAmbientShadow;
					hlslcc_movcTemp.x = (shadowCheck.x) ? invertFinalAmbientShadow.x : finalAmbientShadow.x;
					hlslcc_movcTemp.y = (shadowCheck.y) ? invertFinalAmbientShadow.y : finalAmbientShadow.y;
					hlslcc_movcTemp.z = (shadowCheck.z) ? invertFinalAmbientShadow.z : finalAmbientShadow.z;
					finalAmbientShadow = hlslcc_movcTemp;
				}
				finalAmbientShadow = saturate(finalAmbientShadow);

				float3 diffuse = mainTex.rgb * _Color.rgb;
				float3 shadedDiffuse = diffuse * finalAmbientShadow;
				float3 finalCol = mainTex.rgb * _Color.rgb - shadedDiffuse;

				KKVertexLight vertexLights[4];
			#ifdef VERTEXLIGHT_ON
				GetVertexLightsTwo(vertexLights, i.posWS, _DisablePointLights);	
			#endif
				float4 vertexLighting = 0.0;
				float vertexLightRamp = 1.0;
			#ifdef VERTEXLIGHT_ON
				vertexLighting = GetVertexLighting(vertexLights, i.normalWS);
				float2 vertexLightRampUV = vertexLighting.a * _RampG_ST.xy + _RampG_ST.zw;
				vertexLightRamp = tex2D(_RampG, vertexLightRampUV).x;
				float3 rampLighting = GetRampLighting(vertexLights, i.normalWS, vertexLightRamp);
				vertexLighting.rgb = _UseRampForLights ? rampLighting : vertexLighting.rgb;
			#endif

				float lambert =	dot(_WorldSpaceLightPos0.xyz, i.normalWS.xyz) + vertexLighting.a;;
				float ramp = tex2D(_RampG, lambert * _RampG_ST.xy + _RampG_ST.zw);
				finalCol = ramp * finalCol + shadedDiffuse;
				
				float shadowAttenuation = saturate(ramp);
				#ifdef SHADOWS_SCREEN
					float2 shadowMapUV = i.shadowCoordinate.xy / i.shadowCoordinate.ww;
					float4 shadowMap = tex2D(_ShadowMapTexture, shadowMapUV);
					shadowAttenuation *= shadowMap;
				#endif

				float3 lightCol = (_LightColor0.xyz + vertexLighting.rgb * vertexLightRamp) * float3(0.600000024, 0.600000024, 0.600000024) + _CustomAmbient;
				lightCol = max(lightCol, _ambientshadowG.xyz);
				finalCol *= lightCol;
				
				float3 hsl = RGBtoHSL(finalCol);
				hsl.x = hsl.x + _ShadowHSV.x;
				hsl.y = hsl.y + _ShadowHSV.y;
				hsl.z = hsl.z + _ShadowHSV.z;
				finalCol = lerp(HSLtoRGB(hsl), finalCol, saturate(shadowAttenuation + 0.5));

				// Overlay emission over everything
				float4 emission = GetEmission(i.uv0);
				finalCol = finalCol * (1 - emission.a) + (emission.a * emission.rgb);
				
				return float4(finalCol, 1);
			}
			ENDCG
		}
		
		//Reflection Pass
		Pass {
			Name "Reflect"
			LOD 600
			Tags { "IGNOREPROJECTOR" = "true" "LIGHTMODE" = "FORWARDBASE" "QUEUE" = "Transparent-1" "RenderType" = "Transparent" "SHADOWSUPPORT" = "true" }
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
		
		//ShadowCaster
		Pass {
			Name "ShadowCaster"
			LOD 600
			Tags { "IGNOREPROJECTOR" = "true" "IgnoerProjector" = "true" "LIGHTMODE" = "SHADOWCASTER" "QUEUE" = "Transparent-1" "RenderType" = "Transparent" "SHADOWSUPPORT" = "true" }
			Offset 1, 1
			Cull Back

			CGPROGRAM
			#pragma target 5.0
			
			#pragma vertex TessVert
			#pragma fragment frag
			#pragma hull hull
			#pragma domain domain
			#pragma multi_compile_shadowcaster
			
			#define SHADOW_CASTER_PASS

			#include "UnityCG.cginc"
			#include "KKPEyeInput.cginc"
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
			
			#include "KKPEyeTess.cginc"

            float4 frag(v2f i) : SV_Target
            {

				float4 mainTex = tex2D(_MainTex, i.uv0 * _MainTex_ST.xy + _MainTex_ST.zw);
				float alphaVal = mainTex.a;
				float clipVal = (alphaVal.x - 0.5) < 0.0f;
				if(clipVal * int(0xffffffffu) != 0)
					discard;

                SHADOW_CASTER_FRAGMENT(i)
            }
			ENDCG
		}
	}
	Fallback "Diffuse"
}
