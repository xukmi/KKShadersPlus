#ifndef KK_COOM_INC
#define KK_COOM_INC

void GetCumVals(float2 uv, out float mask, out float3 normal){
	float2 liquidUV = uv * _LiquidTiling.zw + _LiquidTiling.xy;
	float2 liquidUV2 = liquidUV * _Texture3_ST.xy + _Texture3_ST.zw;
	liquidUV = liquidUV * _Texture2_ST.xy + _Texture2_ST.zw;
	float4 liquidTex = tex2D(_Texture2, liquidUV);
	float liquidValTop = max(saturate(_liquidftop - 1.0) * liquidTex.y,
						  saturate(_liquidftop) * liquidTex.x);
	float2 liquidMaskUV = uv * _liquidmask_ST.xy + _liquidmask_ST.zw;
	float4 liquidMaskTex = tex2D(_liquidmask, liquidMaskUV);
	float3 liquidMaskVals = max(liquidMaskTex.zzy, liquidMaskTex.yxx);
	liquidMaskVals = liquidMaskTex.rgb - liquidMaskVals;
	liquidMaskTex.xy = min(liquidMaskTex.yz, liquidMaskTex.xy);
	liquidMaskTex.xy = liquidMaskTex.xy * float2(1.11111104, 1.11111104) + float2(-0.111111097, -0.111111097);
	liquidValTop = min(liquidValTop, liquidMaskVals.x);
	float4 liquidInputVals = float4(_liquidfbot, _liquidbtop, _liquidbbot, _liquidface) + float4(-1.0, -1.0, -1.0, -1.0);
	liquidInputVals = saturate(liquidInputVals) * liquidTex.y;
	float4 liquidInputVals2 = float4(_liquidfbot, _liquidbtop, _liquidbbot, _liquidface);
	liquidInputVals2 = saturate(liquidInputVals2) * liquidTex.x;
	float4 liquidValBot = max(liquidInputVals, liquidInputVals2);
	float2 liquidBackFLegs = min(liquidMaskVals.yz, liquidValBot.xy);
	float2 liquidButtBLegs = min(liquidMaskTex.xy, liquidValBot.zw);
	float liquidFinalMask = max(liquidValTop, liquidBackFLegs.x);
	liquidFinalMask = max(liquidFinalMask, liquidBackFLegs.y);
	liquidFinalMask = max(liquidFinalMask, liquidButtBLegs.x);
	liquidFinalMask = max(liquidFinalMask, liquidButtBLegs.y);

	//Normal
	float3 liquidNormal = UnpackNormal(tex2D(_Texture3, liquidUV2));

	mask = liquidFinalMask;
	normal = liquidNormal;
}

#endif