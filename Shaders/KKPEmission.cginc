#ifndef KKP_EMISSION_INC
#define KKP_EMISSION_INC

sampler2D _EmissionMask;
float4 _EmissionMask_ST;
float4 _EmissionColor;
float _EmissionIntensity;


float4 GetEmission(float2 uv){
	float2 emissionUV = uv * _EmissionMask_ST.xy + _EmissionMask_ST.zw;
	float emissionMask = tex2D(_EmissionMask, emissionUV).r;
	float3 emissionCol =  _EmissionColor.rgb * _EmissionIntensity * emissionMask;
	return float4(emissionCol, emissionMask * _EmissionColor.a);
}

#endif