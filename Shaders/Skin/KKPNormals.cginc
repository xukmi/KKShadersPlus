#ifndef KKP_NORMAL_INC
#define KKP_NORMAL_INC

float3 GetNormal(Varyings i){	
	//Normals
	float2 detailNormalUV = i.uv0 + _NormalMapDetail_ST.xy + _NormalMapDetail_ST.zw;
	float3 detailNormal = UnpackScaleNormal(tex2D(_NormalMapDetail, detailNormalUV), _DetailNormalMapScale);
	float2 normalUV = i.uv0 + _NormalMap_ST.xy + _NormalMap_ST.zw;
	float3 normalMap = UnpackScaleNormal(tex2D(_NormalMap, normalUV), _NormalMapScale);
	float3 mergedNormals = BlendNormals(normalMap, detailNormal);
	return mergedNormals;
}

float3 NormalAdjust(Varyings i, float3 finalCombinedNormal){

	float3 normal = finalCombinedNormal;

    float3 tspace0 = float3(i.tanWS.x, i.bitanWS.x, i.normalWS.x);
	float3 tspace1 = float3(i.tanWS.y, i.bitanWS.y, i.normalWS.y);
    float3 tspace2 = float3(i.tanWS.z, i.bitanWS.z, i.normalWS.z);
	
	float3 adjustedNormal;
    adjustedNormal.x = dot(tspace0, normal);
    adjustedNormal.y = dot(tspace1, normal);
    adjustedNormal.z = dot(tspace2, normal);

	return adjustedNormal;
}

#endif