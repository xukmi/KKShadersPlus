fixed4 frag (Varyings i) : SV_Target {
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
	float4 iris = SAMPLE_TEX2D_SAMPLER(_MainTex, SAMPLERTEX, uv);
	float3 viewDir = normalize(_WorldSpaceCameraPos - i.posWS);
	float2 expressionUV = float2(dot(i.tanWS, viewDir),
						   dot(i.bitanWS, viewDir));
	//Gives some depth
	expressionUV = expressionUV * -0.059999998 * _ExpressionDepth + i.uv0;
	expressionUV = expressionUV * _MainTex_ST.xy + _MainTex_ST.zw; //Makes expression follow eye
	expressionUV -= 0.5;
	expressionUV /= max(0.1, _ExpressionSize);
	expressionUV += 0.5;
	float4 expression = SAMPLE_TEX2D_SAMPLER(_expression, _expression, expressionUV + float2(0, 0.1));
	expression.rgb =  expression.rgb - iris.rgb;
	expression.a *= _exppower;
	float3 diffuse = expression.a * expression.rgb + iris.rgb;


	float4 overTex1 = SAMPLE_TEX2D_SAMPLER(_overtex1, _overtex1, i.uv1 * _overtex1_ST + _overtex1_ST.zw);
	overTex1 = overTex1.a * _overcolor1.rgba;
	float4 overTex2 = SAMPLE_TEX2D_SAMPLER(_overtex2, _overtex2, i.uv2 * _overtex2_ST + _overtex2_ST.zw);
	overTex2 = overTex2.a * _overcolor2.rgba;
	float4 overTex = max(overTex1, overTex2);
	float3 blendOverTex = overTex.rgb - diffuse;
	overTex.a = saturate(overTex.a * _isHighLight);
	diffuse = overTex.a * blendOverTex + diffuse;
	float alpha = saturate(max(max(overTex.a, expression.a), iris.a));
	if (alpha < 0.01) discard;

	float3 shadedDiffuse = diffuse * finalAmbientShadow;
	finalAmbientShadow = -diffuse * finalAmbientShadow + diffuse;


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
	float lambert = max(dot(_WorldSpaceLightPos0.xyz, i.normalWS.xyz), 0.0) + vertexLighting.a;
	lambert = saturate(expression.a + overTex.a + lambert);
	finalAmbientShadow = lambert * finalAmbientShadow + shadedDiffuse;
	
	float shadowAttenuation = saturate(tex2D(_RampG, lambert * _RampG_ST.xy + _RampG_ST.zw).x);
	#ifdef SHADOWS_SCREEN
		float2 shadowMapUV = i.shadowCoordinate.xy / i.shadowCoordinate.ww;
		float4 shadowMap = tex2D(_ShadowMapTexture, shadowMapUV);
		shadowAttenuation *= shadowMap;
	#endif

	float3 lightCol = (_LightColor0.xyz + vertexLighting.rgb * vertexLightRamp) * float3(0.600000024, 0.600000024, 0.600000024) + _CustomAmbient;
	lightCol = max(lightCol, _ambientshadowG.xyz);
	float3 finalCol = finalAmbientShadow * lightCol;
	
	float3 hsl = RGBtoHSL(finalCol);
	hsl.x = hsl.x + _ShadowHSV.x;
	hsl.y = hsl.y + _ShadowHSV.y;
	hsl.z = hsl.z + _ShadowHSV.z;
	finalCol = lerp(HSLtoRGB(hsl), finalCol, saturate(shadowAttenuation + 0.5));

	// Overlay emission over expression
	float4 emission = GetEmission(expressionUV);
	finalCol = finalCol * (1 - emission.a) + (emission.a * emission.rgb);
	
	return float4(finalCol, alpha);
}