#ifndef KKP_SKINFRAG_INC
#define KKP_SKINFRAG_INC
// Rotation with angle (in radians) and axis
float3x3 AngleAxis3x3(float angle, float3 axis)
{
    float c, s;
    sincos(angle, s, c);

    float t = 1 - c;
    float x = axis.x;
    float y = axis.y;
    float z = axis.z;

    return float3x3(
        t * x * x + c,      t * x * y - s * z,  t * x * z + s * y,
        t * x * y + s * z,  t * y * y + c,      t * y * z - s * x,
        t * x * z - s * y,  t * y * z + s * x,  t * z * z + c
    );
}

			fixed4 frag (Varyings i, int frontFace : VFACE) : SV_Target
			{
				//Clips based on alpha texture
				AlphaClip(i.uv0, 1);

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

				//return float4(normal, 1);
				// Cum
				float liquidFinalMask;
				float3 liquidNormal;
				GetCumVals(i.uv0, liquidFinalMask, liquidNormal);
				
				//Combines normals from cum then adjusts to WS from TS
				float3 finalCombinedNormal = lerp(normal, liquidNormal, liquidFinalMask); 
				normal = NormalAdjust(i, finalCombinedNormal, frontFace);
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


				float3x3 rotX = AngleAxis3x3(_KKPRimRotateX, float3(0, 1, 0));
				float3x3 rotY = AngleAxis3x3(_KKPRimRotateY, float3(1, 0, 0));
				float3 adjustedViewDir = frontFace == 1 ? viewDir : -viewDir;
				float3 rotView = mul(adjustedViewDir, mul(rotX, rotY));
				float fresnel = dot(normal, rotView);
				float bodyFres = fresnel;
				bodyFres = saturate(pow(1-bodyFres, _KKPRimSoft) * _KKPRimIntensity);
				_KKPRimColor.a *= (_UseKKPRim);
				float3 bodyFresCol = bodyFres * _KKPRimColor;

				diffuse = lerp(diffuse, bodyFresCol, _KKPRimColor.a * bodyFres * _KKPRimAsDiffuse);

				//Lighting begins here

				//Because of how Koikatsu lighting works, the ForwardAdd pass method isn't going to look right with Koikatsu's shading
				//It's are limited to 4 pointlights + 1 directional light because we're using Unity's vertex lights which is capped at 4 + the Forward Light pass
				KKVertexLight vertexLights[4];
			#ifdef VERTEXLIGHT_ON
				GetVertexLightsTwo(vertexLights, i.posWS, _DisablePointLights);
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
				shadowExtend = drawnShadows * (1 - shadowExtend) + shadowExtend;
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
					float3 shadowCol = lerp(1, _ShadowColor.rgb, 1 - saturate(_ShadowColor.a));
					shadingAdjustment = saturate(hlslcc_movcTemp * shadowCol);
				}
				
				float3 finalDiffuse = specularDiffuse * shadingAdjustment;
				specularDiffuse = -specularDiffuse * shadingAdjustment + specularDiffuse;
				specularDiffuse = specularDiffuse * shadowAttenuation + finalDiffuse;
				finalDiffuse = liquidFinalMask * float3(0.350000024, 0.45294112, 0.607352912) + float3(0.5, 0.397058904, 0.242647097);
				
				float3 cumCol = (GetLambert(worldLightPos, normal) + vertexLighting.a + 0.5) * float3(0.149999976, 0.199999988, 0.300000012) + float3(.850000024, 0.800000012, 0.699999988);
				float3 bodyShine = finalDiffuse * cumCol + specularMesh;

				//Rimlight

				fresnel = max(fresnel, 0.0);
				fresnel = log2(1 - fresnel);
				float rimLight = _rimpower * 9 + 1;
				rimLight *= exp2(fresnel) * 5 - 2;
				float2 detailMaskAdjusted = detailMask.xz * float2(0.5, 2.5) + float2(0.5, -1.5);
				rimLight = saturate(min(rimLight, detailMaskAdjusted.y));
				rimLight *= detailMask.x * (1-_UseKKPRim);

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
				
				shadingAdjustment = shadowExtend * (1 - shadingAdjustment) + shadingAdjustment;
				specularDiffuse = specularDiffuse * shadingAdjustment - diffuseAdjusted;

				float lineMaskB = lineMask.z * 0.5 + 0.5;
				float lineWidth = 1 - (_linewidthG);
				lineWidth = lineWidth * 0.800000012 + 0.200000003;
				lineWidth = log2(lineWidth) * lineMask.y;
				lineWidth = exp2(lineWidth);
				lineWidth = min(lineWidth, lineMaskB) - 1;
				lineWidth = _linetexon * lineWidth + 1.0;

				float3 finalCol = (lineWidth * specularDiffuse + diffuseAdjusted);
				
				float3 hsl = RGBtoHSL(finalCol);
				hsl.x = hsl.x + _ShadowHSV.x;
				hsl.y = hsl.y + _ShadowHSV.y;
				hsl.z = hsl.z + _ShadowHSV.z;
				finalCol = lerp(HSLtoRGB(hsl), finalCol, saturate(shadowAttenuation + 0.5));

				finalCol = lerp(finalCol, bodyFresCol, _KKPRimColor.a * bodyFres * (1 - _KKPRimAsDiffuse));

				//Overlay Emission over everything
				float4 emission = GetEmission(i.uv0);
				finalCol = finalCol * (1 - emission.a) + (emission.a*emission.rgb);

				return float4(finalCol, 1); 
			}


#endif