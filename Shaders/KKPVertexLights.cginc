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
	float lightValNoAtten;
};


void GetVertexLights(out KKVertexLight lights[4], float3 surfaceWorldPos) {
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

void GetVertexLightsTwo(out KKVertexLight lights[4], float3 surfaceWorldPos, float disablePointLights) {
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
		kLight.atten = (1.0 - disablePointLights) / (1.0 + unity_4LightAtten0[i] * distSqr);
		lights[i] = kLight;
	}
}


float LumaGrayscale(float3 col){
	return col.r * 0.2126 + col.g * 0.7152 + col.b * 0.0722;
}

float MaxGrayscale(float3 col){
	return max(col.r, max(col.g, col.b));
}


float4 GetVertexLighting(inout KKVertexLight lights[4], float3 normal){
	float4 finalOutput = 0;
	[unroll]
	for(int i = 0; i < 4; i++){
		KKVertexLight light = lights[i];
		float dotProduct = dot(normal, light.dir);
		float lighting = dotProduct * light.atten;
		lights[i].lightVal = saturate(lighting);
		lights[i].lightValNoAtten = saturate(dotProduct);
		float3 lightCol = lighting * light.col.rgb;
		finalOutput.rgb += lightCol;
		finalOutput.a += saturate(MaxGrayscale(lightCol));
	}
	finalOutput.rgb = clamp(finalOutput.rgb, 0.0, 1.0);
	return finalOutput;
}

float3 GetRampLighting(inout KKVertexLight lights[4], float3 normal, float ramp){
	float3 finalOutput = 0;
	[unroll]
	for(int i = 0; i < 4; i++){
		KKVertexLight light = lights[i];
	#ifdef KKP_EXPENSIVE_RAMP
		float lighting = light.lightValNoAtten;
		float2 lightRampUV = lighting * _RampG_ST.xy + _RampG_ST.zw;
		float lightRamp = tex2D(_RampG, lightRampUV).x;
		float atten = smoothstep(0.04, 0.041, light.atten); 
		lighting = saturate(lightRamp * atten);
	#else
		float lighting = light.lightValNoAtten;
		lighting = ramp * lighting;
	#endif
		float3 lightCol = lighting * light.col.rgb;
		finalOutput.rgb += lightCol;
	}
	finalOutput.rgb = max(0.0, finalOutput.rgb);
	return finalOutput;
}

#endif