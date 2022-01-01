#ifndef KKP_ITEMDIFFUSE_INC
#define KKP_ITEMDIFFUSE_INC


float3 ShadeAdjust(float3 col){
	float3 u_xlat1 = col;

	float4 u_xlat4;
	float4 u_xlat7;
	float4 u_xlat8;
	float3 u_xlat14;
	float u_xlat23;
	bool u_xlatb23;
	float u_xlat33;

	u_xlat4.z = float(-1.0);
	u_xlat4.w = float(0.666666687);
	u_xlat7.z = float(1.0);
	u_xlat7.w = float(-1.0);
	u_xlat8.xyw = u_xlat1.yzx * _ShadowColor.yzx;
	u_xlat4.xy = u_xlat8.yx;
	u_xlat7.xy = u_xlat1.yz * _ShadowColor.yz + (-u_xlat4.xy);
	u_xlatb23 = u_xlat4.y>=u_xlat8.y;
	u_xlat23 = u_xlatb23 ? 1.0 : float(0.0);
	u_xlat4 = (u_xlat23) * u_xlat7 + u_xlat4;
	u_xlat8.xyz = u_xlat4.xyw;
	u_xlatb23 = u_xlat8.w>=u_xlat8.x;
	u_xlat23 = u_xlatb23 ? 1.0 : float(0.0);
	u_xlat4.xyw = u_xlat8.wyx;
	u_xlat4 = u_xlat4 + (-u_xlat8);
	u_xlat4 = (u_xlat23) * u_xlat4 + u_xlat8;
	u_xlat23 = min(u_xlat4.y, u_xlat4.w);
	u_xlat23 = (-u_xlat23) + u_xlat4.x;
	u_xlat33 = u_xlat23 * 6.0 + 1.00000001e-10;
	u_xlat14.x = (-u_xlat4.y) + u_xlat4.w;
	u_xlat33 = u_xlat14.x / u_xlat33;
	u_xlat33 = u_xlat33 + u_xlat4.z;
	u_xlat4.x = u_xlat4.x + 1.00000001e-10;
	u_xlat23 = u_xlat23 / u_xlat4.x;
	u_xlat23 = u_xlat23 * 0.5;
	u_xlat4.xyz = abs((u_xlat33)) + float3(0.0, -0.333333343, 0.333333343);
	u_xlat4.xyz = frac(u_xlat4.xyz);
	u_xlat4.xyz = (-u_xlat4.xyz) * float3(2.0, 2.0, 2.0) + float3(1.0, 1.0, 1.0);
	u_xlat4.xyz = abs(u_xlat4.xyz) * float3(3.0, 3.0, 3.0) + float3(-1.0, -1.0, -1.0);
	u_xlat4.xyz = clamp(u_xlat4.xyz, 0.0, 1.0);
	u_xlat4.xyz = u_xlat4.xyz + float3(-1.0, -1.0, -1.0);
	u_xlat4.xyz = (u_xlat23) * u_xlat4.xyz + float3(1.0, 1.0, 1.0);

	return u_xlat4.xyz;
						
}

void AlphaClip(float2 uv, float texAlpha){
	//Body alpha mask from outfits
	float2 alphaUV = uv * _AlphaMask_ST.xy + _AlphaMask_ST.zw;
	float4 alphaMask = tex2D(_AlphaMask, alphaUV);
	float2 alphaVal = -float2(_alpha_a, _alpha_b) + float2(1.0f, 1.0f);
	alphaVal = max(alphaVal, alphaMask.xy);
	alphaVal = min(alphaVal.y, alphaVal.x);
	alphaVal = min(alphaVal, texAlpha);
	alphaVal.x -= 0.5f;
	float clipVal = alphaVal.x < 0.0f;
	if(clipVal * int(0xffffffffu) != 0)
		discard;
}
#endif