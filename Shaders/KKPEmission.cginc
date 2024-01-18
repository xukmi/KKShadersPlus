#ifndef KKP_EMISSION_INC
#define KKP_EMISSION_INC

sampler2D _EmissionMask;
float4 _EmissionMask_ST;
float4 _EmissionColor;
#ifdef STUDIO_SHADER
	float _EmissionPower;
#else
	float _EmissionIntensity;
#endif


float4 GetEmission(float2 uv){
	float2 emissionUV = uv * _EmissionMask_ST.xy + _EmissionMask_ST.zw;
	float4 emissionMask = tex2D(_EmissionMask, emissionUV);
	#ifdef STUDIO_SHADER
		float3 emissionCol =  _EmissionColor.rgb * _EmissionPower * emissionMask.rgb;
	#else
		float3 emissionCol =  _EmissionColor.rgb * _EmissionIntensity * emissionMask.rgb;
	#endif
	return float4(emissionCol, emissionMask.a * _EmissionColor.a);
}

#endif