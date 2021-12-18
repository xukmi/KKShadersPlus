#ifndef KK_NORMAL_INC
#define KK_NORMAL_INC

float3 GetNormal(Varyings i){	
	//Normals
	float2 detailNormalUV = i.uv0 + _NormalMapDetail_ST.xy + _NormalMapDetail_ST.zw;
	float3 detailNormal = UnpackScaleNormal(tex2D(_NormalMapDetail, detailNormalUV), _DetailNormalMapScale);
	return detailNormal;
	float2 normalUV = i.uv0 + _NormalMap_ST.xy + _NormalMap_ST.zw;
	float3 normalMap = UnpackScaleNormal(tex2D(_NormalMap, normalUV), 1);
	float3 mergedNormals = BlendNormals(normalMap, detailNormal);
	return mergedNormals;
}

float3 NormalAdjust(Varyings i, int frontFace, float3 finalCombinedNormal){
	//Adjusting normals from tangent space
	float3 adjustedYNormal = finalCombinedNormal.y * i.bitanWS.xyz;
	float4 adjustedNormal = float4(finalCombinedNormal, 1);
	adjustedNormal.xyw = finalCombinedNormal.x * i.tanWS.xyz + adjustedYNormal;
	float faceVal = frontFace == true ? 1.0 : -1.0;
	float3 worldNormal = normalize(i.normalWS);
	worldNormal *= faceVal;
	adjustedNormal.xyz = adjustedNormal.z * worldNormal.xyz + adjustedNormal.xyw;
	float3 finalNormal = normalize(adjustedNormal.xyz);
	return finalNormal;
}

#endif