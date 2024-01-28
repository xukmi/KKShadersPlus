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

float3 ShadeAdjustItem(float3 col){
	float4 u_xlat0;
	float4 u_xlat1;
	float4 u_xlat2;
	float4 u_xlat3;
	float u_xlat11;
	float u_xlat30;
	bool u_xlatb30;

	u_xlat0.xyz = col;

	u_xlat1.xyw = u_xlat0.yzx * _ShadowColor.yzx;
	u_xlat2.xy = u_xlat1.yx;
	u_xlat3.xy = u_xlat0.yz * _ShadowColor.yz + (-u_xlat2.xy);
	u_xlatb30 = u_xlat2.y>=u_xlat1.y;
	u_xlat30 = u_xlatb30 ? 1.0 : float(0.0);
	u_xlat2.z = float(-1.0);
	u_xlat2.w = float(0.666666687);
	u_xlat3.z = float(1.0);
	u_xlat3.w = float(-1.0);
	u_xlat2 = (u_xlat30) * u_xlat3 + u_xlat2;
	u_xlatb30 = u_xlat1.w>=u_xlat2.x;
	u_xlat30 = u_xlatb30 ? 1.0 : float(0.0);
	u_xlat1.xyz = u_xlat2.xyw;
	u_xlat2.xyw = u_xlat1.wyx;
	u_xlat2 = (-u_xlat1) + u_xlat2;
	u_xlat1 = (u_xlat30) * u_xlat2 + u_xlat1;
	u_xlat30 = min(u_xlat1.y, u_xlat1.w);
	u_xlat30 = (-u_xlat30) + u_xlat1.x;
	u_xlat2.x = u_xlat30 * 6.0 + 1.00000001e-10;
	u_xlat11 = (-u_xlat1.y) + u_xlat1.w;
	u_xlat11 = u_xlat11 / u_xlat2.x;
	u_xlat11 = u_xlat11 + u_xlat1.z;
	u_xlat1.x = u_xlat1.x + 1.00000001e-10;
	u_xlat30 = u_xlat30 / u_xlat1.x;
	u_xlat30 = u_xlat30 * 0.5;
	u_xlat1.xyz = abs((u_xlat11)) + float3(0.0, -0.333333343, 0.333333343);
	u_xlat1.xyz = frac(u_xlat1.xyz);
	u_xlat1.xyz = (-u_xlat1.xyz) * float3(2.0, 2.0, 2.0) + float3(1.0, 1.0, 1.0);
	u_xlat1.xyz = abs(u_xlat1.xyz) * float3(3.0, 3.0, 3.0) + float3(-1.0, -1.0, -1.0);
	u_xlat1.xyz = clamp(u_xlat1.xyz, 0.0, 1.0);
	u_xlat1.xyz = u_xlat1.xyz + float3(-1.0, -1.0, -1.0);
	u_xlat1.xyz = (u_xlat30) * u_xlat1.xyz + float3(1.0, 1.0, 1.0);
	return u_xlat1.xyz;
}

float3 HUEtoRGB(in float H)
{
	float R = abs(H * 6 - 3) - 1;
	float G = 2 - abs(H * 6 - 2);
	float B = 2 - abs(H * 6 - 4);
	return saturate(float3(R,G,B));
}

float Epsilon = 1e-10;
float3 RGBtoHCV(in float3 RGB)
{
	// Based on work by Sam Hocevar and Emil Persson
	float4 P = (RGB.g < RGB.b) ? float4(RGB.bg, -1.0, 2.0/3.0) : float4(RGB.gb, 0.0, -1.0/3.0);
	float4 Q = (RGB.r < P.x) ? float4(P.xyw, RGB.r) : float4(RGB.r, P.yzx);
	float C = Q.x - min(Q.w, Q.y);
	float H = abs((Q.w - Q.y) / (6 * C + Epsilon) + Q.z);
	return float3(H, C, Q.x);
}

float3 RGBtoHSL(in float3 RGB)
{
	float3 HCV = RGBtoHCV(RGB);
	float L = HCV.z - HCV.y * 0.5;
	float S = HCV.y / (1 - abs(L * 2 - 1) + Epsilon);
	return float3(HCV.x, S, L);
}
float3 HSLtoRGB(in float3 HSL)
{
	float3 RGB = HUEtoRGB(HSL.x);
	float C = (1 - abs(2 * HSL.z - 1)) * HSL.y;
	return (RGB - 0.5) * C + HSL.z;
}

void AlphaClip(float2 uv, float texAlpha){
	//Body alpha mask from outfits
	float2 alphaUV = uv * _AlphaMask_ST.xy + _AlphaMask_ST.zw;
	float4 alphaMask = SAMPLE_TEX2D_SAMPLER(_AlphaMask, SAMPLERTEX, alphaUV);
	float2 alphaVal = -float2(_alpha_a, _alpha_b) + float2(1.0f, 1.0f);
	alphaVal = max(alphaVal, alphaMask.xy);
	alphaVal = min(alphaVal.y, alphaVal.x);
	alphaVal = min(alphaVal, texAlpha);
	alphaVal.x -= _Cutoff;
	float clipVal = alphaVal.x < 0.0f;
	if(clipVal * int(0xffffffffu) != 0 && _AlphaOptionCutoff)
		discard;
}
#endif