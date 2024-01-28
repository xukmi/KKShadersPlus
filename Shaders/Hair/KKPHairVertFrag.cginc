#ifndef KKP_HAIRVF_INC
#define KKP_HAIRVF_INC

Varyings vert (VertexData v)
{
	Varyings o;
	
#ifdef TESS_SHADER
	float4 vertex = v.vertex;
	float3 normal = v.normal;
	DisplacementValues(v, vertex, normal);
	v.vertex = vertex;
	v.normal = normal;
#endif
	
	o.posWS = mul(unity_ObjectToWorld, v.vertex);
	o.posCS = mul(UNITY_MATRIX_VP, o.posWS);
	o.normalWS = UnityObjectToWorldNormal(v.normal);
	o.tanWS = float4(UnityObjectToWorldDir(v.tangent.xyz), v.tangent.w);


	float3 u_xlat0 = o.normalWS;
	float3 u_xlat1 = o.tanWS;
	float3 u_xlat2;
	float u_xlat9;
	u_xlat2.xyz = u_xlat0.zxy * u_xlat1.yzx;
	u_xlat0.xyz = u_xlat0.yzx * u_xlat1.zxy + (-u_xlat2.xyz);
	u_xlat0.xyz = u_xlat0.xyz * v.tangent.www;
	u_xlat9 = dot(u_xlat0.xyz, u_xlat0.xyz);
	u_xlat9 = rsqrt(u_xlat9);
	o.bitanWS = (u_xlat9) * u_xlat0.xyz;
	
	//float3 biTan = cross(o.tanWS, o.normalWS);
	//o.bitanWS = normalize(biTan);

	o.uv0 = v.uv0;
	o.uv1 = v.uv1;
				
#ifdef SHADOWS_SCREEN
	float4 projPos = o.posCS;
	projPos.y *= _ProjectionParams.x;
	float4 projbiTan;
	projbiTan.xyz = o.bitanWS;
	projbiTan.xzw = projPos.xwy * 0.5;
	o.shadowCoordinate.zw = projPos.zw;
	o.shadowCoordinate.xy = projbiTan.zz + projbiTan.xw;
#endif
	return o;
}

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
	
	float3 viewDir = normalize(_WorldSpaceCameraPos - i.posWS);
	float3 worldLight = normalize(_WorldSpaceLightPos0.xyz); //Directional light
	float4 mainTex = SAMPLE_TEX2D_SAMPLER(_MainTex, SAMPLERTEX, i.uv0 * _MainTex_ST.xy + _MainTex_ST.zw);
	float alpha = AlphaClip(i.uv0, mainTex.a);
	float3 diffuse = GetDiffuse(i.uv0) * mainTex.rgb;

	float3 ambientShadowExtendAdjust;
	AmbientShadowAdjust(ambientShadowExtendAdjust);

	float3 adjustedNormal = NormalAdjust(i, GetNormal(i), frontFace);
	_NormalMapScale *= _SpecularNormalScale;
	float3 specularNormal = NormalAdjust(i, GetNormal(i), frontFace);
	

	float3x3 rotX = AngleAxis3x3(_KKPRimRotateX, float3(0, 1, 0));
	float3x3 rotY = AngleAxis3x3(_KKPRimRotateY, float3(1, 0, 0));
	float3 adjustedViewDir = frontFace == 1 ? viewDir : -viewDir;
	float3 rotView = mul(adjustedViewDir, mul(rotX, rotY));
	float kkpFres = max(0.1, dot(adjustedNormal, rotView));
	kkpFres = saturate(pow(1-kkpFres, _KKPRimSoft) * _KKPRimIntensity);
	_KKPRimColor.a *= (_UseKKPRim);
	float3 kkpFresCol = kkpFres * _KKPRimColor + (1 - kkpFres) * diffuse;
	
	float fresnel = max(0.0, dot(viewDir, adjustedNormal));
	float anotherRamp = tex2D(_AnotherRamp, fresnel * _AnotherRamp_ST.xy + _AnotherRamp_ST.zw).x;
	fresnel = 1 - fresnel;
	fresnel = log2(fresnel);
	float rimPow = _rimpower * 9.0 + 1.0;
	fresnel *= rimPow;
	fresnel = exp2(fresnel);
	fresnel = saturate(fresnel * 5.0 - 1.5) * (1-_UseKKPRim);
				
	ambientShadowExtendAdjust = min(ambientShadowExtendAdjust * fresnel, 0.5);
				
	
	KKVertexLight vertexLights[4];
#ifdef VERTEXLIGHT_ON
	GetVertexLightsTwo(vertexLights, i.posWS, _DisablePointLights);	
#endif
	float4 vertexLighting = 0.0;
	float vertexLightRamp = 1.0;
