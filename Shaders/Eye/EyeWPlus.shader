Shader "xukmi/EyeWPlus"
{
	Properties
	{
		[Gamma]_Color ("Color", Vector) = (0.5,0.5,0.5,1)
		_MainTex ("MainTex", 2D) = "white" {}
		[Gamma]_shadowcolor ("shadowcolor", Vector) = (0.6298235,0.6403289,0.747,1)
		[HideInInspector] _Cutoff ("Alpha cutoff", Range(0, 1)) = 0.5
		[Gamma]_CustomAmbient("Custom Ambient", Color) = (0.666666666, 0.666666666, 0.666666666, 1)
		[MaterialToggle] _UseRampForLights ("Use Ramp For Light", Float) = 1
		_DisablePointLights ("Disable Point Lights", Float) = 0.0
	}
	SubShader
	{
		LOD 600
		Tags {"IgnoreProjector" = "true"
			  "Queue" = "Transparent-1" 
			  "RenderType" = "Transparent" }
		//Main Pass
		Pass
		{
			Name "Forward"
			LOD 600
			Tags { 	"IgnoreProjector" = "true"
					"LightMode" = "ForwardBase" 
					"Queue" = "Transparent-1" 
			  		"RenderType" = "Transparent"
					"ShadowSupport" = "true" }

			ZWrite Off
			Stencil {
				Ref 2
				Comp Always
				Pass Replace
				Fail Keep
				ZFail Keep
			}


			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile _ VERTEXLIGHT_ON
			
			#define KKP_EXPENSIVE_RAMP
			
			//Unity Includes
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
			#include "Lighting.cginc"


			#include "KKPEyeInput.cginc"
			#include "..//KKPVertexLights.cginc"

			Varyings vert (VertexData v)
			{
				Varyings o;
				o.posWS = mul(unity_ObjectToWorld, v.vertex);
				o.posCS = mul(UNITY_MATRIX_VP, o.posWS);
				o.normalWS = UnityObjectToWorldNormal(v.normal);
				o.uv0 = v.uv0;
				1;
				return o;
			}


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

				float3 lightCol = (_LightColor0.xyz + vertexLighting.rgb * vertexLightRamp) * float3(0.600000024, 0.600000024, 0.600000024) + _CustomAmbient;
				lightCol = max(lightCol, _ambientshadowG.xyz);
				finalCol *= lightCol;
				
				return float4(finalCol, 1);
			}

			
			ENDCG
		}
		//ShadowCaster
		Pass
		{
			Name "ShadowCaster"
			LOD 600
			Tags { "IgnoerProjector" = "true" "LightMode" = "ShadowCaster" "Queue" = "Transparent-1" "RenderType" = "Transparent" "ShadowSupport" = "true" }
			Offset 1, 1
			Cull Back

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_shadowcaster

			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;

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
