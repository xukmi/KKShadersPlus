#ifndef KK_LIGHTING_INC
// Upgrade NOTE: excluded shader from DX11, OpenGL ES 2.0 because it uses unsized arrays
#pragma exclude_renderers d3d11 gles
#define KK_LIGHTING_INC



// Vertex Lights
//Has nothing to do with vertex lighting
//This is using Unity's variables designated for single-pass multi-light lighting
struct KKVertexLight{
	float3 pos;
	float3 dir;
	float4 col;
	float atten;
	float lightVal;
};


void GetVertexLights(out KKVertexLight lights[4], float3 surfaceWorldPos){
	[unroll]
	for(int i = 0; i < 4; i++){
		KKVertexLight kLight;
		kLight.pos = float3(unity_4LightPosX0[i],
							unity_4LightPosY0[i],
							unity_4LightPosZ0[i]);
		float3 dir = kLight.pos - surfaceWorldPos;
		kLight.dir = normalize(dir);
		kLight.col = unity_LightColor[i];
		float distSqr = max(dot(dir, dir), 0.0001);
		kLight.atten = 1.0 / (1.0 + unity_4LightAtten0[i] * distSqr);
		lights[i] = kLight;
	}
}


float LumaGrayscale(float3 col){
	return col.r * 0.2126 + col.g * 0.7152 + col.b * 0.0722;
}

float4 GetVertexLighting(inout KKVertexLight lights[4], float3 normal){
	float4 finalOutput = 0;
	[unroll]
	for(int i = 0; i < 4; i++){
		KKVertexLight light = lights[i];
		float lighting = (saturate(dot(normal, light.dir)) * light.atten);
		lights[i].lightVal = lighting;
		float3 lightCol = lighting * light.col.rgb;
		finalOutput.rgb += lightCol;
		finalOutput.a += saturate(LumaGrayscale(lightCol));
	}
	finalOutput.rgb = max(0.0, finalOutput.rgb);
	return finalOutput;
}

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



float GetMeshSpecular(KKVertexLight vertexLights[4], float3 normal, float3 viewDir, float3 worldLightPos, out float3 specularColorMesh){
	float3 halfVector = normalize(viewDir + worldLightPos);
	float specularMesh = max(dot(halfVector, normal), 0.0);
	specularMesh = log2(specularMesh);
	float specularPowerMesh = _SpecularPower * 256;
	specularPowerMesh = specularPowerMesh * specularMesh;
	specularPowerMesh = saturate(exp2(specularPowerMesh) * _SpecularPower * _SpecularColor.a);
	specularMesh = exp2(specularMesh * 256) * 0.5;

	float3 specularColor = _UseLightColorSpecular ? _LightColor0.rgb * _SpecularColor.a: _SpecularColor.rgb * _SpecularColor.a;
	specularColorMesh = specularPowerMesh * specularColor;


//KK's specular is FUCKED lmao

#ifdef VERTEXLIGHT_ON
	[unroll]
	for(int i = 0; i < 4; i++){
		KKVertexLight light = vertexLights[i];
		float3 halfVector = normalize(viewDir + light.dir);
		float vertexLightSpecular = max(dot(halfVector, normal), 0.0);
		vertexLightSpecular = log2(vertexLightSpecular);
		float vertexSpecularPower = _SpecularPower * 256;
		vertexSpecularPower = vertexSpecularPower * vertexLightSpecular;
		vertexSpecularPower = saturate(exp2(vertexSpecularPower) * _SpecularPower * _SpecularColor.a);
		vertexLightSpecular = exp2(vertexLightSpecular * 256) * 0.5;

		float3 vertexSpecularColor = _UseLightColorSpecular ? light.col.rgb * _SpecularColor.a: _SpecularColor.rgb * _SpecularColor.a;
		vertexSpecularColor = vertexSpecularPower * vertexSpecularColor;

		specularColorMesh += vertexSpecularColor * light.lightVal;
		specularMesh += vertexLightSpecular * light.lightVal;

	}
#endif


	specularColorMesh = saturate(specularColorMesh);
	specularMesh = saturate(specularMesh);
	
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
    float lightShadows = GetLambert(worldLightPos, normal) + vertexLightingShadowAtten;
	float blendShadows = (max(lightShadows, shadowAttenuation)) * lightShadows;
	
	float2 rampUV = blendShadows * _RampG_ST.xy + _RampG_ST.zw;
	float ramp = tex2D(_RampG, rampUV).x;



    return ramp;

}



#endif