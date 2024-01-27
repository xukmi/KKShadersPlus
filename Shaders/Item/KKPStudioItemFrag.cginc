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

float2 PatternUV(Varyings i, float4 ST, float4 uv, float rot, float clampuv) {
	float2 output = (i.uv0 + uv.xy);
	output = rotateUV(output, float2(0.5, 0.5), -rot * 3.14159265358979);
	output = (output - 0.5) * uv.zw + 0.5;
	output = output + (output - saturate(output)) * -clampuv;
	output = output * ST.xy + ST.zw;
	return output;
}

float3 SaturationAdjustment(float3 x) {
	return -2.39016 * x * x + 4.06485 * x - 0.223603;
}

float3 LightnessAdjustment(float3 x) {
	return -1.44837 * x * x + 3.80805 * x - 0.736657;
}

float ShadowExtendAdjustment(float x) {
	float pol1 = 0.2199 * x * x * x - 0.6290 * x * x + 1.411 * x;
	float pol2 = -0.0294 * x * x * x + 0.5031 * x * x - 1.4444 * x + 5.5711;
	return lerp(lerp(pol1, pol2, pow(saturate((x - 1) / 2),2)), x+3, pow(saturate((x - 7) / 2),2));
}

fixed4 frag (Varyings i, int faceDir : VFACE) : SV_Target {
	//Clips based on main texture
	float4 mainTex = SAMPLE_TEX2D_SAMPLER(_MainTex, SAMPLERTEX, i.uv0 * _MainTex_ST.xy + _MainTex_ST.zw);
	if (mainTex.a <= _Cutoff) discard;
	
	float alpha = 1;
	_ShadowColor = max(_ShadowColor, 1E-06);
#ifdef ALPHA_SHADER
	float2 alphaUV = i.uv0 * _MainTex_ST.xy + _MainTex_ST.zw;
	float alphaMask = SAMPLE_TEX2D_SAMPLER(_MainTex, SAMPLERTEX, alphaUV).a;
	alpha = 1 - (1 - (alphaMask - _Cutoff + 0.0001) / (1.0001 - _Cutoff)) * floor(_AlphaOptionCutoff/2.0) - (1 - alphaMask) * (floor(_AlphaOptionCutoff) % 2);
	if (alpha <= _Cutoff) discard;
	alpha *= _alpha * _alpha;
	
	_ShadowColor.rgb = (_ShadowColor.rgb) / MaxGrayscale(_ShadowColor.rgb);
	_ShadowColor.rgb = lerp(_ShadowColor.rgb, 1, 0.6) * (_ShadowColor.a);
	_ShadowColor = float4(_ShadowColor.rgb, 1);
#endif

	float3 worldLightPos = normalize(_WorldSpaceLightPos0.xyz);
	float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.posWS);
	float3 halfDir = normalize(viewDir + worldLightPos);

	float4 colorMask = SAMPLE_TEX2D_SAMPLER(_ColorMask, SAMPLERTEX, i.uv0 * _ColorMask_ST.xy + _ColorMask_ST.zw);
	
	float3 patternMask1 = SAMPLE_TEX2D_SAMPLER(_PatternMask1, _PatternMask1, PatternUV(i, _PatternMask1_ST, _Patternuv1, _patternrotator1, _patternclamp1)).rgb;
	float3 patternMask2 = SAMPLE_TEX2D_SAMPLER(_PatternMask2, _PatternMask1, PatternUV(i, _PatternMask2_ST, _Patternuv2, _patternrotator2, _patternclamp2)).rgb;
	float3 patternMask3 = SAMPLE_TEX2D_SAMPLER(_PatternMask3, _PatternMask1, PatternUV(i, _PatternMask3_ST, _Patternuv3, _patternrotator3, _patternclamp3)).rgb;
	
	float3 color1col = patternMask1 * _Color.rgb + (1 - patternMask1) * _Color1_2.rgb;
	float3 color2col = patternMask2 * _Color2.rgb + (1 - patternMask2) * _Color2_2.rgb;
	float3 color3col = patternMask3 * _Color3.rgb + (1 - patternMask3) * _Color3_2.rgb;
	
	float3 color;
	color = colorMask.r * (color1col - 1) + 1;
	color = colorMask.g * (color2col - color) + color;
	color = colorMask.b * (color3col - color) + color;
	float3 diffuse = mainTex * color;
	float3 shadowsOFF = diffuse;
	
	float3 normal = NormalAdjust(i, GetNormal(i), faceDir);
	_NormalMapScale *= _SpecularNormalScale;
	_DetailNormalMapScale *= _SpecularDetailNormalScale;
	float3 specularNormal = NormalAdjust(i, GetNormal(i), faceDir);

	float3x3 rotX = AngleAxis3x3(_KKPRimRotateX, float3(0, 1, 0));
	float3x3 rotY = AngleAxis3x3(_KKPRimRotateY, float3(1, 0, 0));
	float3 adjustedViewDir = faceDir == 1 ? viewDir : -viewDir;
	float3 rotView = mul(adjustedViewDir, mul(rotX, rotY));
	float kkpFres = dot(normal, rotView);
	kkpFres = saturate(pow(1-kkpFres, _KKPRimSoft) * _KKPRimIntensity);
	_KKPRimColor.a *= (_UseKKPRim);
	float3 kkpFresCol = kkpFres * _KKPRimColor + (1 - kkpFres) * diffuse;

	float2 detailUV = i.uv0 * _DetailMask_ST.xy + _DetailMask_ST.zw;
	float4 detailMask = tex2D(_DetailMask, detailUV);
	float2 lineMaskUV = i.uv0 * _LineMask_ST.xy + _LineMask_ST.zw;
	float4 lineMask = SAMPLE_TEX2D_SAMPLER(_LineMask, _LineMask, lineMaskUV);
	lineMask.r = lerp(lineMask.r, detailMask.r, _DetailRLineR);

	float4 ambientShadow = 1 - _ambientshadowG.wxyz;
	float3 ambientShadowIntensity = -ambientShadow.x * ambientShadow.yzw + 1;
	float ambientShadowAdjust = _ambientshadowG.w * 0.5 + 0.5;
	float ambientShadowAdjustDoubled = ambientShadowAdjust + ambientShadowAdjust;
	bool ambientShadowAdjustShow = 0.5 < ambientShadowAdjust;
	ambientShadow.rgb = ambientShadowAdjustDoubled * _ambientshadowG.rgb;
	float3 finalAmbientShadow = ambientShadowAdjustShow ? ambientShadowIntensity : ambientShadow.rgb;
	finalAmbientShadow = saturate(finalAmbientShadow);
	float3 invertFinalAmbientShadow = 1 - finalAmbientShadow;

	float3 shadingAdjustment = diffuse * _ShadowColor.rgb;
	shadingAdjustment *= finalAmbientShadow;
	shadingAdjustment *= 1.79999995;
	
