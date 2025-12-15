#ifndef KKP_EMISSION_INC
#define KKP_EMISSION_INC

DECLARE_TEX2D(_EmissionMask);
float4 _EmissionMask_ST;
float4 _EmissionColor;
float _EmissionIntensity;
float _EmissionMaskMode;
float _EmissionKeepCol;

float4 GetEmission(float2 uv){
	float2 emissionUV = uv * _EmissionMask_ST.xy + _EmissionMask_ST.zw;
	float4 emissionMask = SAMPLE_TEX2D(_EmissionMask, emissionUV);
	float3 emissionCol = _EmissionColor.rgb * _EmissionIntensity * emissionMask.rgb;
	return float4(emissionCol, emissionMask.a * _EmissionColor.a);
}

float3 CombineEmission(float3 col, float4 emission) {
	col = max(col, 1E-06);
	float3 maskedEmission = col + lerp(0, col, emission) * emission.a;
	float3 overlayedEmission = col * (1 - emission.a * (1 - _EmissionKeepCol)) + (emission.a*emission.rgb);
	return maskedEmission * _EmissionMaskMode + overlayedEmission * (1 - _EmissionMaskMode);
}

#endif