#ifdef VERTEXLIGHT_ON
	vertexLighting = GetVertexLighting(vertexLights, adjustedNormal);
	float2 vertexLightRampUV = vertexLighting.a * _RampG_ST.xy + _RampG_ST.zw;
	vertexLightRamp = tex2D(_RampG, vertexLightRampUV).x;
	float3 rampLighting = GetRampLighting(vertexLights, adjustedNormal, vertexLightRamp);
	vertexLighting.rgb = _UseRampForLights ? rampLighting : vertexLighting.rgb;
#endif

	float3 halfVector = normalize(viewDir + worldLight);
	float specularMesh = max(dot(halfVector, specularNormal), 0.0);
	specularMesh = log2(specularMesh);
	float specularPowerMesh = _SpecularHairPower * 256;
	specularPowerMesh = specularPowerMesh * specularMesh;
	specularPowerMesh = saturate(exp2(specularPowerMesh) * _SpecularHairPower * _SpecularColor.a);
	float specularMask = _SpecularIsHighLightsPow;
	specularMask = specularMask * specularMesh;
	specularMask = saturate(exp2(specularMask) * _SpecularColor.a);


#ifdef KKP_EXPENSIVE_RAMP
	float2 lightRampUV = specularPowerMesh * _RampG_ST.xy + _RampG_ST.zw;
	specularPowerMesh = tex2D(_RampG, lightRampUV) * _UseRampForSpecular + specularPowerMesh * (1 - _UseRampForSpecular);
#endif

	float3 specularLightColor = _UseLightColorSpecular ? _LightColor0.rgb * _SpecularColor.a: _SpecularColor.rgb * _SpecularColor.a;

	float4 specularColorMesh;
	specularColorMesh.rgb = specularPowerMesh * specularLightColor;
	specularColorMesh.a = specularMask;
#ifdef VERTEXLIGHT_ON
	float3 specularColorVertex = 0;
	specularColorMesh += GetVertexSpecularHair(vertexLights, specularNormal, viewDir, _SpecularIsHighLightsPow, _SpecularHairPower);
#endif
	float specular = specularColorMesh.a; //Mask
	float3 specularColor = specularColorMesh.rgb; //Color

	float lambert = saturate(dot(worldLight, adjustedNormal)) + vertexLighting.a;
	float ramp = tex2D(_RampG, lambert * _RampG_ST.xy + _RampG_ST.zw).x;
	float bitanFres = dot(viewDir, i.bitanWS);
	float specularHeight = _SpeclarHeight - 1.0;
	float3 hairGlossVal;
	//Slightly different values for hair front
#ifdef HAIR_FRONT 
	hairGlossVal.x = lambert * 0.0199999809 + i.uv1.x;
	hairGlossVal.x += 0.99000001;
#else
	hairGlossVal.x = lambert * 0.00499999989 + i.uv1.x;