#ifdef ALPHA_SHADER
	shadingAdjustment = saturate(shadingAdjustment);
#else
	float3 shadowCol = lerp(1, _ShadowColor.rgb, 1 - saturate(_ShadowColor.a));
	shadingAdjustment = saturate(shadingAdjustment * shadowCol);
#endif

	float shadowExtendAnother = 1 - _ShadowExtendAnother;
	float kkMetal = lerp(lineMask.r, 1, _AnotherRampFull);

	float kkMetalMap = kkMetal;
	kkMetal *= _UseKKMetal;

	shadowExtendAnother -= kkMetal;
	shadowExtendAnother += 1;
	shadowExtendAnother = saturate(shadowExtendAnother) * 0.670000017 + 0.330000013;

	float3 shadowExtendShaded = shadowExtendAnother * shadingAdjustment;
	float3 diffuseShadow = diffuse * shadowExtendShaded;
	float3 diffuseShadowBlended = -shadowExtendShaded * diffuse + diffuse;
	
	float3 adjustedShadow;
	{
		bool3 compTest = _ShadowColor.rgb > 0.555555582;
		float3 hsl = RGBtoHSL(shadowExtendShaded.rgb);
		float3 hsl_r = hsl;
		float3 hsl_g = hsl;
		float3 hsl_b = hsl;
		float3 saturation = SaturationAdjustment(_ShadowColor);
		float3 lightness = LightnessAdjustment(_ShadowColor);
		hsl_r.y *= compTest.x ? saturation.r : 1.3;
		hsl_r.z *= compTest.x ? lightness.r : 0.91;
		hsl_g.y *= compTest.y ? saturation.g : 1.3;
		hsl_g.z *= compTest.y ? lightness.g : 0.91;
		hsl_b.y *= compTest.z ? saturation.b : 1.3;
		hsl_b.z *= compTest.z ? lightness.b : 0.91;
		adjustedShadow = float3(HSLtoRGB(hsl_r).r, HSLtoRGB(hsl_g).g, HSLtoRGB(hsl_b).b);
	}

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

	float specular = dot(specularNormal, halfDir);
	specular = max(specular, 0.0);
	float anotherRampSpecularVertex = 0.0;
#ifdef VERTEXLIGHT_ON
	[unroll]
	for(int j = 0; j < 4; j++){
		KKVertexLight light = vertexLights[j];
		float3 halfVector = normalize(viewDir + light.dir) * saturate(MaxGrayscale(light.col));
		anotherRampSpecularVertex = max(anotherRampSpecularVertex, dot(halfVector, specularNormal));
	}
#endif
	float2 anotherRampUV = max(specular, anotherRampSpecularVertex) * _AnotherRamp_ST.xy + _AnotherRamp_ST.zw;
	float anotherRamp = tex2D(_AnotherRamp, anotherRampUV);
	specular = log2(specular);
	float finalRamp = lerp(ramp, anotherRamp, kkMetal);

#ifdef SHADOWS_SCREEN
	float2 shadowMapUV = i.shadowCoordinate.xy / i.shadowCoordinate.ww;
	float4 shadowMap = tex2D(_ShadowMapTexture, shadowMapUV);
	float shadowAttenuation = saturate(shadowMap.x * 2.0 - 1.0);
	finalRamp *= shadowAttenuation;
