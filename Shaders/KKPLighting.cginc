#ifndef KKP_LIGHTING_INC
#define KKP_LIGHTING_INC

//Specular
float GetDrawnSpecular(Varyings i, float4 detailMask, float shadowAttenuation, float3 viewDir, out float3 drawnSpecularColor){
	float specularHeight = _SpeclarHeight  - 1.0;
	specularHeight *= 0.800000012;
	float2 detailSpecularOffset;
	detailSpecularOffset.x = dot(i.tanWS, viewDir);
	detailSpecularOffset.y = dot(i.bitanWS, viewDir);

	float2 detailMaskUV2 = specularHeight * detailSpecularOffset + i.uv0;
	detailMaskUV2 = detailMaskUV2 * _DetailMask_ST.xy + _DetailMask_ST.zw;
	float4 detailMask2 = tex2D(_DetailMask, detailMaskUV2);
	float detailSpecular = saturate(detailMask2.x * 1.66666698);
	float squaredDetailSpecular = detailSpecular * detailSpecular;
	float specularUnder = -detailSpecular * squaredDetailSpecular + detailSpecular;
	detailSpecular *= squaredDetailSpecular;

	drawnSpecularColor = detailSpecular * _SpecularColor.xyz;
	float bodySpecular = detailMask.a * _SpecularPower;
	float nailSpecular = detailMask.g * _SpecularPowerNail;
	float specularIntensity = max(bodySpecular, nailSpecular);
	float specular = specularIntensity * specularUnder;
	drawnSpecularColor *= specularIntensity;

	float dotSpecCol = dot(drawnSpecularColor.rgb, float3(0.300000012, 0.589999974, 0.109999999));
	dotSpecCol = min(dotSpecCol, specular);
	dotSpecCol = min(dotSpecCol, shadowAttenuation);
	dotSpecCol = min(dotSpecCol, detailMask.a);
	return dotSpecCol;
}

float GetMeshSpecular(Varyings i, KKVertexLight vertexLights[4], float3 normal, float3 viewDir, float3 worldLightPos, out float3 specularColorMesh){
	float3 halfVector = normalize(viewDir + worldLightPos);
	float specularMesh = max(dot(halfVector, normal), 0.0);
	specularMesh = log2(specularMesh);
	float specularPowerMesh = _SpecularPower * 256;
	specularPowerMesh = specularPowerMesh * specularMesh;
	specularPowerMesh = saturate(exp2(specularPowerMesh) * _SpecularPower * _SpecularColor.a);
	specularMesh = exp2(specularMesh * 256) * 0.5;

#ifdef KKP_EXPENSIVE_RAMP
	float2 lightRampUV = specularPowerMesh * _RampG_ST.xy + _RampG_ST.zw;
	specularPowerMesh = tex2D(_RampG, lightRampUV) * _UseRampForSpecular + specularPowerMesh * (1 - _UseRampForSpecular);
#endif

	float3 specularColor = _UseLightColorSpecular ? _LightColor0.rgb * _SpecularColor.a: _SpecularColor.rgb * _SpecularColor.a;
	specularColorMesh = specularPowerMesh * specularColor;

#ifdef VERTEXLIGHT_ON
	float3 specularColorVertex = 0;
	specularMesh += GetVertexSpecularDiffuse(vertexLights, normal, viewDir, _SpecularPower, specularColorVertex);
	specularColorMesh += specularColorVertex;
#endif

	return specularMesh;
}

float GetLambert(float3 lightPos, float3 normal){
    return max(dot(lightPos, normal), 0.0);
}

//Shadows
float GetShadowAttenuation(Varyings i, float vertexLightingShadowAtten, float3 normal, float3 worldLightPos, float3 viewDir){

	//Normal adjustment for the face I suppose it keeps the face more lit?
	float3 viewNorm = viewDir - normal;
	float2 normalMaskUV = i.uv0 * _NormalMask_ST.xy + _NormalMask_ST.zw;
	float3 normalMask = tex2D(_NormalMask, normalMaskUV).rgb;
	normalMask.xy = normalMask.yz * float2(_FaceNormalG, _FaceShadowG);
	viewNorm = normalMask.x * viewNorm + normal;
	float maskG = max(normalMask.g, 1.0);
	
	#ifdef SHADOWS_SCREEN
		float2 shadowMapUV = i.shadowCoordinate.xy / i.shadowCoordinate.ww;
		float4 shadowMap = tex2D(_ShadowMapTexture, shadowMapUV);
		float shadowAttenuation = saturate(shadowMap.x * 2.0 - 1.0);
		shadowAttenuation = max(shadowAttenuation, normalMask.y);
	#else
		float shadowAttenuation = maskG;
	#endif

	float shadowAttenLambert = _UseRampForShadows ? shadowAttenuation : 1;
	float rampAtten = _UseRampForShadows ? 1 : shadowAttenuation;

    float lambertShadows = GetLambert(worldLightPos, normal) * shadowAttenLambert;
    float vertexShadows = vertexLightingShadowAtten;
	float blendShadows = max(vertexShadows, lambertShadows);
	float2 rampUV = blendShadows * _RampG_ST.xy + _RampG_ST.zw;
	float ramp = tex2D(_RampG, rampUV).x * rampAtten;

    return ramp;
}
#endif