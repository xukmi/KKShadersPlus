#ifndef KKP_ITEMNORMAL_INC
#define KKP_ITEMNORMAL_INC

float3 GetNormal(Varyings i){	
	//Normals
	float2 normalUV = i.uv0 + _NormalMap_ST.xy + _NormalMap_ST.zw;
	float3 normalMap = UnpackScaleNormal(tex2D(_NormalMap, normalUV), 1);
	return normalMap;
}

//KK uses VFACE to flip the normals, but that seems to break in reflection probes which is what messes up the lighting in mirrors
float3 NormalAdjust(Varyings i, float3 finalCombinedNormal, int faceDir){
	//Adjusting normals from tangent space
	float3 normal = finalCombinedNormal;

    float3 tspace0 = float3(i.tanWS.x, i.bitanWS.x, i.normalWS.x);
	float3 tspace1 = float3(i.tanWS.y, i.bitanWS.y, i.normalWS.y);
    float3 tspace2 = float3(i.tanWS.z, i.bitanWS.z, i.normalWS.z);
	
	float3 adjustedNormal;
    adjustedNormal.x = dot(tspace0, normal);
    adjustedNormal.y = dot(tspace1, normal);
    adjustedNormal.z = dot(tspace2, normal);


	//This give some items correct shading on backfaces but messes up mirror shading
	//adjustedNormal.z *= faceDir <= 0 ? -1 : 1;

	return normalize(adjustedNormal);
}

#endif