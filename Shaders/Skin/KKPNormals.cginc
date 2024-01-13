#ifndef KKP_NORMAL_INC
#define KKP_NORMAL_INC

float3 GetNormal(Varyings i){	
	//Normals
	float2 detailNormalUV = i.uv0 * _NormalMapDetail_ST.xy + _NormalMapDetail_ST.zw;
	float3 detailNormal = UnpackScaleNormal(UNITY_SAMPLE_TEX2D_SAMPLER(_NormalMapDetail, _MainTex, detailNormalUV), _DetailNormalMapScale);
	float2 normalUV = i.uv0 * _NormalMap_ST.xy + _NormalMap_ST.zw;
	float3 normalMap = UnpackScaleNormal(UNITY_SAMPLE_TEX2D_SAMPLER(_NormalMap, _MainTex, normalUV), _NormalMapScale);
	float3 mergedNormals = BlendNormals(normalMap, detailNormal);
	return mergedNormals;
}

float3 CreateBinormal (float3 normal, float3 tangent, float binormalSign) {
	return cross(normal, tangent.xyz) *
		(binormalSign * unity_WorldTransformParams.w);
}

float3 NormalAdjust(Varyings i, float3 finalCombinedNormal, int faceDir = 0){
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