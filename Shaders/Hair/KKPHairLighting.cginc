#ifndef KKP_HAIR_LIGHTING_INC
#define KKP_HAIR_LIGHTING_INC

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