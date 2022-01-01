#ifndef KKP_VERTEX_LIGHTING_SPECULAR_INC
#define KKP_VERTEX_LIGHTING_SPECULAR_INC

//Diffuse pass uses it slightly differently
float GetVertexSpecularDiffuse(KKVertexLight lights[4], float3 normal, float3 viewDir, float specularPower, inout float3 specularVertexMesh){
	float specularMesh = 0;
	[unroll]
	for(int i = 0; i < 4; i++){
		KKVertexLight light = lights[i];
		float3 halfVector = normalize(viewDir + light.dir);
		float vertexLightSpecular = max(dot(halfVector, normal), 0.0);
		vertexLightSpecular = log2(vertexLightSpecular);
		float vertexSpecularPower = specularPower * 256;
		vertexSpecularPower = vertexSpecularPower * vertexLightSpecular;
		vertexSpecularPower = saturate(exp2(vertexSpecularPower) * specularPower * _SpecularColor.a);
		vertexLightSpecular = exp2(vertexLightSpecular * 256) * 1;

		float3 vertexSpecularColor = _UseLightColorSpecular ? light.col.rgb * _SpecularColor.a: light.lightVal * _SpecularColor.rgb * _SpecularColor.a;
	#ifdef KKP_EXPENSIVE_RAMP
		float2 lightRampUV = vertexSpecularPower * _RampG_ST.xy + _RampG_ST.zw;
		vertexSpecularPower = tex2D(_RampG, lightRampUV) * _UseRampForSpecular + vertexSpecularPower * (1 - _UseRampForSpecular);
	#endif
		vertexSpecularColor = vertexSpecularPower * vertexSpecularColor;

		specularVertexMesh += vertexSpecularColor * light.lightVal;
		specularMesh += vertexLightSpecular * light.lightVal;
	}

	return specularMesh;

}

float4 GetVertexSpecularHair(KKVertexLight lights[4], float3 normal, float3 viewDir, float specularPoint, float specularPower){
	float4 specularMesh = 0;
	[unroll]
	for(int i = 0; i < 4; i++){
		KKVertexLight light = lights[i];
		float3 halfVector = normalize(viewDir + light.dir);
		float vertexLightSpecular = max(dot(halfVector, normal), 0.0);
		vertexLightSpecular = log2(vertexLightSpecular);
		float vertexSpecularPower = specularPower * 256;
		vertexSpecularPower = vertexSpecularPower * vertexLightSpecular;
		vertexSpecularPower = saturate(exp2(vertexSpecularPower) * specularPower * _SpecularColor.a);

		float specularMask = specularPoint;
		specularMask = specularMask * vertexLightSpecular;
		specularMask = saturate(exp2(specularMask) * _SpecularColor.a) * light.lightVal;

		float3 vertexSpecularColor = _UseLightColorSpecular ? light.col.rgb * _SpecularColor.a: light.lightVal * _SpecularColor.rgb * _SpecularColor.a;
	#ifdef KKP_EXPENSIVE_RAMP
		float2 lightRampUV = vertexSpecularPower * _RampG_ST.xy + _RampG_ST.zw;
		vertexSpecularPower = tex2D(_RampG, lightRampUV) * _UseRampForSpecular + vertexSpecularPower * (1 - _UseRampForSpecular);
	#endif
		vertexSpecularColor = vertexSpecularPower * vertexSpecularColor * light.lightVal;
		
		specularMesh.rgb += vertexSpecularColor;
		specularMesh.a += specularMask * light.lightVal * LumaGrayscale(light.col.rgb);
	}
	return specularMesh;

}

float4 GetVertexSpecular(KKVertexLight lights[4], float3 normal, float3 viewDir, float specularPoint, float specularPower){
	float4 specularMesh = 0;
	[unroll]
	for(int i = 0; i < 4; i++){
		KKVertexLight light = lights[i];
		float3 halfVector = normalize(viewDir + light.dir);
		float vertexLightSpecular = max(dot(halfVector, normal), 0.0);
		vertexLightSpecular = log2(vertexLightSpecular);
		float vertexSpecularPower = specularPower * specularPoint;
		vertexSpecularPower = vertexSpecularPower * vertexLightSpecular;
		vertexSpecularPower = saturate(exp2(vertexSpecularPower) * specularPower * _SpecularColor.a);

		float3 vertexSpecularColor = _UseLightColorSpecular ? light.col.rgb * _SpecularColor.a: light.lightVal * _SpecularColor.rgb * _SpecularColor.a;
	#ifdef KKP_EXPENSIVE_RAMP
		float2 lightRampUV = vertexSpecularPower * _RampG_ST.xy + _RampG_ST.zw;
		vertexSpecularPower = tex2D(_RampG, lightRampUV) * _UseRampForSpecular + vertexSpecularPower * (1 - _UseRampForSpecular);
	#endif
		vertexSpecularColor = vertexSpecularPower * vertexSpecularColor * light.lightVal;
		
		specularMesh.rgb += vertexSpecularColor;
		specularMesh.a += LumaGrayscale(vertexSpecularColor);
	}
	return specularMesh;

}

#endif