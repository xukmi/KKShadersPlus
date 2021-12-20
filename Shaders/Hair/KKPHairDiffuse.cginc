#ifndef KKP_HAIR_DIFFUSE_INC
#define KKP_HAIR_DIFFUSE_INC


void AmbientShadowAdjust(out float3 a){

	float4 u_xlat0;
	bool u_xlatb0;
	float4 u_xlat2;
	float4 u_xlat3;
	float2 u_xlat7;
	float u_xlat22;
	bool u_xlatb22;


	u_xlatb0 = _ambientshadowG.y>=_ambientshadowG.z;
	u_xlat0.x = u_xlatb0 ? 1.0 : (0.0);
	u_xlat2.xy = _ambientshadowG.yz;
	u_xlat2.z = (0.0);
	u_xlat2.w = (-0.333333343);
	u_xlat3.xy = _ambientshadowG.zy;
	u_xlat3.z = (-1.0);
	u_xlat3.w = (0.666666687);
	u_xlat2 = u_xlat2 + (-u_xlat3);
	u_xlat0 = u_xlat0.xxxx * u_xlat2.xywz + u_xlat3.xywz;
	u_xlatb22 = _ambientshadowG.x>=u_xlat0.x;
	u_xlat22 = u_xlatb22 ? 1.0 : (0.0);
	u_xlat2.z = u_xlat0.w;
	u_xlat0.w = _ambientshadowG.x;
	u_xlat2.xyw = u_xlat0.wyx;
	u_xlat2 = (-u_xlat0) + u_xlat2;
	u_xlat0 = (u_xlat22) * u_xlat2 + u_xlat0;
	u_xlat22 = min(u_xlat0.y, u_xlat0.w);
	u_xlat0.x = u_xlat0.x + (-u_xlat22);
	u_xlat0.x = u_xlat0.x * 6.0 + 1.00000001e-10;
	u_xlat7.x = (-u_xlat0.y) + u_xlat0.w;
	u_xlat0.x = u_xlat7.x / u_xlat0.x;
	u_xlat0.x = u_xlat0.x + u_xlat0.z;
	u_xlat0.xyz = abs(u_xlat0.xxx) + float3(0.0, -0.333333343, 0.333333343);
	u_xlat0.xyz = frac(u_xlat0.xyz);
	u_xlat0.xyz = (-u_xlat0.xyz) * float3(2.0, 2.0, 2.0) + float3(1.0, 1.0, 1.0);
	u_xlat0.xyz = abs(u_xlat0.xyz) * float3(3.0, 3.0, 3.0) + float3(-1.0, -1.0, -1.0);
	u_xlat0.xyz = clamp(u_xlat0.xyz, 0.0, 1.0);
	u_xlat0.xyz = u_xlat0.xyz * float3(0.330000013, 0.330000013, 0.330000013) + float3(0.330000013, 0.330000013, 0.330000013);
	a = u_xlat0.xyz;
}

float3 GetDiffuse(float2 uv){
	float3 diffuse = _Color.rgb - 1;
	float4 colorMask = tex2D(_ColorMask, uv * _ColorMask_ST.xy + _ColorMask_ST.zw);
	diffuse = colorMask.x * diffuse + 1;
	float3 color2 = _Color2.rgb - diffuse;
	diffuse = colorMask.y * color2 + diffuse; 
	float3 color3 = _Color3.rgb - diffuse;
	diffuse = colorMask.z * color3 + diffuse;
	return diffuse;
}

float AlphaClip(float2 uv, float mainTexAlpha){
	float2 alphaUV = uv * _AlphaMask_ST.xy + _AlphaMask_ST.zw;
	float4 alphaMask = tex2D(_AlphaMask, alphaUV);
	float alphaVal = alphaMask.x * mainTexAlpha;
	float clipVal = (alphaVal.x - 0.5) < 0.0f;
	if(clipVal * int(0xffffffffu) != 0)
		discard;
	return alphaVal;
}
#endif