#endif
	
	float rimPlace = lerp(lerp(1 - finalRamp, 1, min(_rimReflectMode+1, 1)), finalRamp, max(0, _rimReflectMode));
	diffuse = lerp(diffuse, kkpFresCol, _KKPRimColor.a * kkpFres * _KKPRimAsDiffuse * rimPlace);
	
	_ShadowExtend = ShadowExtendAdjustment(_ShadowExtend);
	float sOFFshadowAdjust = 1 + 3.1 * saturate(2 * _ambientshadowOFF);
	float sOFFlightAdjust = 1 + 0.58 * saturate(2 * _ambientshadowOFF);
	float lightAmount = finalRamp * (1 - detailMask.g * _ShadowExtend);
	diffuseShadow = lerp(adjustedShadow * sOFFshadowAdjust, (diffuseShadowBlended + diffuseShadow) * sOFFlightAdjust, lightAmount);
	
	float specularHeight = _SpeclarHeight  - 1.0;
	specularHeight *= 0.800000012;
	float2 detailSpecularOffset;
	detailSpecularOffset.x = dot(i.tanWS, viewDir);
	detailSpecularOffset.y = dot(i.bitanWS, viewDir);
	float2 detailMaskUV2 = specularHeight * detailSpecularOffset + i.uv0;
	detailMaskUV2 = detailMaskUV2 * _DetailMask_ST.xy + _DetailMask_ST.zw;
	float drawnSpecular = tex2D(_DetailMask, detailMaskUV2).x;
	float drawnSpecularSquared = min(drawnSpecular * drawnSpecular, 1.0);

	_SpecularPower *= _UseDetailRAsSpecularMap ? detailMask.r : 1;

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
	specularVertex = GetVertexSpecularDiffuse(vertexLights, specularNormal, viewDir, _SpecularPower, specularVertexCol);
#endif
	float3 specularCol = saturate(specular) * _SpecularColor.rgb + saturate(specularVertex) * specularVertexCol * _notusetexspecular;
	specularCol *= _SpecularColor.a;

	float3 ambientShadowAdjust2 = AmbientShadowAdjust();

	float rimPow = _rimpower * 9.0 + 1.0;
	rimPow = rimPow * fresnel;
	float rim = saturate(exp2(rimPow) * 2.5 - 0.5) * _rimV * rimPlace;
	float rimMask = (1 - detailMask.b) * 9.99999809 + -8.99999809;
	rim *= rimMask;

	ambientShadowAdjust2 *= rim;
	ambientShadowAdjust2 *= 1 - detailMask.g;
	ambientShadowAdjust2 = min(max(ambientShadowAdjust2, 0.0), 0.5);
	diffuseShadow += ambientShadowAdjust2;

	float3 lightCol = (_LightColor0.xyz + vertexLighting.rgb * vertexLightRamp) * float3(0.600000024, 0.600000024, 0.600000024) + _CustomAmbient.rgb;
	float3 ambientCol = max(lightCol, _ambientshadowG.xyz);
	diffuseShadow = diffuseShadow * ambientCol;
	
	float drawnShadow = max(detailMask.g * _ShadowExtend * 0.25, lineMask.b);
	float detailLineShadow = lerp(lineMask.g, detailMask.b, _DetailBLineG);
	float texShadow = max(drawnShadow, detailLineShadow);

	shadingAdjustment = 1 - shadingAdjustment * shadowExtendAnother;
	shadingAdjustment = shadingAdjustment + shadowExtendShaded;
	shadingAdjustment *= diffuseShadow + specularCol;

	float4 emissionColor = float4(diffuse, 1);
	float emissionMask = saturate(detailMask.r * 5) * 3;
	
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

	float3 finalDiffuse = texShadow * diffuse + shadingAdjustment;
	
	float3 hsl = RGBtoHSL(finalDiffuse);
	hsl.x = hsl.x + _ShadowHSV.x;
	hsl.y = hsl.y + _ShadowHSV.y;
	hsl.z = hsl.z + _ShadowHSV.z;
	finalDiffuse = lerp(HSLtoRGB(hsl), finalDiffuse, saturate(finalRamp + 0.5));

	finalDiffuse = GetBlendReflections(i, max(finalDiffuse, 1E-06), normal, viewDir, kkMetalMap, finalRamp);

	finalDiffuse = lerp(finalDiffuse, kkpFresCol, _KKPRimColor.a * kkpFres * rimPlace * (1 - _KKPRimAsDiffuse));

	float4 emission = GetEmission(i.uv0);
	finalDiffuse = finalDiffuse * (1 - emission.a) + (emission.a*emission.rgb) + emissionColor * emissionMask * _EmissionPower;
	
	finalDiffuse = lerp(finalDiffuse, shadowsOFF, saturate(2 * _ambientshadowOFF - 1));

	return float4(max(finalDiffuse,1E-06), alpha);
}