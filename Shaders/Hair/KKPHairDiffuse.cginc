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
	float4 colorMask = SAMPLE_TEX2D_SAMPLER(_ColorMask, SAMPLERTEX, uv * _ColorMask_ST.xy + _ColorMask_ST.zw);
	diffuse = colorMask.x * diffuse + 1;
	float3 color2 = _Color2.rgb - diffuse;
	diffuse = colorMask.y * color2 + diffuse; 
	float3 color3 = _Color3.rgb - diffuse;
	diffuse = colorMask.z * color3 + diffuse;
	return diffuse;
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

float AlphaClip(float2 uv, float mainTexAlpha){
	float2 alphaUV = uv * _AlphaMask_ST.xy + _AlphaMask_ST.zw;
	float4 alphaMask = SAMPLE_TEX2D_SAMPLER(_AlphaMask, SAMPLERTEX, alphaUV);
	float alphaVal = alphaMask.x * mainTexAlpha;
	float clipVal = (alphaVal.x - _Cutoff) < 0.0f;
	if(clipVal * int(0xffffffffu) != 0)
		discard;
	return alphaVal;
}
#endif