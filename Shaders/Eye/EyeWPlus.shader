Shader "xukmi/EyeWPlus"
{
	Properties
	{
		[Gamma]_Color ("Color", Vector) = (0.5,0.5,0.5,1)
		_MainTex ("MainTex", 2D) = "white" {}
		[Gamma]_shadowcolor ("shadowcolor", Vector) = (0.6298235,0.6403289,0.747,1)
		[HideInInspector] _Cutoff ("Alpha cutoff", Range(0, 1)) = 0.5
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
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile _ SHADOWS_SCREEN
			
			//Unity Includes
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
			#include "Lighting.cginc"


			#include "KKEyeInput.cginc"


			Varyings vert (VertexData v)
			{
				Varyings o;
				o.posWS = mul(unity_ObjectToWorld, v.vertex);
				o.posCS = mul(UNITY_MATRIX_VP, o.posWS);
				o.normalWS = UnityObjectToWorldNormal(v.normal);
				o.uv0 = v.uv0;
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

				float lambert =	dot(_WorldSpaceLightPos0.xyz, i.normalWS.xyz);
				float ramp = tex2D(_RampG, lambert * _RampG_ST.xy + _RampG_ST.zw);
				finalCol = ramp * finalCol + shadedDiffuse;

				float3 lightCol = _LightColor0.xyz * float3(0.600000024, 0.600000024, 0.600000024) + float3(0.400000006, 0.400000006, 0.400000006);
				lightCol = max(lightCol, _ambientshadowG.xyz);
				finalCol *= lightCol;
				
				return float4(finalCol, alpha);
			}

			
			ENDCG
		}
		//There was a shadow pass but I don't think it really needs one since this is mainly for the eye

		
	}
	Fallback "Diffuse"
}
