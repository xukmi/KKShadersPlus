#ifndef KKP_ITEMNORMAL_INC
#define KKP_ITEMNORMAL_INC

float3 GetNormal(Varyings i){	
	//Normals
	float2 detailNormalUV = i.uv0 * _NormalMapDetail_ST.xy + _NormalMapDetail_ST.zw;
	float4 packedNormalDetail = SAMPLE_TEX2D_SAMPLER(_NormalMapDetail, SAMPLERTEX, detailNormalUV);
	float3 detailNormal = UnpackScaleNormal(packedNormalDetail, _DetailNormalMapScale);
	float2 normalUV = i.uv0 * _NormalMap_ST.xy + _NormalMap_ST.zw;
	float4 packedNormal = SAMPLE_TEX2D_SAMPLER(_NormalMap, SAMPLERTEX, normalUV);
	float3 normalMap = UnpackScaleNormal(packedNormal, _NormalMapScale);
	float3 mergedNormals = BlendNormals(normalMap, detailNormal);
	return mergedNormals;
}

float3 CreateBinormal (float3 normal, float3 tangent, float binormalSign) {
	return cross(normal, tangent.xyz) *
		(binormalSign * unity_WorldTransformParams.w);
}

//KK uses VFACE to flip the normals, but that seems to break in reflection probes which is what messes up the lighting in mirrors
float3 NormalAdjust(Varyings i, float3 finalCombinedNormal, int faceDir){
	//Adjusting normals from tangent space
	float3 normal = finalCombinedNormal;

	float3 binormal = CreateBinormal(i.normalWS, i.tanWS.xyz, i.tanWS.w);
	normal = normalize(
		finalCombinedNormal.x * i.tanWS +
		finalCombinedNormal.y * binormal +
		finalCombinedNormal.z * i.normalWS
	);

	//This give some items correct shading on backfaces but messes up mirror shading
	int adjust = int(floor(_AdjustBackfaceNormals));
	return adjust ? normal * (faceDir <= 0 ? -1 : 1) : normal;
}

#endif