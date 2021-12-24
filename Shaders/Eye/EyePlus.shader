Shader "xukmi/EyePlus"
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
	}
	SubShader
	{
		LOD 600
		Tags {"IgnoreProjector" = "true"
			  "Queue" = "Transparent" 
			  "RenderType" = "Transparent" }
		//Main Pass
		Pass
		{
			Name "Forward"
			LOD 600
			Tags { 	"IgnoreProjector" = "true"
					"LightMode" = "ForwardBase" 
					"Queue" = "Transparent" 
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
			#pragma multi_compile _ VERTEXLIGHT_ON

			//Unity Includes
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
			#include "Lighting.cginc"


			#include "KKPEyeInput.cginc"
			#include "../KKPVertexLights.cginc"
			#include "../KKPEmission.cginc"


			Varyings vert (VertexData v)
			{
				Varyings o;
				o.posWS = mul(unity_ObjectToWorld, v.vertex);
				o.posCS = mul(UNITY_MATRIX_VP, o.posWS);
				o.normalWS = UnityObjectToWorldNormal(v.normal);
				o.tanWS = float4(UnityObjectToWorldDir(v.tangent.xyz), v.tangent.w);
				float3 biTan = cross(o.tanWS, o.normalWS);
				o.bitanWS = normalize(biTan);
				o.uv0 = v.uv0;
				o.uv1 = v.uv1;
				o.uv2 = v.uv2;
				return o;
			}


			fixed4 frag (Varyings i) : SV_Target
			{

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
				float2 uv = i.uv0 - 0.5;
				float angle = _rotation * 6.28318548;
				float rotCos = cos(angle);
				float rotSin = sin(angle);
				float3 rotation = float3(-rotSin, rotCos, rotSin);
				float2 dotRot = float2(dot(uv, rotation.yz), dot(uv, rotation.xy));
				uv = dotRot + 0.5;
				uv = uv * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 iris = tex2D(_MainTex, uv);
				float3 viewDir = normalize(_WorldSpaceCameraPos - i.posWS);
				float2 expressionUV = float2(dot(i.tanWS, viewDir),
									   dot(i.bitanWS, viewDir));
				//Gives some depth
				expressionUV = expressionUV * -0.059999998 * _ExpressionDepth + i.uv0;
				expressionUV = expressionUV * _MainTex_ST.xy + _MainTex_ST.zw; //Makes expression follow eye
				expressionUV -= 0.5;
				expressionUV /= max(0.1, _ExpressionSize);
				expressionUV += 0.5;
				float4 expression = tex2D(_expression, expressionUV + float2(0, 0.1));
				expression.rgb =  expression.rgb - iris.rgb;
				expression.a *= _exppower;
				float3 diffuse = expression.a * expression.rgb + iris.rgb;


				float4 overTex1 = tex2D(_overtex1, i.uv1 * _overtex1_ST + _overtex1_ST.zw);
				overTex1 = overTex1.a * _overcolor1.rgba;
				float4 overTex2 = tex2D(_overtex2, i.uv2 * _overtex2_ST + _overtex2_ST.zw);
				overTex2 = overTex2.a * _overcolor2.rgba;
				float4 overTex = max(overTex1, overTex2);
				float3 blendOverTex = overTex.rgb - diffuse;
				overTex.a *= _isHighLight;
				diffuse = overTex.a * blendOverTex + diffuse;
				float alpha = max(max(overTex.a, expression.a), iris.a);

				float3 shadedDiffuse = diffuse * finalAmbientShadow;
				finalAmbientShadow = -diffuse * finalAmbientShadow + diffuse;


				KKVertexLight vertexLights[4];
				#ifdef VERTEXLIGHT_ON
					GetVertexLights(vertexLights, i.posWS);	
				#endif
					float4 vertexLighting = 0.0;
				#ifdef VERTEXLIGHT_ON
					float vertexLightRamp = 1.0;
					vertexLighting = GetVertexLighting(vertexLights, i.normalWS);
				#endif
				float lambert = max(dot(_WorldSpaceLightPos0.xyz, i.normalWS.xyz), 0.0) + vertexLighting.a;
				lambert = saturate(expression.a + overTex.a + lambert);
				finalAmbientShadow = lambert * finalAmbientShadow + shadedDiffuse;

				float3 lightCol = (_LightColor0.xyz + vertexLighting.rgb) * float3(0.600000024, 0.600000024, 0.600000024) + _CustomAmbient;
				lightCol = max(lightCol, _ambientshadowG.xyz);
				float3 finalCol = saturate(finalAmbientShadow * lightCol);

				float4 emission = GetEmission(expressionUV);
				finalCol = finalCol * (1 - emission.a) +  (emission.a * emission.rgb);
				
				return float4(finalCol, alpha);
			}

			
			ENDCG
		}

		
	}
	Fallback "Diffuse"
}
