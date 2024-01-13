#ifndef KKP_DIFFUSE_INC
#define KKP_DIFFUSE_INC

//Some color adjustment for shading
void MapValuesMain(float3 col, out float3 a, out float3 b){
	float3 u_xlat0 = col;
	bool u_xlatb0;
	float4 u_xlat1;
	float4 u_xlat2;
	float u_xlat11;
	float u_xlat30;
	bool u_xlatb30;

	u_xlatb30 = u_xlat0.y>=u_xlat0.z;
	u_xlat30 = u_xlatb30 ? 1.0 : float(0.0);
	u_xlat1.xy = u_xlat0.zy;
	u_xlat2.xy = u_xlat0.yz + (-u_xlat1.xy);	
	u_xlat1.z = float(-1.0);
	u_xlat1.w = float(0.666666687);
	u_xlat2.z = float(1.0);
	u_xlat2.w = float(-1.0);
	u_xlat1 = float4(u_xlat30, u_xlat30, u_xlat30, u_xlat30) * u_xlat2.xywz + u_xlat1.xywz;
	u_xlatb30 = u_xlat0.x>=u_xlat1.x;
	u_xlat30 = u_xlatb30 ? 1.0 : float(0.0);
	u_xlat2.z = u_xlat1.w;
	u_xlat1.w = u_xlat0.x;
	u_xlat2.xyw = u_xlat1.wyx;
	u_xlat2 = (-u_xlat1) + u_xlat2;
	u_xlat1 = float4(u_xlat30, u_xlat30, u_xlat30, u_xlat30) * u_xlat2 + u_xlat1;
	u_xlat30 = min(u_xlat1.y, u_xlat1.w);
	u_xlat30 = (-u_xlat30) + u_xlat1.x;
	u_xlat2.x = u_xlat30 * 6.0 + 1.00000001e-10;
	u_xlat11 = (-u_xlat1.y) + u_xlat1.w;
	u_xlat11 = u_xlat11 / u_xlat2.x;
	u_xlat11 = u_xlat11 + u_xlat1.z;
	u_xlat1.x = u_xlat1.x + 1.00000001e-10;
	u_xlat30 = u_xlat30 / u_xlat1.x;
	u_xlat30 = u_xlat30 * 0.660000026;
	u_xlat1.xzw = abs(float3(u_xlat11, u_xlat11, u_xlat11)) + float3(-0.0799999982, -0.413333356, 0.25333333);
	u_xlat2.xyz = abs(float3(u_xlat11, u_xlat11, u_xlat11)) + float3(0.0, -0.333333343, 0.333333343);
	u_xlat2.xyz = frac(u_xlat2.xyz);
	u_xlat2.xyz = (-u_xlat2.xyz) * float3(2.0, 2.0, 2.0) + float3(1.0, 1.0, 1.0);
	u_xlat2.xyz = abs(u_xlat2.xyz) * float3(3.0, 3.0, 3.0) + float3(-1.0, -1.0, -1.0);
	u_xlat2.xyz = clamp(u_xlat2.xyz, 0.0, 1.0);
	u_xlat2.xyz = u_xlat2.xyz + float3(-1.0, -1.0, -1.0);
	u_xlat2.xyz = float3(u_xlat30, u_xlat30, u_xlat30) * u_xlat2.xyz + float3(1.0, 1.0, 1.0);
	u_xlat1.xyz = frac(u_xlat1.xzw);
	u_xlat1.xyz = (-u_xlat1.xyz) * float3(2.0, 2.0, 2.0) + float3(1.0, 1.0, 1.0);
	u_xlat1.xyz = abs(u_xlat1.xyz) * float3(3.0, 3.0, 3.0) + float3(-1.0, -1.0, -1.0);
	u_xlat1.xyz = clamp(u_xlat1.xyz, 0.0, 1.0);
	u_xlat1.xyz = u_xlat1.xyz + float3(-1.0, -1.0, -1.0);
	u_xlat1.xyz = u_xlat1.xyz * float3(0.400000006, 0.400000006, 0.400000006) + float3(1.0, 1.0, 1.0);
	u_xlat1.xyz = u_xlat1.xyz * float3(0.970000029, 0.970000029, 0.970000029) + float3(-1.0, -1.0, -1.0);
	a = u_xlat1.xyz;
	b = u_xlat2.xyz;
}

