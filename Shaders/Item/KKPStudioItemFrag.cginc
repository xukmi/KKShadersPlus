float3 AmbientShadowAdjust() {
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

float3x3 AngleAxis3x3(float angle, float3 axis) {
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

float2 PatternUV(Varyings i, float4 ST, float4 uv, float rot) {
	float2 output = (i.uv0 + uv.xy);
	output = rotateUV(output, float2(0.5, 0.5), -rot * 3.14159265358979);
	output = (output - 0.5) * uv.zw + 0.5;
	output = output * ST.xy + ST.zw;
	return output;
}

fixed4 frag (Varyings i, int faceDir : VFACE) : SV_Target {
	//Clips based on alpha texture
	float4 mainTex = SAMPLE_TEX2D_SAMPLER(_MainTex, SAMPLERTEX, i.uv0 * _MainTex_ST.xy + _MainTex_ST.zw);
	AlphaClip(i.uv0, mainTex.a);

	float3 worldLightPos = normalize(_WorldSpaceLightPos0.xyz);
	float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.posWS);
	float3 halfDir = normalize(viewDir + worldLightPos);

	float4 colorMask = SAMPLE_TEX2D_SAMPLER(_ColorMask, SAMPLERTEX, i.uv0 * _ColorMask_ST.xy + _ColorMask_ST.zw);
	
	float3 patternMask1 = SAMPLE_TEX2D_SAMPLER(_PatternMask1, _PatternMask1, PatternUV(i, _PatternMask1_ST, _Patternuv1, _patternrotator1)).rgb;
	float3 patternMask2 = SAMPLE_TEX2D_SAMPLER(_PatternMask2, _PatternMask1, PatternUV(i, _PatternMask2_ST, _Patternuv2, _patternrotator2)).rgb;
	float3 patternMask3 = SAMPLE_TEX2D_SAMPLER(_PatternMask3, _PatternMask1, PatternUV(i, _PatternMask3_ST, _Patternuv3, _patternrotator3)).rgb;
	
	float3 color1col = patternMask1 * _Color.rgb + (1 - patternMask1) * _Color1_2.rgb;
	float3 color2col = patternMask2 * _Color2.rgb + (1 - patternMask2) * _Color2_2.rgb;
	float3 color3col = patternMask3 * _Color3.rgb + (1 - patternMask3) * _Color3_2.rgb;
	
	float3 color;
	color = colorMask.r * (color1col - 1) + 1;
	color = colorMask.g * (color2col - color) + color;
	color = colorMask.b * (color3col - color) + color;
	float3 diffuse = mainTex * color;
	
	float3 normal = NormalAdjust(i, GetNormal(i), 1);

	float3x3 rotX = AngleAxis3x3(_KKPRimRotateX, float3(0, 1, 0));
	float3x3 rotY = AngleAxis3x3(_KKPRimRotateY, float3(1, 0, 0));
	float3 adjustedViewDir = faceDir == 1 ? viewDir : -viewDir;
	float3 rotView = mul(adjustedViewDir, mul(rotX, rotY));
	float kkpFres = dot(normal, rotView);
	kkpFres = saturate(pow(1-kkpFres, _KKPRimSoft) * _KKPRimIntensity);
	_KKPRimColor.a *= (_UseKKPRim);
	float3 kkpFresCol = kkpFres * _KKPRimColor + (1 - kkpFres) * diffuse;

	float3 shadingAdjustment = diffuse * _ShadowColor.rgb;

	float2 detailUV = i.uv0 * _DetailMask_ST.xy + _DetailMask_ST.zw;
	float4 detailMask = tex2D(_DetailMask, detailUV);
	float2 lineMaskUV = i.uv0 * _LineMask_ST.xy + _LineMask_ST.zw;
	float4 lineMask = SAMPLE_TEX2D_SAMPLER(_LineMask, SAMPLERTEX, lineMaskUV);
	lineMask.r = _DetailRLineR * (detailMask.r - lineMask.r) + lineMask.r;

	float4 ambientShadow = 1 - _ambientshadowG.wxyz;
	float3 ambientShadowIntensity = -ambientShadow.x * ambientShadow.yzw + 1;
	float ambientShadowAdjust = _ambientshadowG.w * 0.5 + 0.5;
	float ambientShadowAdjustDoubled = ambientShadowAdjust + ambientShadowAdjust;
	bool ambientShadowAdjustShow = 0.5 < ambientShadowAdjust;
	ambientShadow.rgb = ambientShadowAdjustDoubled * _ambientshadowG.rgb;
	float3 finalAmbientShadow = ambientShadowAdjustShow ? ambientShadowIntensity : ambientShadow.rgb;
	finalAmbientShadow = saturate(finalAmbientShadow);
	float3 invertFinalAmbientShadow = 1 - finalAmbientShadow;

	///////
	shadingAdjustment = shadingAdjustment * finalAmbientShadow;
	/*bool3 compTest = 0.555555582 < shadingAdjustment;
	shadingAdjustment *= finalAmbientShadow;
	shadingAdjustment *= 1.79999995;
	float3 diffuseShaded = shadingAdjustment * 0.899999976 - 0.5;
	diffuseShaded = -diffuseShaded * 2 + 1;
	diffuseShaded = -diffuseShaded * invertFinalAmbientShadow + 1;
	{
		float3 hlslcc_movcTemp = shadingAdjustment;
		hlslcc_movcTemp.x = (compTest.x) ? diffuseShaded.x : shadingAdjustment.x;
		hlslcc_movcTemp.y = (compTest.y) ? diffuseShaded.y : shadingAdjustment.y;
		hlslcc_movcTemp.z = (compTest.z) ? diffuseShaded.z : shadingAdjustment.z;
		
		shadingAdjustment = saturate(hlslcc_movcTemp);
	}*/
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
	
	float rimPlace = lerp(lerp(1 - finalRamp, 1, min(_rimReflectMode+1, 1)), finalRamp, max(0, _rimReflectMode));
	diffuse = lerp(diffuse, kkpFresCol, _KKPRimColor.a * kkpFres * _KKPRimAsDiffuse * rimPlace);
	
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

	_SpecularPower *= _UseDetailRAsSpecularMap ? detailMask.x : 1;

	float specularPower = _SpecularPower * 256.0;
	specular *= specularPower;
	specular = exp2(specular) * 5.0 - 4.0;
	drawnSpecular = saturate(specular * _SpecularPower + drawnSpecularSquared);
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
	float rim = saturate(exp2(rimPow) * 2.5 - 0.5) * _rimV * rimPlace;
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
	
	float3 hsl = RGBtoHSL(finalDiffuse);
	hsl.x = hsl.x + _ShadowHSV.x;
	hsl.y = hsl.y + _ShadowHSV.y;
	hsl.z = hsl.z + _ShadowHSV.z;
	finalDiffuse = lerp(HSLtoRGB(hsl), finalDiffuse, saturate(finalRamp + 0.5));

	finalDiffuse = GetBlendReflections(i, max(finalDiffuse, 1E-06), normal, viewDir, kkMetalMap, finalRamp);

	finalDiffuse = lerp(finalDiffuse, kkpFresCol, _KKPRimColor.a * kkpFres * rimPlace * (1 - _KKPRimAsDiffuse));

	float4 emission = GetEmission(i.uv0);
	finalDiffuse = finalDiffuse * (1 - emission.a) + (emission.a*emission.rgb);
	
	float alpha = 1;
	#ifdef ALPHA_SHADER
	float2 maskUV = i.uv0 * _AlphaMask_ST.xy + _AlphaMask_ST.zw;
	float alphaMask = SAMPLE_TEX2D_SAMPLER(_AlphaMask, SAMPLERTEX, maskUV).r;
	alphaMask = 1 - (1 - (alphaMask - _Cutoff + 0.0001) / (1.0001 - _Cutoff)) * floor(_AlphaOptionCutoff/2.0);
	alpha = mainTex.a * _Alpha * alphaMask;
	
	if (alpha <= 0) discard;
	#endif

	return float4(max(finalDiffuse,1E-06), alpha);
}