#ifndef KKP_REFLECT_INC
#define KKP_REFLECT_INC

float4 _ReflectCol;
float _ReflectColAlphaOpt;
float _ReflectColColorOpt;
float _DisableShadowedMatcap;

float _Reflective;
float _ReflectiveBlend;
float _ReflectiveMulOrAdd;

float _UseMatCapReflection;
sampler2D _ReflectionMapCap;

float _ReflectRotation;
sampler2D _ReflectMapDetail;
float4 _ReflectMapDetail_ST;

float2 rotateUV(float2 uv, float2 pivot, float rotation) {
	float cosa = cos(rotation);
	float sina = sin(rotation);
	uv -= pivot;
	return float2(
		cosa * uv.x - sina * uv.y,
		cosa * uv.y + sina * uv.x 
	) + pivot;
}

float3 GetBlendReflections(Varyings i, float3 diffuse, float3 normal, float3 viewDir, float metallicMap, float lightAmount = 1){
	float3 reflectionDir = reflect(-viewDir, normal);
	float roughness = 1 - (metallicMap * _Reflective);
	roughness *= 1.7 - 0.7 * roughness;
	float4 envSample = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflectionDir, roughness * UNITY_SPECCUBE_LOD_STEPS);
	float3 env = DecodeHDR(envSample, unity_SpecCube0_HDR) * _ReflectiveBlend;

	float3 viewNormal = mul((float3x3)UNITY_MATRIX_V, normal);
	float2 matcapUV = rotateUV(viewNormal.xy * 0.5 + 0.5, float2(0.5, 0.5), radians(_ReflectRotation));
	float reflectMask = tex2D(_ReflectMapDetail, (i.uv0 *_ReflectMapDetail_ST.xy) + _ReflectMapDetail_ST.zw).g;
	
	float4 matcap = tex2D(_ReflectionMapCap, matcapUV) * _ReflectiveBlend;
	matcap = pow(matcap, 0.454545);
	float3 matcapRGBcolored = lerp(matcap.rgb * _ReflectCol.rgb, lerp(matcap.rgb, _ReflectCol, 0.5), _ReflectColColorOpt);
	float3 matcapRGBalphacolored = lerp(lerp(1, matcapRGBcolored, _ReflectCol.a), lerp(matcap.rgb, matcapRGBcolored, _ReflectCol.a), _ReflectColAlphaOpt);
	env = lerp(env, matcapRGBalphacolored, _UseMatCapReflection * reflectMask);
	
	float matCapAttenuation = 1 - (1 - lightAmount) * _DisableShadowedMatcap;
	float reflectMap = tex2D(_ReflectMapDetail, (i.uv0 *_ReflectMapDetail_ST.xy) + _ReflectMapDetail_ST.zw).r;

	//Yes, this is dumb
	float3 envMul = env * diffuse;
	float3 envAdd = env + diffuse; 
	env = lerp(envMul, envAdd, _ReflectiveMulOrAdd);
	diffuse = lerp(diffuse, env, (metallicMap) * (1 - _UseKKMetal) * matCapAttenuation * reflectMap);
	return diffuse;
}

#endif