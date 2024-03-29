﻿#ifndef KKP_REFLECT_INC
#define KKP_REFLECT_INC

float _Reflective;
float _ReflectiveBlend;
float _ReflectiveMulOrAdd;

float _UseMatCapReflection;
sampler2D _ReflectionMapCap;

float3 GetBlendReflections(float3 diffuse, float3 normal, float3 viewDir, float metallicMap){
	float3 reflectionDir = reflect(-viewDir, normal);
	float roughness = 1 - (metallicMap * _Reflective);
	roughness *= 1.7 - 0.7 * roughness;
	float4 envSample = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflectionDir, roughness * UNITY_SPECCUBE_LOD_STEPS);
	float3 env = DecodeHDR(envSample, unity_SpecCube0_HDR) * _ReflectiveBlend;

	float3 viewNormal = mul((float3x3)UNITY_MATRIX_V, normal);
	float2 matcapUV = viewNormal.xy * 0.5 + 0.5;
	float3 matcap = tex2D(_ReflectionMapCap, matcapUV).rgb * _ReflectiveBlend;
	matcap = pow(matcap, 0.454545);
	env = lerp(env, matcap, _UseMatCapReflection);

	//Yes, this is dumb
	float3 envMul = env * diffuse;
	float3 envAdd = env + diffuse; 
	env = lerp(envMul, envAdd, _ReflectiveMulOrAdd);
	diffuse = lerp(diffuse, env, (metallicMap) * (1 - _UseKKMetal));
	return diffuse;
}

#endif