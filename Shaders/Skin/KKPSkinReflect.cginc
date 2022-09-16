#ifndef KKP_SKIN_REFLECT
#define KKP_SKIN_REFLECT
			sampler2D _ReflectMap;
			sampler2D _ReflectionMapCap;
			float _Roughness;
			float _ReflectionVal;
			float _UseMatCapReflection;
			float _ReflBlendVal;
			float _ReflBlendSrc;
			float _ReflBlendDst;
			fixed4 reflectfrag (Varyings i) : SV_Target
			{
				AlphaClip(i.uv0, 1);
				float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.posWS);
				float3 normal = GetNormal(i);
				normal = NormalAdjust(i, normal);
				float reflectMap = tex2D(_ReflectMap, i.uv0).r;


				float3 reflectionDir = reflect(-viewDir, normal);
				float roughness = 1 - (_Roughness);
				roughness *= 1.7 - 0.7 * roughness;
				float4 envSample = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflectionDir, roughness * UNITY_SPECCUBE_LOD_STEPS);
				float3 env = DecodeHDR(envSample, unity_SpecCube0_HDR);

				float3 viewNormal = mul((float3x3)UNITY_MATRIX_V, normal);
				float2 matcapUV = viewNormal.xy * 0.5 + 0.5;

				float3 matcap = tex2D(_ReflectionMapCap, matcapUV).rgb;
				matcap = pow(matcap, 0.454545);
				env = lerp(matcap, env, _UseMatCapReflection);

				float reflectMulOrAdd = 1.0;
				float src = floor(_ReflBlendSrc);
				float dst = floor(_ReflBlendDst);
				//Add
				if(src == 1.0 && dst == 1.0){
					reflectMulOrAdd = 0.0;
				}
				//Mul
				else if(src == 2.0 && dst == 0.0){
					reflectMulOrAdd = 1.0;
				}
				else if(dst == 10.0 && (src == 1.0 || src == 5.0)){
					reflectMulOrAdd = 0.0;
				}
				else{
					reflectMulOrAdd = _ReflBlendVal;
				}

				//5, 10 is alpha blend
				env *= _ReflectionVal;

				float3 reflCol = lerp(env, reflectMulOrAdd, 1-_ReflectionVal*reflectMap);
			
				return float4(reflCol, reflectMap * _ReflectionVal);
			}

#endif