#endif
	//For some reason hair gloss is fucked on some hairs unless you invert
	float invertSpecularHeight = _SpecularHeightInvert ? -1 : 1;
	hairGlossVal.z = invertSpecularHeight * specularHeight * bitanFres + i.uv1.y;
	hairGlossVal.y = hairGlossVal.z + 0.00800000038;

	float4 hairGlossUV = hairGlossVal.xyxz * _HairGloss_ST.xyxy + _HairGloss_ST.zwzw;
	float4 hairGloss1 = SAMPLE_TEX2D_SAMPLER(_HairGloss, SAMPLERTEX, hairGlossUV.xy);
	float4 hairGloss2 = SAMPLE_TEX2D_SAMPLER(_HairGloss, SAMPLERTEX, hairGlossUV.zw);
	float hairGloss = (hairGloss1 - hairGloss2) * 0.5f;

	float4 ambientShadow = 1 - _ambientshadowG.wxyz;
	float3 ambientShadowIntensity = -ambientShadow.x * ambientShadow.yzw + 1;
	float ambientShadowAdjust = _ambientshadowG.w * 0.5 + 0.5;
	float ambientShadowAdjustDoubled = ambientShadowAdjust + ambientShadowAdjust;
	bool ambientShadowAdjustShow = 0.5 < ambientShadowAdjust;
	ambientShadow.rgb = ambientShadowAdjustDoubled * _ambientshadowG.rgb;
	float3 finalAmbientShadow = ambientShadowAdjustShow ? ambientShadowIntensity : ambientShadow.rgb;
	finalAmbientShadow = saturate(finalAmbientShadow);
	float3 invertFinalAmbientShadow = 1 - finalAmbientShadow;

	finalAmbientShadow = finalAmbientShadow * (_ShadowColor.xyz+1E-06);
	finalAmbientShadow += finalAmbientShadow;
	float3 shadowCol = _ShadowColor+1E-06 - 0.5;
	shadowCol = -shadowCol * 2 + 1;

	invertFinalAmbientShadow = -shadowCol * invertFinalAmbientShadow + 1;
	bool3 shadeCheck = 0.5 < (_ShadowColor.xyz+1E-06);
	{
	    float3 hlslcc_movcTemp = finalAmbientShadow;
	    hlslcc_movcTemp.x = (shadeCheck.x) ? invertFinalAmbientShadow.x : finalAmbientShadow.x;
	    hlslcc_movcTemp.y = (shadeCheck.y) ? invertFinalAmbientShadow.y : finalAmbientShadow.y;
	    hlslcc_movcTemp.z = (shadeCheck.z) ? invertFinalAmbientShadow.z : finalAmbientShadow.z;
	    finalAmbientShadow = hlslcc_movcTemp;
	}
	
	float shadowAttenuation = saturate(min(ramp, anotherRamp));
	float rampAdjust = ramp * 0.5 + 0.5;
	#ifdef SHADOWS_SCREEN
		float2 shadowMapUV = i.shadowCoordinate.xy / i.shadowCoordinate.ww;
		float4 shadowMap = tex2D(_ShadowMapTexture, shadowMapUV);
		shadowAttenuation *= shadowMap;
	#endif
	
	float rimPlace = lerp(lerp(1 - shadowAttenuation, 1, min(_rimReflectMode+1, 1)), shadowAttenuation, max(0, _rimReflectMode));
	diffuse = lerp(diffuse, kkpFresCol, _KKPRimColor.a * kkpFres * _KKPRimAsDiffuse * rimPlace);
	
	finalAmbientShadow = saturate(finalAmbientShadow);
	float minusAmbientShadow = finalAmbientShadow - 1;
	minusAmbientShadow = hairGloss * minusAmbientShadow + 1;
	shadowCol = diffuse * minusAmbientShadow;
	shadowCol *= finalAmbientShadow;
	diffuse = diffuse * minusAmbientShadow - shadowCol;
	
	float4 detailMask = tex2D(_DetailMask, i.uv0 * _DetailMask_ST.xy + _DetailMask_ST.zw);
	float specularMap = _UseDetailRAsSpecularMap ? detailMask.r : 1;
	_SpecularHairPower *= specularMap;
	float2 invertDetailGB = 1 - detailMask.gb;
	float shadowMasked = shadowAttenuation * invertDetailGB.x;
	shadowAttenuation = max(shadowAttenuation, invertDetailGB.x);
	diffuse = shadowMasked * diffuse + shadowCol;
	
	//Add hair gloss
	hairGloss2.x = _SpecularIsHighlights ? min(hairGloss2.x, specular * _SpecularIsHighlightsRange) : hairGloss2.x; 
	hairGloss2.x *= specularMap;
	float hairGlossMask = hairGloss2.x * rampAdjust * _GlossColor.a;
	float3 hairGlossColor = hairGlossMask * _GlossColor.rgb * _GlossColor.a;
	diffuse = hairGlossColor + saturate(1 - hairGlossMask) * diffuse;
	float rimVal = invertDetailGB.x * _rimV * rimPlace;
	rimVal *= invertDetailGB.y;

	float3 finalDiffuse  = saturate(rimVal * ambientShadowExtendAdjust + diffuse) + _UseMeshSpecular * specularColor;

	float shadowExtend = 1 - _ShadowExtend;
	shadowAttenuation = max(shadowAttenuation, shadowExtend);
	float3 shading = 1 - finalAmbientShadow;
	shading = shadowAttenuation * shading + finalAmbientShadow;
	finalDiffuse *= shading;
	shading = (_LightColor0.xyz + vertexLighting.rgb * vertexLightRamp)* float3(0.600000024, 0.600000024, 0.600000024) + _CustomAmbient.rgb;
	shading = max(shading, _ambientshadowG.rgb);
	finalDiffuse *= shading;
	
	float3 hsl = RGBtoHSL(finalDiffuse);
	hsl.x = hsl.x + _ShadowHSV.x;
	hsl.y = hsl.y + _ShadowHSV.y;
	hsl.z = hsl.z + _ShadowHSV.z;
	finalDiffuse = lerp(HSLtoRGB(hsl), finalDiffuse, saturate(shadowMasked + 0.5));

	finalDiffuse = lerp(finalDiffuse, kkpFresCol, _KKPRimColor.a * kkpFres * rimPlace * (1 - _KKPRimAsDiffuse));

	//Overlay Emission over everything
	float4 emission = GetEmission(i.uv0);
	finalDiffuse = finalDiffuse * (1 - emission.a) +  (emission.a * emission.rgb);

	return float4(max(finalDiffuse,1E-06), alpha);
}

#endif