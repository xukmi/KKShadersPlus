// (?<=\s{3})1+(?=;$)

#ifndef KKP_DECLARATIONS
#define KKP_DECLARATIONS

#define DECLARE_TEX2D(tex) Texture2D tex; SamplerState sampler##tex
#define DECLARE_TEX2D_NOSAMPLER(tex) Texture2D tex

#define SAMPLE_TEX2D(tex,coord) tex.Sample (sampler##tex,coord)
#define SAMPLE_TEX2D_LOD(tex,coord,lod) tex.SampleLevel (sampler##tex,coord,lod)
#define SAMPLE_TEX2D_SAMPLER(tex,samplertex,coord) tex.Sample (sampler##samplertex,coord)
#define SAMPLE_TEX2D_SAMPLER_LOD(tex,samplertex,coord,lod) tex.SampleLevel (sampler##samplertex,coord,lod)

float _Saturation;

float3 applySaturation(float3 col, float saturation) {
	float average = col.r * 0.2126 + col.g * 0.7152 + col.b * 0.0722;
	float adjustment = (1 - saturation) * average;
	return col * saturation + adjustment;
}

#endif