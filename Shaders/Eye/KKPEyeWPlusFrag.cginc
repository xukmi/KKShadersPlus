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
	
	float shadowAttenuation = saturate(ramp);
	#ifdef SHADOWS_SCREEN
		float2 shadowMapUV = i.shadowCoordinate.xy / i.shadowCoordinate.ww;
		float4 shadowMap = tex2D(_ShadowMapTexture, shadowMapUV);
		shadowAttenuation *= shadowMap;
	#endif

	float3 lightCol = (_LightColor0.xyz + vertexLighting.rgb * vertexLightRamp) * float3(0.600000024, 0.600000024, 0.600000024) + _CustomAmbient;
	lightCol = max(lightCol, _ambientshadowG.xyz);
	finalCol *= lightCol;
	
	float3 hsl = RGBtoHSL(finalCol);
	hsl.x = hsl.x + _ShadowHSV.x;
	hsl.y = hsl.y + _ShadowHSV.y;
	hsl.z = hsl.z + _ShadowHSV.z;
	finalCol = lerp(HSLtoRGB(hsl), finalCol, saturate(shadowAttenuation + 0.5));

	// Overlay emission over everything
	float4 emission = GetEmission(i.uv0);
	finalCol = finalCol * (1 - emission.a) + (emission.a * emission.rgb);
	
	return float4(finalCol, 1);
}