#ifndef KKP_DISPLACE_INC
#define KKP_DISPLACE_INC

sampler2D _DisplaceTex;
float4 _DisplaceTex_ST;
float4 _DisplaceTex_TexelSize;
float _DisplaceMultiplier;
float _DisplaceNormalMultiplier;
float _DisplaceFull;

#ifndef DEFINED_CLOCK
#define DEFINED_CLOCK
float4 _Clock;
#endif

float DisplaceVal(float2 uv, float2 offset, float2 texelSize){
	float4 displaceTex = tex2Dlod(_DisplaceTex, float4(uv, 0, 0) + float4(texelSize * offset, 0, 0));
	float displaceVal = displaceTex.r;
	//Gamma correction
	displaceVal = pow(displaceVal, 0.454545);
	displaceVal = (displaceVal - 0.5) * 2.0 * displaceTex.a;
	displaceVal += _DisplaceFull;

	//Can animate via rendereditor since _Clock is an exposed variable
	float displacementAnimation = _Clock.w;
	return displaceVal * displacementAnimation;
}

float3 normalsFromHeight(sampler2D heightTex, float2 uv, float2 texelSize)
{
    float4 h;
	h[0] = DisplaceVal(uv, float2( 0,-1), texelSize);
    h[1] = DisplaceVal(uv, float2( -1,0), texelSize);
    h[2] = DisplaceVal(uv, float2( 1,0), texelSize);
    h[3] = DisplaceVal(uv, float2( 0,1), texelSize);
	h *= _DisplaceMultiplier * _DisplaceNormalMultiplier;
    float3 n;
    n.z = h[3] - h[0];
    n.x = h[2] - h[1];
    n.y = 2;
    return normalize(n);
}




void DisplacementValues(VertexData v, inout float4 vertex, inout float3 normal){
	float3 displace = DisplaceVal(v.uv0 * _DisplaceTex_ST.xy + _DisplaceTex_ST.zw, 0, 0);
#ifndef SHADOW_CASTER_PASS
	float3 bumpnormal = normalsFromHeight(_DisplaceTex, v.uv0 * _DisplaceTex_ST.xy + _DisplaceTex_ST.zw, _DisplaceTex_TexelSize.xy);
	bumpnormal.xyz = bumpnormal.xzy;
	float3 mergedNormals = BlendNormals(normal, bumpnormal);
	normal = mergedNormals;
#endif
	vertex.xyz += displace * v.normal * _DisplaceMultiplier * 0.01;
}

#endif