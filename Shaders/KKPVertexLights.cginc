#ifndef KKP_VERTEX_LIGHTING_INC
#define KKP_VERTEX_LIGHTING_INC

// Vertex Lights
//Has nothing to do with vertex lighting
//This is using Unity's variables designated for single-pass multi-light lighting
struct KKVertexLight{
	float3 pos;
	float3 dir;
	float4 col;
	float atten;
	float lightVal;
};


void GetVertexLights(out KKVertexLight lights[4], float3 surfaceWorldPos){
	[unroll]
	for(int i = 0; i < 4; i++){
		KKVertexLight kLight;
		kLight.pos = float3(unity_4LightPosX0[i],
							unity_4LightPosY0[i],
							unity_4LightPosZ0[i]);
		float3 dir = kLight.pos - surfaceWorldPos;
		kLight.dir = normalize(dir);
		kLight.col = unity_LightColor[i];
		float distSqr = max(dot(dir, dir), 0.0001);
		kLight.atten = 1.0 / (1.0 + unity_4LightAtten0[i] * distSqr);
		lights[i] = kLight;
	}
}


float LumaGrayscale(float3 col){
	return col.r * 0.2126 + col.g * 0.7152 + col.b * 0.0722;
}

float4 GetVertexLighting(inout KKVertexLight lights[4], float3 normal){
	float4 finalOutput = 0;
	[unroll]
	for(int i = 0; i < 4; i++){
		KKVertexLight light = lights[i];
		float lighting = (saturate(dot(normal, light.dir)) * light.atten);
		lights[i].lightVal = lighting;
		float3 lightCol = lighting * light.col.rgb;
		finalOutput.rgb += lightCol;
		finalOutput.a += saturate(LumaGrayscale(lightCol));
	}
	finalOutput.rgb = max(0.0, finalOutput.rgb);
	return finalOutput;
}

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
		vertexLightSpecular = exp2(vertexLightSpecular * 256) * 0.5;

		float3 vertexSpecularColor = _UseLightColorSpecular ? light.col.rgb * _SpecularColor.a: light.lightVal * _SpecularColor.rgb * _SpecularColor.a;
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

		float specularMask = specularPower * specularPoint;
		specularMask = specularMask * vertexLightSpecular;
		specularMask = saturate(exp2(specularMask) * specularPower * _SpecularColor.a) * light.lightVal;

		float3 vertexSpecularColor = _UseLightColorSpecular ? light.col.rgb * _SpecularColor.a: light.lightVal * _SpecularColor.rgb * _SpecularColor.a;
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
		vertexSpecularColor = vertexSpecularPower * vertexSpecularColor * light.lightVal;
		
		specularMesh.rgb += vertexSpecularColor;
		specularMesh.a += LumaGrayscale(vertexSpecularColor);
	}
	return specularMesh;

}

#endif