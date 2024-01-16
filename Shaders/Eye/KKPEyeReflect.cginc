#ifndef KKP_HAIR_REFLECT
#define KKP_HAIR_REFLECT
			sampler2D _ReflectMap;
			float4 _ReflectMap_ST;
			sampler2D _ReflectionMapCap;
			float4 _ReflectionMapCap_ST;
			float _Roughness;
			float _ReflectionVal;
			float _UseMatCapReflection;
			float _ReflBlendVal;
			float _ReflBlendSrc;
			float _ReflBlendDst;
			float4 _ReflectCol;
			float _ReflectColMix;
			
			float _ReflectRotation;
			sampler2D _ReflectMask;
			float4 _ReflectMask_ST;

		#ifndef ROTATEUV
			float2 rotateUV(float2 uv, float2 pivot, float rotation) {
			    float cosa = cos(rotation);
			    float sina = sin(rotation);
			    uv -= pivot;
			    return float2(
			        cosa * uv.x - sina * uv.y,
			        cosa * uv.y + sina * uv.x 
			    ) + pivot;
			}
		#endif

			fixed4 reflectfrag (Varyings i) : SV_Target
			{
				KKVertexLight vertexLights[4];
			#ifdef VERTEXLIGHT_ON
				GetVertexLightsTwo(vertexLights, i.posWS, _DisablePointLights);	
			#endif
				float4 vertexLighting = 0.0;
				float vertexLightRamp = 1.0;
			#ifdef VERTEXLIGHT_ON
				vertexLighting = GetVertexLighting(vertexLights, i.normalWS);
				float2 vertexLightRampUV = vertexLighting.a * _RampG_ST.xy + _RampG_ST.zw;
				vertexLightRamp = tex2D(_RampG, vertexLightRampUV).x;
				float3 rampLighting = GetRampLighting(vertexLights, i.normalWS, vertexLightRamp);
				vertexLighting.rgb = _UseRampForLights ? rampLighting : vertexLighting.rgb;
			#endif
				float lambert = max(dot(_WorldSpaceLightPos0.xyz, i.normalWS.xyz), 0.0) + vertexLighting.a;
				float shadowAttenuation = saturate(tex2D(_RampG, lambert * _RampG_ST.xy + _RampG_ST.zw).x);
				#ifdef SHADOWS_SCREEN
					float2 shadowMapUV = i.shadowCoordinate.xy / i.shadowCoordinate.ww;
					float4 shadowMap = tex2D(_ShadowMapTexture, shadowMapUV);
					shadowAttenuation *= shadowMap;
				#endif
				float matcapAttenuation = 1 - (1 - shadowAttenuation)*_DisableShadowedMatcap;
			
				//Reflection begins here
				float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.posWS);
				float3 normal = i.normalWS.xyz;
				float2 reflectMapUV = (i.uv0 *_ReflectMap_ST.xy + _ReflectMap_ST.zw);
			#ifdef MOVE_PUPILS
				reflectMapUV = rotateUV(reflectMapUV, float2(0.5, 0.5), -_rotation*6.28318548);
				reflectMapUV = reflectMapUV * _MainTex_ST.xy + _MainTex_ST.zw;
			#endif
				float reflectMap = tex2D(_ReflectMap, reflectMapUV).r;

				float3 reflectionDir = reflect(-viewDir, normal);
				float roughness = 1 - (_Roughness);
				roughness *= 1.7 - 0.7 * roughness;
				float4 envSample = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflectionDir, roughness * UNITY_SPECCUBE_LOD_STEPS);
				float3 env = DecodeHDR(envSample, unity_SpecCube0_HDR);

				float3 viewNormal = mul((float3x3)UNITY_MATRIX_V, normal);
				float2 matcapUV = viewNormal.xy * 0.5 * _ReflectionMapCap_ST.xy + 0.5 + _ReflectionMapCap_ST.zw;
				matcapUV = rotateUV(matcapUV, float2(0.5, 0.5), radians(_ReflectRotation));
				
				float2 reflectMaskUV = (i.uv0 *_ReflectMask_ST.xy + _ReflectMask_ST.zw);
			#ifdef MOVE_PUPILS
				reflectMaskUV = rotateUV(reflectMaskUV, float2(0.5, 0.5), -_rotation*6.28318548);
				reflectMaskUV = reflectMaskUV * _MainTex_ST.xy + _MainTex_ST.zw;
			#endif
				float reflectMask = tex2D(_ReflectMask, reflectMaskUV).r;
				
				float4 matcap = tex2D(_ReflectionMapCap, matcapUV);
				matcap = pow(matcap, 0.454545);
				float3 matcapRGBcolored = lerp(matcap.rgb, matcap.rgb * _ReflectCol.rgb, _ReflectColMix);
				env = lerp(env, matcapRGBcolored, _UseMatCapReflection * reflectMask);

				float alphaLerp = 1;
				float reflectMulOrAdd = 1.0;
				float src = floor(_ReflBlendSrc);
				float dst = floor(_ReflBlendDst);
				//Add
				if(src == 1.0 && dst == 1.0){
					reflectMulOrAdd = 0.0;
					alphaLerp = _ReflectCol.a;
				}
				//Mul
				else if(src == 2.0 && dst == 0.0){
					reflectMulOrAdd = 1.0;
					alphaLerp = _ReflectCol.a;
				}
				// Alpha Blend & Premultiplied Alpha
				else if(dst == 10.0 && (src == 5.0 || src == 1.0)){
					reflectMulOrAdd = 0.0;
					env *= _ReflectCol.a;
				}
				else {
					reflectMulOrAdd = _ReflBlendVal;
					alphaLerp = _ReflectCol.a;
				}
				
				env *= matcapAttenuation * matcap.a;

				float3 reflCol = lerp(env, reflectMulOrAdd, 1-_ReflectionVal * reflectMap * matcapAttenuation * matcap.a * alphaLerp);
			
				return float4(max(reflCol, 1E-06), _ReflectionVal * reflectMap * _ReflectCol.a);
			}

#endif