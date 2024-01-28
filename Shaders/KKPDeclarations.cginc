#ifndef KKP_DECLARATIONS
#define KKP_DECLARATIONS

#define DECLARE_TEX2D(tex) Texture2D tex; SamplerState sampler##tex
#define DECLARE_TEX2D_NOSAMPLER(tex) Texture2D tex

#define SAMPLE_TEX2D(tex,coord) tex.Sample (sampler##tex,coord)
#define SAMPLE_TEX2D_LOD(tex,coord,lod) tex.SampleLevel (sampler##tex,coord,lod)
#define SAMPLE_TEX2D_SAMPLER(tex,samplertex,coord) tex.Sample (sampler##samplertex,coord)
#define SAMPLE_TEX2D_SAMPLER_LOD(tex,samplertex,coord,lod) tex.SampleLevel (sampler##samplertex,coord,lod)

#endif