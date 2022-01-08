Shader "xukmi/MainItemAlphaPlus"
{
	Properties
	{
		_AnotherRamp ("Another Ramp(LineR)", 2D) = "white" {}
		_MainTex ("MainTex", 2D) = "white" {}
		_NormalMap ("Normal Map", 2D) = "bump" {}
		_DetailMask ("Detail Mask", 2D) = "black" {}
		_LineMask ("Line Mask", 2D) = "black" {}
		_EmissionMask ("Emission Mask", 2D) = "black" {}
		[Gamma]_EmissionColor("Emission Color", Color) = (1, 1, 1, 1)
		_EmissionIntensity("Emission Intensity", Float) = 1
		[Gamma]_ShadowColor ("Shadow Color", Vector) = (0.628,0.628,0.628,1)
		[Gamma]_SpecularColor ("Specular Color", Color) = (1,1,1,0)
		_SpecularPower ("Specular Power", Range(0, 1)) = 0
		_SpeclarHeight ("Speclar Height", Range(0, 1)) = 0.98
		_rimpower ("Rim Width", Range(0, 1)) = 0.5
		_rimV ("Rim Strength", Range(0, 1)) = 0.5
		_ShadowExtend ("Shadow Extend", Range(0, 1)) = 1
		_ShadowExtendAnother ("Shadow Extend Another", Range(0, 1)) = 1
		[MaterialToggle] _AnotherRampFull ("Another Ramp Full", Float) = 0
		[MaterialToggle] _DetailBLineG ("DetailB LineG", Float) = 0
		[MaterialToggle] _DetailRLineR ("DetailR LineR", Float) = 0
		[MaterialToggle] _notusetexspecular ("not use tex specular", Float) = 0
		_LineWidthS ("LineWidthS", Float) = 1
		_Clock ("Clock(xy/piv)(z/ang)(w/spd)", Vector) = (0,0,0,0)
		_ColorMask ("Color Mask", 2D) = "black" {}
		[Gamma]_Color ("Color", Color) = (1,0,0,1)
		[Gamma]_Color2 ("Color2", Color) = (0.1172419,0,1,1)
		[Gamma]_Color3 ("Color3", Color) = (0.5,0.5,0.5,1)
		[Gamma]_CustomAmbient("Custom Ambient", Color) = (0.666666666, 0.666666666, 0.666666666, 1)
		[MaterialToggle] _UseRampForLights ("Use Ramp For Light", Float) = 1
		[MaterialToggle] _UseRampForSpecular ("Use Ramp For Specular", Float) = 1
		[MaterialToggle] _UseLightColorSpecular ("Use Light Color Specular", Float) = 1
		[HideInInspector] _Cutoff ("Alpha cutoff", Range(0, 1)) = 0.5
		[Enum(Off,0,On,1)]_OutlineOn ("Outline On", Float) = 0.0
		[Enum(Off,0,On,1)]_AlphaOptionZWrite ("ZWrite", Float) = 1.0
		[Enum(Off,0,On,1)]_AlphaOptionCutoff ("Cutoff On", Float) = 1.0
		[Enum(Off,0,Front,1,Back,2)] _CullOption ("Cull Option", Range(0, 2)) = 2
		_Alpha ("AlphaValue", Float) = 1
		[MaterialToggle] _UseDetailRAsSpecularMap ("Use DetailR as Specular Map", Float) = 0
		_Reflective("Reflective", Range(0, 1)) = 0.75
		_ReflectiveBlend("Reflective Blend", Range(0, 1)) = 0.05
		_ReflectiveMulOrAdd("Mul Or Add", Range(0, 1)) = 1
		_UseKKMetal("Use KK Metal", Range(0, 1)) = 1
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
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			#include "KKPItemInput.cginc"
			#include "KKPItemDiffuse.cginc"

			Varyings vert (VertexData v)
			{
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
				o.uv0 = v.uv0;
				return o;
			}
			

			

			fixed4 frag (Varyings i) : SV_Target
			{
				//Clips based on alpha texture
				float4 mainTex = tex2D(_MainTex, i.uv0 * _MainTex_ST.xy + _MainTex_ST.zw);
				AlphaClip(i.uv0,  _OutlineOn ? mainTex.a * _Alpha : 0);

				float3 worldLightPos = normalize(_WorldSpaceLightPos0.xyz);
				float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.posWS);
				float3 halfDir = normalize(viewDir + worldLightPos);

				float4 colorMask = tex2D(_ColorMask, i.uv0 * + _ColorMask_ST.xy + _ColorMask_ST.zw);
				float3 color;
				color = colorMask.r * (_Color.rgb - 1) + 1;
				color = colorMask.g * (_Color2.rgb - color) + color;
				color = colorMask.b * (_Color3.rgb - color) + color;
				float3 diffuse = mainTex * color;


				//Apparently can rotate?
				float time = _TimeEditor.y + _Time.y;
				time *= _Clock.z * _Clock.w;
				float sinTime = sin(time);
				float cosTime = cos(time);
				float3 rotVal = float3(-sinTime, cosTime, sinTime);
				float2 detailUVAdjust = i.uv0 - _Clock.xy;
				float2 rotatedDetailUV;
				rotatedDetailUV.x = dot(detailUVAdjust, rotVal.yz); 
				rotatedDetailUV.y = dot(detailUVAdjust, rotVal.xy);
				rotatedDetailUV += _Clock.xy;
				rotatedDetailUV = rotatedDetailUV * _LineMask_ST.xy + _LineMask_ST.zw;
				float4 lineMaskRot = tex2D(_LineMask, rotatedDetailUV);

				diffuse = lineMaskRot.b * -diffuse + diffuse;
				float3 shadingAdjustment = ShadeAdjustItem(diffuse);

				float2 detailUV = i.uv0 * _DetailMask_ST.xy + _DetailMask_ST.zw;
				float4 detailMask = tex2D(_DetailMask, detailUV);
				float2 lineMaskUV = i.uv0 * _LineMask_ST.xy + _LineMask_ST.zw;
				float4 lineMask = tex2D(_LineMask, lineMaskUV);
				lineMask.r = _DetailRLineR * (detailMask.r - lineMask.r) + lineMask.r;

				float3 diffuseShaded = shadingAdjustment * 0.899999976 - 0.5;
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

				bool3 compTest = 0.555555582 < shadingAdjustment;
				shadingAdjustment *= finalAmbientShadow;
				shadingAdjustment *= 1.79999995;
				diffuseShaded = -diffuseShaded * invertFinalAmbientShadow + 1;
				{
					float3 hlslcc_movcTemp = shadingAdjustment;
					hlslcc_movcTemp.x = (compTest.x) ? diffuseShaded.x : shadingAdjustment.x;
					hlslcc_movcTemp.y = (compTest.y) ? diffuseShaded.y : shadingAdjustment.y;
					hlslcc_movcTemp.z = (compTest.z) ? diffuseShaded.z : shadingAdjustment.z;
					shadingAdjustment = saturate(hlslcc_movcTemp);
				}
				float shadowExtendAnother = 1 - _ShadowExtendAnother;
				float kkMetal = _AnotherRampFull * (1 - lineMask.r) + lineMask.r;

				shadowExtendAnother -= kkMetal;
				shadowExtendAnother += 1;
				shadowExtendAnother = saturate(shadowExtendAnother) * 0.670000017 + 0.330000013;
				float3 shadowExtendShaded = shadowExtendAnother * shadingAdjustment;

				diffuse = diffuse * _LineColorG;				
				float3 lineCol = -diffuse * shadowExtendShaded + 1;
				diffuse *= shadowExtendShaded;

				float lineAlpha = _LineColorG.w - 0.5;
				lineAlpha = -lineAlpha * 2.0 + 1.0;
				lineCol = -lineAlpha * lineCol + 1;
				lineAlpha = _LineColorG.w *2;
				diffuse *= lineAlpha;
				diffuse = 0.5 < _LineColorG.w ? lineCol : diffuse;

				float3 finalDiffuse =  diffuse;



				return float4(finalDiffuse, mainTex.a * _Alpha);


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
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile _ VERTEXLIGHT_ON
			#pragma multi_compile _ SHADOWS_SCREEN
			
			//Unity Includes
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
			#include "Lighting.cginc"

			#define KKP_EXPENSIVE_RAMP

			#include "KKPItemInput.cginc"
			#include "KKPItemDiffuse.cginc"
			#include "KKPItemNormals.cginc"
			#include "KKPItemCoom.cginc"
			#include "../KKPVertexLights.cginc"
			#include "../KKPVertexLightsSpecular.cginc"
			#include "../KKPEmission.cginc"
			#include "../KKPReflect.cginc"

			float3 AmbientShadowAdjust(){
				float4 u_xlat5;
				float4 u_xlat6;
				float u_xlat30;
				bool u_xlatb30;
				float u_xlat31;

				u_xlatb30 = _ambientshadowG.y>=_ambientshadowG.z;
				u_xlat30 = u_xlatb30 ? 1.0 : float(0.0);
				u_xlat5.xy = _ambientshadowG.yz;
				u_xlat5.z = float(0.0);
				u_xlat5.w = float(-0.333333343);
				u_xlat6.xy = _ambientshadowG.zy;
				u_xlat6.z = float(-1.0);
				u_xlat6.w = float(0.666666687);
				u_xlat5 = u_xlat5 + (-u_xlat6);
				u_xlat5 = (u_xlat30) * u_xlat5.xywz + u_xlat6.xywz;
				u_xlatb30 = _ambientshadowG.x>=u_xlat5.x;
				u_xlat30 = u_xlatb30 ? 1.0 : float(0.0);
				u_xlat6.z = u_xlat5.w;
				u_xlat5.w = _ambientshadowG.x;
				u_xlat6.xyw = u_xlat5.wyx;
				u_xlat6 = (-u_xlat5) + u_xlat6;
				u_xlat5 = (u_xlat30) * u_xlat6 + u_xlat5;
				u_xlat30 = min(u_xlat5.y, u_xlat5.w);
				u_xlat30 = (-u_xlat30) + u_xlat5.x;
				u_xlat30 = u_xlat30 * 6.0 + 1.00000001e-10;
				u_xlat31 = (-u_xlat5.y) + u_xlat5.w;
				u_xlat30 = u_xlat31 / u_xlat30;
				u_xlat30 = u_xlat30 + u_xlat5.z;
				u_xlat5.xyz = abs((u_xlat30)) + float3(0.0, -0.333333343, 0.333333343);
				u_xlat5.xyz = frac(u_xlat5.xyz);
				u_xlat5.xyz = (-u_xlat5.xyz) * float3(2.0, 2.0, 2.0) + float3(1.0, 1.0, 1.0);
				u_xlat5.xyz = abs(u_xlat5.xyz) * float3(3.0, 3.0, 3.0) + float3(-1.0, -1.0, -1.0);
				u_xlat5.xyz = clamp(u_xlat5.xyz, 0.0, 1.0);
				u_xlat5.xyz = u_xlat5.xyz * float3(0.400000006, 0.400000006, 0.400000006) + float3(0.300000012, 0.300000012, 0.300000012);
				return u_xlat5.xyz;
			}

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

			fixed4 frag (Varyings i, int faceDir : VFACE) : SV_Target
			{
				//Clips based on alpha texture
				float4 mainTex = tex2D(_MainTex, i.uv0 * _MainTex_ST.xy + _MainTex_ST.zw);
				AlphaClip(i.uv0, mainTex.a);

				float3 worldLightPos = normalize(_WorldSpaceLightPos0.xyz);
				float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.posWS);
				float3 halfDir = normalize(viewDir + worldLightPos);

				float4 colorMask = tex2D(_ColorMask, i.uv0 * + _ColorMask_ST.xy + _ColorMask_ST.zw);
				float3 color;
				color = colorMask.r * (_Color.rgb - 1) + 1;
				color = colorMask.g * (_Color2.rgb - color) + color;
				color = colorMask.b * (_Color3.rgb - color) + color;
				float3 diffuse = mainTex * color;
				
				float3 normal = NormalAdjust(i, GetNormal(i), 1);

				//Apparently can rotate?
				float time = _TimeEditor.y + _Time.y;
				time *= _Clock.z * _Clock.w;
				float sinTime = sin(time);
				float cosTime = cos(time);
				float3 rotVal = float3(-sinTime, cosTime, sinTime);
				float2 detailUVAdjust = i.uv0 - _Clock.xy;
				float2 rotatedDetailUV;
				rotatedDetailUV.x = dot(detailUVAdjust, rotVal.yz); 
				rotatedDetailUV.y = dot(detailUVAdjust, rotVal.xy);
				rotatedDetailUV += _Clock.xy;
				rotatedDetailUV = rotatedDetailUV * _LineMask_ST.xy + _LineMask_ST.zw;
				float4 lineMaskRot = tex2D(_LineMask, rotatedDetailUV);

				diffuse = lineMaskRot.b * -diffuse + diffuse;
				float3 shadingAdjustment = ShadeAdjustItem(diffuse);

				float2 detailUV = i.uv0 * _DetailMask_ST.xy + _DetailMask_ST.zw;
				float4 detailMask = tex2D(_DetailMask, detailUV);
				float2 lineMaskUV = i.uv0 * _LineMask_ST.xy + _LineMask_ST.zw;
				float4 lineMask = tex2D(_LineMask, lineMaskUV);
				lineMask.r = _DetailRLineR * (detailMask.r - lineMask.r) + lineMask.r;

				float3 diffuseShaded = shadingAdjustment * 0.899999976 - 0.5;
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

				bool3 compTest = 0.555555582 < shadingAdjustment;
				shadingAdjustment *= finalAmbientShadow;
				shadingAdjustment *= 1.79999995;
				diffuseShaded = -diffuseShaded * invertFinalAmbientShadow + 1;
				{
					float3 hlslcc_movcTemp = shadingAdjustment;
					hlslcc_movcTemp.x = (compTest.x) ? diffuseShaded.x : shadingAdjustment.x;
					hlslcc_movcTemp.y = (compTest.y) ? diffuseShaded.y : shadingAdjustment.y;
					hlslcc_movcTemp.z = (compTest.z) ? diffuseShaded.z : shadingAdjustment.z;
					shadingAdjustment = saturate(hlslcc_movcTemp);
				}
				float shadowExtendAnother = 1 - _ShadowExtendAnother;
				float kkMetal = _AnotherRampFull * (1 - lineMask.r) + lineMask.r;

				float kkMetalMap = kkMetal;
				kkMetal *= _UseKKMetal;

				shadowExtendAnother -= kkMetal;
				shadowExtendAnother += 1;
				shadowExtendAnother = saturate(shadowExtendAnother) * 0.670000017 + 0.330000013;

				float3 shadowExtendShaded = shadowExtendAnother * shadingAdjustment;
				shadingAdjustment = -shadingAdjustment * shadowExtendAnother + 1;
				float3 diffuseShadow = diffuse * shadowExtendShaded;
				float3 diffuseShadowBlended = -shadowExtendShaded * diffuse + diffuse;
		
				KKVertexLight vertexLights[4];
			#ifdef VERTEXLIGHT_ON
				GetVertexLights(vertexLights, i.posWS);	
			#endif
				float4 vertexLighting = 0.0;
				float vertexLightRamp = 1.0;
			#ifdef VERTEXLIGHT_ON
				vertexLighting = GetVertexLighting(vertexLights, normal);
				float2 vertexLightRampUV = vertexLighting.a * _RampG_ST.xy + _RampG_ST.zw;
				vertexLightRamp = tex2D(_RampG, vertexLightRampUV).x;
				float3 rampLighting = GetRampLighting(vertexLights, normal, vertexLightRamp);
				vertexLighting.rgb = _UseRampForLights ? rampLighting : vertexLighting.rgb;
			#endif
				float lambert = dot(_WorldSpaceLightPos0.xyz, normal);
				lambert = max(lambert, vertexLighting.a);
				float2 rampUV = lambert * _RampG_ST.xy + _RampG_ST.zw;
				float ramp = tex2D(_RampG, rampUV);

				float fresnel = max(dot(normal, viewDir), 0.0);
				fresnel = log2(1 - fresnel);


				float specular = dot(normal, halfDir);
				specular = max(specular, 0.0);
				float anotherRampSpecularVertex = 0.0;
			#ifdef VERTEXLIGHT_ON
				[unroll]
				for(int j = 0; j < 4; j++){
					KKVertexLight light = vertexLights[j];
					float3 halfVector = normalize(viewDir + light.dir) * saturate(MaxGrayscale(light.col));
					anotherRampSpecularVertex = max(anotherRampSpecularVertex, dot(halfVector, normal));
				}
			#endif
				float2 anotherRampUV = max(specular, anotherRampSpecularVertex) * _AnotherRamp_ST.xy + _AnotherRamp_ST.zw;
				float anotherRamp = tex2D(_AnotherRamp, anotherRampUV);
				specular = log2(specular);
				anotherRamp -= ramp;
				float finalRamp = kkMetal * anotherRamp + ramp;

				#ifdef SHADOWS_SCREEN
					float2 shadowMapUV = i.shadowCoordinate.xy / i.shadowCoordinate.ww;
					float4 shadowMap = tex2D(_ShadowMapTexture, shadowMapUV);
					float shadowAttenuation = saturate(shadowMap.x * 2.0 - 1.0);
					finalRamp *= shadowAttenuation;
				#endif
				
				diffuseShadow = finalRamp *  diffuseShadowBlended + diffuseShadow;
				
				float specularHeight = _SpeclarHeight  - 1.0;
				specularHeight *= 0.800000012;
				float2 detailSpecularOffset;
				detailSpecularOffset.x = dot(i.tanWS, viewDir);
				detailSpecularOffset.y = dot(i.bitanWS, viewDir);
				float2 detailMaskUV2 = specularHeight * detailSpecularOffset + i.uv0;
				detailMaskUV2 = detailMaskUV2 * _DetailMask_ST.xy + _DetailMask_ST.zw;
				float drawnSpecular = tex2D(_DetailMask, detailMaskUV2).x;
				float drawnSpecularSquared = min(drawnSpecular * drawnSpecular, 1.0);

				float specularPower = _SpecularPower * 256.0;
				specular *= specularPower;
				specular = exp2(specular) * 5.0 - 4.0;
			#ifdef KKP_EXPENSIVE_RAMP
				float2 lightRampUV = specular * _RampG_ST.xy + _RampG_ST.zw;
				specular = tex2D(_RampG, lightRampUV) * _UseRampForSpecular + specular * (1 - _UseRampForSpecular);
			#endif
				specular = saturate(specular * _SpecularPower);
				specular = specular - drawnSpecular;
				specular = _notusetexspecular * specular + drawnSpecular;
				float specularVertex = 0.0;
				float3 specularVertexCol = 0.0;
			#ifdef VERTEXLIGHT_ON
				specularVertex = GetVertexSpecularDiffuse(vertexLights, normal, viewDir, _SpecularPower, specularVertexCol);
			#endif
				float3 specularCol = saturate(specular) * _SpecularColor.rgb + saturate(specularVertex) * specularVertexCol * _notusetexspecular;
				specularCol *= _SpecularColor.a;

				float3 ambientShadowAdjust2 = AmbientShadowAdjust();

				detailMask.rg = 1 - detailMask.bg;

				float rimPow = _rimpower * 9.0 + 1.0;
				rimPow = rimPow * fresnel;
				float rim = saturate(exp2(rimPow) * 2.5 - 0.5) * _rimV;
				float rimMask = detailMask.x * 9.99999809 + -8.99999809;
				rim *= rimMask;

				ambientShadowAdjust2 *= rim;
				ambientShadowAdjust2 *= detailMask.g;
				ambientShadowAdjust2 = min(max(ambientShadowAdjust2, 0.0), 0.5);
				diffuseShadow += ambientShadowAdjust2;

				float3 lightCol = (_LightColor0.xyz + vertexLighting.rgb * vertexLightRamp) * float3(0.600000024, 0.600000024, 0.600000024) + _CustomAmbient.rgb;
				float3 ambientCol = max(lightCol, _ambientshadowG.xyz);
				diffuseShadow = diffuseShadow * ambientCol;
				float shadowExtend = _ShadowExtend * -1.20000005 + 1.0;
				float drawnShadow = detailMask.y * (1 - shadowExtend) + shadowExtend;
				
				float detailLineShadow = 1 - detailMask.x;
				detailLineShadow -= lineMask.y;
				detailLineShadow = _DetailBLineG * detailLineShadow + lineMask.y;

				shadingAdjustment = drawnShadow * shadingAdjustment + shadowExtendShaded;
				shadingAdjustment *= diffuseShadow;

				diffuse = diffuse * _LineColorG;
				float3 lineCol = -diffuse * shadowExtendShaded + 1;
				diffuse *= shadowExtendShaded;

				float lineAlpha = _LineColorG.w - 0.5;
				lineAlpha = -lineAlpha * 2.0 + 1.0;
				lineCol = -lineAlpha * lineCol + 1;
				lineAlpha = _LineColorG.w *2;
				diffuse *= lineAlpha;
				diffuse = 0.5 < _LineColorG.w ? lineCol : diffuse;
				diffuse = saturate(diffuse);
				diffuse = -shadingAdjustment + diffuse;

				float3 finalDiffuse = detailLineShadow * diffuse + shadingAdjustment;
				finalDiffuse += specularCol;
			
				finalDiffuse = GetBlendReflections(finalDiffuse, normal, viewDir, kkMetalMap);

				float4 emission = GetEmission(i.uv0);
				finalDiffuse = finalDiffuse * (1 - emission.a) + (emission.a*emission.rgb);

				return float4(finalDiffuse, mainTex.a * _Alpha);


			}

			
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
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_shadowcaster

			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _AlphaMask;
			float4 _AlphaMask_ST;

			float _alpha_a;
			float _alpha_b;


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
				float2 alphaUV = i.uv0 * _AlphaMask_ST.xy + _AlphaMask_ST.zw;
				float4 alphaMask = tex2D(_AlphaMask, alphaUV);
				float2 alphaVal = -float2(_alpha_a, _alpha_b) + float2(1.0f, 1.0f);
				float mainTexAlpha = tex2D(_MainTex, i.uv0 * _MainTex_ST.xy + _MainTex_ST.zw).a;
				alphaVal = max(alphaVal, alphaMask.xy);
				alphaVal = min(alphaVal.y, alphaVal.x);
				alphaVal *= mainTexAlpha;
				alphaVal.x -= 0.5f;
				float clipVal = alphaVal.x < 0.0f;
				if(clipVal * int(0xffffffffu) != 0)
					discard;

                SHADOW_CASTER_FRAGMENT(i)
            }

			
			ENDCG
		}
		

		
	}
	Fallback "Unlit/Texture"
}