void MapValuesOutline(float3 col, out float3 a){
	float3 u_xlat0 = col;
	bool u_xlatb18;
	float4 u_xlat1;
	float4 u_xlat2;
	float u_xlat18;
	float u_xlat7;
	u_xlatb18 = u_xlat0.y>=u_xlat0.z;
	u_xlat18 = u_xlatb18 ? 1.0 : float(0.0);
	u_xlat1.xy = u_xlat0.zy;
	u_xlat2.xy = u_xlat0.yz + (-u_xlat1.xy);
	u_xlat1.z = float(-1.0);
	u_xlat1.w = float(0.666666687);
	u_xlat2.z = float(1.0);
	u_xlat2.w = float(-1.0);
	u_xlat1 = (u_xlat18) * u_xlat2.xywz + u_xlat1.xywz;
	u_xlatb18 = u_xlat0.x>=u_xlat1.x;
	u_xlat18 = u_xlatb18 ? 1.0 : float(0.0);
	u_xlat2.z = u_xlat1.w;
	u_xlat1.w = u_xlat0.x;
	u_xlat0.xyz = u_xlat0.xyz * _LineColorG.xyz;
	u_xlat2.xyw = u_xlat1.wyx;
	u_xlat2 = (-u_xlat1) + u_xlat2;
	u_xlat1 = (u_xlat18) * u_xlat2 + u_xlat1;
	u_xlat18 = min(u_xlat1.y, u_xlat1.w);
	u_xlat18 = (-u_xlat18) + u_xlat1.x;
	u_xlat2.x = u_xlat18 * 6.0 + 1.00000001e-10;
	u_xlat7 = (-u_xlat1.y) + u_xlat1.w;
	u_xlat7 = u_xlat7 / u_xlat2.x;
	u_xlat7 = u_xlat7 + u_xlat1.z;
	u_xlat1.x = u_xlat1.x + 1.00000001e-10;
	u_xlat18 = u_xlat18 / u_xlat1.x;
	u_xlat18 = u_xlat18 * 0.660000026;
	u_xlat1.xyz = abs((u_xlat7)) + float3(0.0, -0.333333343, 0.333333343);
	u_xlat1.xyz = frac(u_xlat1.xyz);
	u_xlat1.xyz = (-u_xlat1.xyz) * float3(2.0, 2.0, 2.0) + float3(1.0, 1.0, 1.0);
	u_xlat1.xyz = abs(u_xlat1.xyz) * float3(3.0, 3.0, 3.0) + float3(-1.0, -1.0, -1.0);
	u_xlat1.xyz = clamp(u_xlat1.xyz, 0.0, 1.0);
	u_xlat1.xyz = u_xlat1.xyz + float3(-1.0, -1.0, -1.0);
	u_xlat1.xyz = (u_xlat18) * u_xlat1.xyz + float3(1.0, 1.0, 1.0);
	a = u_xlat1.xyz;
}

void AlphaClip(float2 uv, bool outline){
	//Body alpha mask from outfits
	float2 alphaUV = uv * _AlphaMask_ST.xy + _AlphaMask_ST.zw;
	float4 alphaMask = UNITY_SAMPLE_TEX2D_SAMPLER(_AlphaMask, _MainTex, alphaUV);
	float2 alphaVal = -float2(_alpha_a, _alpha_b) + float2(1.0f, 1.0f);
	alphaVal = max(alphaVal, alphaMask.xy);
	alphaVal = min(alphaVal.y, alphaVal.x) * outline;
	alphaVal.x -= 0.5f;
	float clipVal = alphaVal.x < 0.0f;
	if(clipVal * int(0xffffffffu) != 0)
		discard;
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

//Anything affected by lighting
float3 GetDiffuse(Varyings i){
	//Nipple params
	float2 boobUV = i.uv1 - 0.5f;
	float uvLength = saturate(length(boobUV) * 16.6666698 + -1.0);
	float2 nippleScale = _nipsize * float2(-1.39999998, 0.699999988) + float2(2.0, -0.5);
	float2 nippleUV = i.uv1 *  nippleScale.xx + nippleScale.yy;
	nippleUV -= i.uv1;
	float2 nippleUV2 = uvLength * nippleUV + i.uv1;
	float2 nippleMaskUV = i.uv1 * i.color.xx;
	nippleUV2 = nippleUV2 * i.color.xx - nippleMaskUV;

	//Nipple for body, lipstick for face 
	float2 overtex1UV = _nip * nippleUV2 + nippleMaskUV;
	overtex1UV = overtex1UV * _overtex1_ST.xy + _overtex1_ST.zw;
	float4 overTex1 = UNITY_SAMPLE_TEX2D_SAMPLER(_overtex1, _MainTex, overtex1UV);
	float nipSpec = overTex1.y * _nip_specular;
	float3 overTex1Spec = nipSpec * float3(0.330000013, 0.330000013, 0.330000013) + _overcolor1.xyz;
	float4 overTex1Col = overTex1 * _overcolor1;
	overTex1.rgb = overTex1.x * overTex1Spec - overTex1Col.rgb;
	float mask = saturate(_tex1mask);
	overTex1.rgb = mask * overTex1.rgb + overTex1Col;

	//Maintex and blend overTex1
	float2 mainTexUV = i.uv0 * _MainTex_ST.xy + _MainTex_ST.zw;
	float4 mainTex = UNITY_SAMPLE_TEX2D(_MainTex, mainTexUV);
	overTex1.rgb -= mainTex.rgb;
	overTex1.rgb = overTex1Col.a * overTex1.rgb + mainTex.rgb;

	//Pubes for body, blush for face
	float2 overTex2UV = i.uv2 * i.color.b;
	overTex2UV = overTex2UV * _overtex2_ST.xy + _overtex2_ST.zw;
	float4 overTex2 = UNITY_SAMPLE_TEX2D_SAMPLER(_overtex2, _MainTex, overTex2UV); 
	overTex2.rgb = _overcolor2.rgb * overTex2.rgb - overTex1.rgb;
	float overTex2Blend = overTex2.a * _overcolor2.a;
	overTex1.rgb = overTex2Blend * overTex2.rgb + overTex1.rgb;

	//Eyeshadow for face, seems to just be another nipple for the body
	float2 overTex3UV = i.uv3 * _overtex3_ST.xy + _overtex3_ST.zw;
	float4 overTex3 = UNITY_SAMPLE_TEX2D_SAMPLER(_overtex3, _MainTex, overTex3UV);
	overTex3.rgb = overTex3.rgb * _overcolor3.rgb - overTex1.rgb;
	float overTex3Blend = overTex3.a * _overcolor3.a;
	overTex1.rgb = overTex3Blend * overTex3.rgb + overTex1.rgb;

	return overTex1.rgb;
}

#endif