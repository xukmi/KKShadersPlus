// modified version of https://github.com/UnityCommunity/UnityLibrary/blob/master/Assets/Shaders/2D/Effects/WireFrame.shader

Shader "xukmi/Debug/WireframeTess"
{
	Properties
	{
		[Gamma]_LineColor ("LineColor", Color) = (1,1,1,1)
		[Gamma]_FillColor ("FillColor", Color) = (0,0,0,0)
		_WireThickness ("Wire Thickness", Range(0, 1)) = 0.5
		[MaterialToggle] _UseDiscard("Discard Fill", Float) = 1
		_TessTex ("Tess Tex", 2D) = "white" {}
		_TessMax("Tess Max", Range(1, 25)) = 12
		_TessMin("Tess Min", Range(1, 25)) = 1
		_TessBias("Tess Distance Bias", Range(1, 100)) = 75
		_TessSmooth("Tess Smooth", Range(0, 1)) = 0
		_Tolerance("Tolerance", Range(0.0, 0.05)) = 0.0005
		_DisplaceTex("DisplacementTex", 2D) = "gray" {}
		_DisplaceMultiplier("DisplaceMultiplier", float) = 0
		_DisplaceNormalMultiplier("DisplaceNormalMultiplier", float) = 1
		_ShrinkVal("ShrinkVal", Range(0, 1)) = 1
		_ShrinkVerticalAdjust("Vertical Pos", Float) = 0
		_Clock ("W is for displacement multiplier for animation", Vector) = (0,0,0,1)
 }

	SubShader
	{
		Tags { "RenderType"="Opaque" }

		Cull Off
		Pass
		{

			CGPROGRAM
			#pragma target 5.0
			#pragma hull hull
			#pragma domain domain
			#pragma vertex TessVert
			#pragma geometry geom
			#pragma fragment frag
			#include "UnityCG.cginc"

			float _WireThickness;
			bool _UseDiscard;
			sampler2D _DisplaceTex;
			float4 _DisplaceTex_ST;
			float4 _DisplaceTex_TexelSize;
			float _DisplaceMultiplier;
			float _DisplaceNormalMultiplier;

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv0 : TEXCOORD0;
			};

			struct v2g
			{
				float4 projectionSpaceVertex : SV_POSITION;
				float4 worldSpacePosition : TEXCOORD1;
			};

			struct g2f
			{
				float4 projectionSpaceVertex : SV_POSITION;
				float4 worldSpacePosition : TEXCOORD0;
				float4 dist : TEXCOORD1;
			};

			
			v2g vert (appdata v)
			{
				v2g o;
				float4 displaceTex = tex2Dlod(_DisplaceTex, float4(v.uv0, 0, 0));
				float displaceVal = displaceTex.r;
				//Gamma correction
				displaceVal = pow(displaceVal, 0.454545);
				displaceVal = (displaceVal - 0.5) * 2.0 * displaceTex.a;
				v.vertex.xyz += displaceVal * v.normal * _DisplaceMultiplier * 0.01;
				o.projectionSpaceVertex = UnityObjectToClipPos(v.vertex);
				o.worldSpacePosition = mul(unity_ObjectToWorld, v.vertex);
				return o;
			}
			
			#include "TessDebug.cginc"

			[maxvertexcount(3)]
			void geom(triangle v2g i[3], inout TriangleStream<g2f> triangleStream)
			{
				float2 p0 = i[0].projectionSpaceVertex.xy / i[0].projectionSpaceVertex.w;
				float2 p1 = i[1].projectionSpaceVertex.xy / i[1].projectionSpaceVertex.w;
				float2 p2 = i[2].projectionSpaceVertex.xy / i[2].projectionSpaceVertex.w;

				float2 edge0 = p2 - p1;
				float2 edge1 = p2 - p0;
				float2 edge2 = p1 - p0;

				// To find the distance to the opposite edge, we take the
				// formula for finding the area of a triangle Area = Base/2 * Height, 
				// and solve for the Height = (Area * 2)/Base.
				// We can get the area of a triangle by taking its cross product
				// divided by 2.  However we can avoid dividing our area/base by 2
				// since our cross product will already be double our area.
				float area = abs(edge1.x * edge2.y - edge1.y * edge2.x);
				float wireThickness = 1 - _WireThickness;
				wireThickness *= 1000;
				g2f o;
				o.worldSpacePosition = i[0].worldSpacePosition;
				o.projectionSpaceVertex = i[0].projectionSpaceVertex;
				o.dist.xyz = float3( (area / length(edge0)), 0.0, 0.0) * o.projectionSpaceVertex.w * wireThickness;
				o.dist.w = 1.0 / o.projectionSpaceVertex.w;
				triangleStream.Append(o);

				o.worldSpacePosition = i[1].worldSpacePosition;
				o.projectionSpaceVertex = i[1].projectionSpaceVertex;
				o.dist.xyz = float3(0.0, (area / length(edge1)), 0.0) * o.projectionSpaceVertex.w * wireThickness;
				o.dist.w = 1.0 / o.projectionSpaceVertex.w;
				triangleStream.Append(o);

				o.worldSpacePosition = i[2].worldSpacePosition;
				o.projectionSpaceVertex = i[2].projectionSpaceVertex;
				o.dist.xyz = float3(0.0, 0.0, (area / length(edge2))) * o.projectionSpaceVertex.w * wireThickness;
				o.dist.w = 1.0 / o.projectionSpaceVertex.w;
				triangleStream.Append(o);
			}

			uniform fixed4 _LineColor;
			uniform fixed4 _FillColor;

			fixed4 frag (g2f i) : SV_Target
			{
				float minDistanceToEdge = min(i.dist[0], min(i.dist[1], i.dist[2])) * i.dist[3];

				// Early out if we know we are not on a line segment.
				if(minDistanceToEdge > 0.9)
				{
				    if(_UseDiscard)
						discard;
					else
						return _FillColor;

				}

				return _LineColor;
			}
			ENDCG
		}
	}
}