/// Copyright (c) 2022 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

#include <metal_stdlib>
using namespace metal;
#import "Common.h"

struct VertexIn
{
    float4 position [[attribute(Position)]];
    float3 normal [[attribute(Normal)]];
    float2 uv [[attribute(UV)]];
};

struct VertexOut
{
    float4 position [[position]];
    float3 normal;
    float2 uv;
};

vertex VertexOut vertex_main(const VertexIn in [[stage_in]],
                             constant Uniforms &uniforms [[buffer(UniformsBuffer)]],
                             texture2d<float> baseColorTexture [[texture(BaseColor)]])
{
    VertexOut out {
        .position = uniforms.projectionMatrix
                    * uniforms.viewMatrix
                    * uniforms.modelMatrix * in.position,
        .normal = in.normal,
        .uv = in.uv
    };
    return out;
}


float3 convertSRGBToLinear(float3 sRGB)
{
    float3 linearColor;
    
    for(uint16_t i = 0; i < 3; ++i)
    {
        if(sRGB[i] <= 0.04045)
        {
            linearColor[i] = sRGB[i] / 12.92;
        }
        else
        {
            linearColor[i] = pow((sRGB[i] + 0.055 / 1.055), 2.4);
        }
    }
        
    return linearColor;
}

float3 convertLinearToSRGB(float3 linearColor)
{
    float3 sRGB;
    
    for(uint16_t i = 0; i < 3; ++i)
    {
        if(linearColor[i] <= 0.0031308)
        {
            sRGB[i] = linearColor[i] * 12.92;
        }
        else
        {
            sRGB[i] = pow(linearColor[i], 1 / 2.4) - 0.055;
        }
    }
        
    return sRGB;
}

//float interpolation(float v0, float v1, float t) {
//  return (1 - t) * v0 + t * v1;
//}

fragment float4 fragment_main(VertexOut in [[stage_in]]
                              ,constant Params &params [[buffer(ParamsBuffer)]]
                              ,texture2d<float> baseColorTexture [[texture(BaseColor)]]
                              ,sampler textureSamplerDesc [[sampler(0)]]
                              )
{
//    constexpr sampler textureSampler;
    constexpr sampler textureSampler(
     filter::linear, // nearest, linear
     mip_filter::linear, // nearest, linear
      max_anisotropy(32),
      address::repeat); // repeat, mirrored_repeat, clamp_to_edge, clamp_to_zero
    
//    float2 uv = float2(in.uv.x * 200, in.uv.y * 20000);
    float2 uv = in.uv * 1;
//        float2 uv = in.uv * params.tiling;
//                                           * params.tiling)
    float3 color = baseColorTexture.sample(
                                        textureSampler
//                                        textureSamplerDesc
                                        ,uv
                                        ).rgb;
    
//    color = convertSRGBToLinear(color);
//    color = convertLinearToSRGB(color);
//    color = pow(color, 1.0/2.2);
    return float4(color, 1);
}
