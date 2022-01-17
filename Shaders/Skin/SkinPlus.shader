Shader "xukmi/SkinPlus"
{
	Properties
	{
		_MainTex ("MainTex", 2D) = "white" {}
		[Gamma]_overcolor1 ("Over Color1", Vector) = (1,1,1,1)
		_overtex1 ("Over Tex1", 2D) = "black" {}
		[Gamma]_overcolor2 ("Over Color2", Vector) = (1,1,1,1)
		_overtex2 ("Over Tex2", 2D) = "black" {}
		[Gamma]_overcolor3 ("Over Color3", Vector) = (1,1,1,1)
		_overtex3 ("Over Tex3", 2D) = "black" {}
		_NormalMap ("Normal Map", 2D) = "bump" {}
		_NormalMapDetail ("Normal Map Detail", 2D) = "bump" {}
		_DetailMask ("Detail Mask", 2D) = "black" {}
		_LineMask ("Line Mask", 2D) = "black" {}
		_AlphaMask ("Alpha Mask", 2D) = "white" {}
		_EmissionMask ("Emission Mask", 2D) = "black" {}
		[Gamma]_EmissionColor("Emission Color", Color) = (1, 1, 1, 1)
		_EmissionIntensity("Emission Intensity", Float) = 1
		[Gamma]_ShadowColor ("Shadow Color", Vector) = (0.628,0.628,0.628,1)
		[Gamma]_SpecularColor ("Specular Color", Vector) = (1,1,1,0)
		_DetailNormalMapScale ("DetailNormalMapScale", Range(0, 1)) = 1
		_NormalMapScale ("NormalMapScale", Float) = 1
		_SpeclarHeight ("Speclar Height", Range(0, 1)) = 0.98
		_SpecularPower ("Specular Power", Range(0, 1)) = 0
		_SpecularPowerNail ("Specular Power Nail", Range(0, 1)) = 0
		_ShadowExtend ("Shadow Extend", Range(0, 1)) = 1
		_rimpower ("Rim Width", Range(0, 1)) = 0.5
		_rimV ("Rim Strength", Range(0, 1)) = 0
		_nipsize ("nipsize", Range(0, 1)) = 0.5
		[MaterialToggle] _alpha_a ("alpha_a", Float) = 1
		[MaterialToggle] _alpha_b ("alpha_b", Float) = 1
		[MaterialToggle] _linetexon ("Line Tex On", Float) = 1
		[MaterialToggle] _notusetexspecular ("not use tex specular", Float) = 0
		[MaterialToggle] _nip ("nip?", Float) = 0
		_liquidmask ("Liquid Mask", 2D) = "black" {}
		_Texture2 ("Liquid Tex", 2D) = "black" {}
		_Texture3 ("Liquid Normal", 2D) = "bump" {}
		_LiquidTiling ("Liquid Tiling (u/v/us/vs)", Vector) = (0,0,2,2)
		_liquidftop ("liquidftop", Range(0, 2)) = 0
		_liquidfbot ("liquidfbot", Range(0, 2)) = 0
		_liquidbtop ("liquidbtop", Range(0, 2)) = 0
		_liquidbbot ("liquidbbot", Range(0, 2)) = 0
		_liquidface ("liquidface", Range(0, 2)) = 0
		_nip_specular ("nip_specular", Range(0, 1)) = 0.5
		_tex1mask ("tex1 mask(1=yes)", Float) = 0
		_NormalMask ("NormalMask(G)", 2D) = "black" {}
		_Cutoff ("Alpha cutoff", Range(0, 1)) = 0.5
		[Gamma]_CustomAmbient("Custom Ambient", Color) = (0.666666666, 0.666666666, 0.666666666, 1)
		[MaterialToggle] _UseRampForLights ("Use Ramp For Light", Float) = 1
		[MaterialToggle] _UseRampForSpecular ("Use Ramp For Specular", Float) = 0
		[MaterialToggle] _UseLightColorSpecular ("Use Light Color Specular", Float) = 1
		[MaterialToggle] _UseDetailRAsSpecularMap ("Use DetailR as Specular Map", Float) = 0
		_LineWidthS ("LineWidthS", Float) = 1
		[Enum(Off,0,On,1)]_OutlineOn ("Outline On", Float) = 1.0
	}
	SubShader
	{
		LOD 600
		Tags { "Queue" = "AlphaTest-100" "RenderType" = "TransparentCutout" }
		//Outline
		Pass
		{
			Name "Outline"
			LOD 600
			Tags {"Queue" = "AlphaTest-100" "RenderType" = "TransparentCutout" "ShadowSupport" = "true" }
			Cull Front

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			#include "KKPSkinInput.cginc"
			#include "KKPDiffuse.cginc"
			Varyings vert (VertexData v)
			{
				Varyings o;
				o.posWS = mul(unity_ObjectToWorld, v.vertex);
				float3 viewDir = _WorldSpaceCameraPos.xyz - o.posWS.xyz;
				float viewVal = dot(viewDir, viewDir);
				viewVal = sqrt(viewVal);
				viewVal = viewVal * 0.0999999866 + 0.300000012;
				float lineVal = _linewidthG * 0.00499999989;
				viewVal *= lineVal * _LineWidthS;
				float2 detailMaskUV = v.uv0 * _DetailMask_ST.xy + _DetailMask_ST.zw;
				float4 detailMask = tex2Dlod(_DetailMask, float4(detailMaskUV, 0, 0));
				float detailB = 1 - detailMask.b;
				viewVal *= detailB;
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
				o.color = v.color;
				o.uv0 = v.uv0;
				o.uv1 = v.uv1;
				o.uv2 = v.uv2;
				o.uv3 = v.uv3;
				return o;
			}
			

			

			fixed4 frag (Varyings i, int frontFace : VFACE) : SV_Target
			{
				//Defined in Diffuse.cginc
				AlphaClip(i.uv0, _OutlineOn ? 1 : 0);	
				float3 diffuse = GetDiffuse(i);
				float3 u_xlat1;
				MapValuesOutline(diffuse, u_xlat1);



				bool3 compTest = 0.555555582 < u_xlat1.xyz;
				float3 diffuseShaded = u_xlat1.xyz * 0.899999976 - 0.5;
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

				u_xlat1.xyz *= finalAmbientShadow;
				u_xlat1.xyz *= 1.79999995;
				diffuseShaded = -diffuseShaded * invertFinalAmbientShadow + 1;
				{
					float3 hlslcc_movcTemp = u_xlat1;
					hlslcc_movcTemp.x = (compTest.x) ? diffuseShaded.x : u_xlat1.x;
					hlslcc_movcTemp.y = (compTest.y) ? diffuseShaded.y : u_xlat1.y;
					hlslcc_movcTemp.z = (compTest.z) ? diffuseShaded.z : u_xlat1.z;
					u_xlat1 = saturate(hlslcc_movcTemp);
				}
				float3 finalDiffuse = diffuse * u_xlat1;
				float2 detailMaskUV = i.uv0 * _DetailMask_ST.xy + _DetailMask_ST.zw;
				float4 detailMask = tex2D(_DetailMask, detailMaskUV);

				float detailGInv = 1 - detailMask.g;
				detailGInv = detailGInv * 0.5 + 0.5;
				float3 outLineCol = -finalDiffuse * detailGInv + 1;
				finalDiffuse *= detailGInv;
				float outlineBlend = _LineColorG.a - 0.5;
				outlineBlend = -outlineBlend * 2.0 + 1.0;
				outLineCol = -outlineBlend * outLineCol + 1;

				float outlineADoubled = _LineColorG.w * 2;
				finalDiffuse *= outlineADoubled;

				finalDiffuse = 0.5 < _LineColorG.w ? outLineCol : finalDiffuse;
				finalDiffuse = saturate(finalDiffuse);
				outLineCol = _LightColor0.rgb * float3(0.600000024, 0.600000024, 0.600000024) + _CustomAmbient.rgb;

				return float4(finalDiffuse * outLineCol, 1.0);


			}

			
			ENDCG
		}

		//Main Pass
		Pass
		{
			Name "Forward"
			LOD 600
			Tags { "LightMode" = "ForwardBase" "Queue" = "AlphaTest-100" "RenderType" = "TransparentCutout" "ShadowSupport" = "true" }
			Blend One OneMinusSrcAlpha, One OneMinusSrcAlpha
			Cull Off


			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile _ VERTEXLIGHT_ON
			#pragma multi_compile _ SHADOWS_SCREEN

			#define KKP_EXPENSIVE_RAMP
			
			//Unity Includes
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
			#include "Lighting.cginc"


			#include "KKPSkinInput.cginc"
			#include "KKPDiffuse.cginc"
			#include "KKPNormals.cginc"
			#include "../KKPVertexLights.cginc"
			#include "../KKPVertexLightsSpecular.cginc"
			#include "KKPLighting.cginc"
			#include "../KKPEmission.cginc"
			#include "KKPCoom.cginc"



			Varyings vert (VertexData v)
			{
				Varyings o;
				o.posWS = mul(unity_ObjectToWorld, v.vertex);
				o.posCS = mul(UNITY_MATRIX_VP, o.posWS);
				o.normalWS = UnityObjectToWorldNormal(v.normal);
				o.tanWS = float4(UnityObjectToWorldDir(v.tangent.xyz), v.tangent.w);
				float3 biTan = cross(o.tanWS, o.normalWS);
				o.bitanWS = normalize(biTan);
				o.color = v.color;
				o.uv0 = v.uv0;
				o.uv1 = v.uv1;
				o.uv2 = v.uv2;
				o.uv3 = v.uv3;
				
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
			




			fixed4 frag (Varyings i) : SV_Target
			{
				//Clips based on alpha texture
				AlphaClip(i.uv0, _OutlineOn ? 1 : 0);


				//Used in various things so calculating them here
				float3 worldLightPos = normalize(_WorldSpaceLightPos0.xyz);
				float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.posWS);

				//Diffuse and color maps KK uses for shading I assume
				float3 diffuse = GetDiffuse(i);
				float3 specularAdjustment; //Adjustments for specular from detailmap
				float3 shadingAdjustment; //Adjustments for shading
				MapValuesMain(diffuse, specularAdjustment, shadingAdjustment);

				//Normals from texture
				float3 normal = GetNormal(i);
	
				// Cum
				float liquidFinalMask;
				float3 liquidNormal;
				GetCumVals(i.uv0, liquidFinalMask, liquidNormal);
				
				//Combines normals from cum then adjusts to WS from TS
				float3 finalCombinedNormal = lerp(normal, liquidNormal, liquidFinalMask); 
				normal = NormalAdjust(i, finalCombinedNormal);
				//Detailmask channels:
				//Red 	: Specular
				//Green : Drawn shadows
				//Blue 	:  Something with rim light
				//Alpha : Specular Intensity, Black = Nails White = body
				float2 detailMaskUV = i.uv0 * _DetailMask_ST.xy + _DetailMask_ST.zw;
				float4 detailMask = tex2D(_DetailMask, detailMaskUV);

				float specularMap = _UseDetailRAsSpecularMap ? detailMask.r : 1;
				_SpecularPower *= specularMap;
				detailMask.xyz = 1 - detailMask.ywz;

				float2 lineMaskUV = i.uv0 * _LineMask_ST.xy + _LineMask_ST.zw;
				float4 lineMask = tex2D(_LineMask, lineMaskUV);
				lineMask.xz = -lineMask.zx * _DetailNormalMapScale + 1;


				//Lighting begins here

				//Because of how Koikatsu lighting works, the ForwardAdd pass method isn't going to look right with Koikatsu's shading
				//It's are limited to 4 pointlights + 1 directional light because we're using Unity's vertex lights which is capped at 4 + the Forward Light pass
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
				

				//Shadows used as a map for the darker shade
				float shadowExtend = _ShadowExtend * -1.20000005 + 1.0;
				float drawnShadows = min(detailMask.x, lineMask.x);
				float shadowAttenuation = GetShadowAttenuation(i, vertexLighting.a, normal, worldLightPos, viewDir);
				float oneMinusShadowExtend = 1 - shadowExtend;
				shadowExtend = drawnShadows * oneMinusShadowExtend + shadowExtend;
				shadowAttenuation *= shadowExtend;

				//FIGURE OUT BETTER SPECULAR MESH
				//Specular values
				float3 drawnSpecularColor;
				float drawnSpecular = GetDrawnSpecular(i, detailMask, shadowAttenuation, viewDir, drawnSpecularColor);
				float3 specularFromDetail = drawnSpecular * specularAdjustment.xyz + 1;
				specularFromDetail = diffuse.rgb * specularFromDetail.xyz + drawnSpecularColor;
				
				float3 specularColorMesh;
				float specularMesh = GetMeshSpecular(vertexLights, normal, viewDir, worldLightPos, specularColorMesh);
				float3 specularDiffuse = saturate((1 - _notusetexspecular) * specularFromDetail.xyz) + (_notusetexspecular * (specularColorMesh + diffuse));	
			
				//Shading
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
				float3 finalDiffuse = specularDiffuse * shadingAdjustment;
				specularDiffuse = -specularDiffuse * shadingAdjustment + specularDiffuse;
				specularDiffuse = specularDiffuse * shadowAttenuation + finalDiffuse;
				finalDiffuse = liquidFinalMask * float3(0.350000024, 0.45294112, 0.607352912) + float3(0.5, 0.397058904, 0.242647097);

				float3 cumCol = (GetLambert(worldLightPos, normal) + vertexLighting.a + 0.5) * float3(0.149999976, 0.199999988, 0.300000012) + float3(.850000024, 0.800000012, 0.699999988);
				float3 bodyShine = finalDiffuse * cumCol + specularMesh;

				//Rimlight
				float fresnel = dot(normal, viewDir);
				fresnel = max(fresnel, 0.0);
				fresnel = log2(1 - fresnel);
				float rimLight = _rimpower * 9 + 1;
				rimLight *= exp2(fresnel) * 5 - 2;
				float2 detailMaskAdjusted = detailMask.xz * float2(0.5, 2.5) + float2(0.5, -1.5);
				rimLight = saturate(min(rimLight, detailMaskAdjusted.y));
				rimLight *= detailMask.x;

				bodyShine = rimLight * _rimV + bodyShine;
				bodyShine = bodyShine - specularDiffuse;
				specularDiffuse = liquidFinalMask * bodyShine + specularDiffuse;
				//Final lighting colors
				bodyShine = (_LightColor0.rgb + vertexLighting.rgb * vertexLightRamp) * float3(0.600000024, 0.600000024, 0.600000024) + _CustomAmbient.rgb;
				float3 ambientCol = max(bodyShine, _ambientshadowG.xyz);
				specularDiffuse *= ambientCol;
				float3 diffuseAdjusted = diffuse * shadingAdjustment;

				//Final combine with drawn lines
				float3 coolVal = -diffuseAdjusted * detailMaskAdjusted.x + 1;
				diffuseAdjusted = detailMaskAdjusted.x * diffuseAdjusted;
				float lineColAlpha = _LineColorG.a - 0.5;
				lineColAlpha = -lineColAlpha * 2.0 + 1.0;
				float3 someValue = -lineColAlpha * coolVal + 1;
				lineColAlpha = _LineColorG.a * 2;
				diffuseAdjusted *= lineColAlpha;
				diffuseAdjusted = 0.5 < _LineColorG.a ? someValue : diffuseAdjusted;
				diffuseAdjusted = saturate(diffuseAdjusted) * bodyShine;
				
				float3 invertShadingAdjustment = 1 - shadingAdjustment;
				shadingAdjustment = shadowExtend * invertShadingAdjustment + shadingAdjustment;
				specularDiffuse = specularDiffuse * shadingAdjustment - diffuseAdjusted;

				float lineMaskB = lineMask.z * 0.5 + 0.5;
				float lineWidth = 1 - (_linewidthG);
				lineWidth = lineWidth * 0.800000012 + 0.200000003;
				lineWidth = log2(lineWidth) * lineMask.y;
				lineWidth = exp2(lineWidth);
				lineWidth = min(lineWidth, lineMaskB) - 1;
				lineWidth = _linetexon * lineWidth + 1.0;


				float3 finalCol = (lineWidth * specularDiffuse + diffuseAdjusted);

				//Overlay Emission over everything
				float4 emission = GetEmission(i.uv0);
				finalCol = finalCol * (1 - emission.a) + (emission.a*emission.rgb);

				return float4(finalCol, 1);
			}

			
			ENDCG
		}

		
		//ShadowCaster
		Pass
		{
			Name "ShadowCaster"
			LOD 600
			Tags { "LightMode" = "ShadowCaster" "Queue" = "AlphaTest-100" "RenderType" = "TransparentCutout" "ShadowSupport" = "true" }
			Offset 1, 1
			Cull Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_shadowcaster

			#include "UnityCG.cginc"

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
				alphaVal = max(alphaVal, alphaMask.xy);
				alphaVal = min(alphaVal.y, alphaVal.x);
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
