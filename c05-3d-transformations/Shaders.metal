#include <metal_stdlib>
using namespace metal;

vertex float4 vertex_main(constant packed_float3 *vertices [[buffer(0)]],
                          // do not use float3(simd_float3). becuase it is larger than three float array. it is 16 bytes
                          constant ushort *indices [[buffer(1)]], // why we can't use packed_uint16 ??
                          constant float* timer [[buffer(11)]],
                          uint vertexID [[vertex_id]])
{
    ushort index = indices[vertexID];
    float4 position = float4(vertices[index], 1);
    position.y += *timer;
    return position;
}

fragment float4 fragment_main()
{
    return float4(1.0, 1.0, 0.0, 1.0);
}

// For vertex descriptor
struct VertexIn
{
    float4 position [[attribute(0)]];
    float4 color [[attribute(1)]];
};

struct VertexOut
{
    float4 posistion [[position]];
    float4 color;
    float point_size [[point_size]];
};

vertex VertexOut vertex_descriptor_main(const VertexIn vertexIn [[stage_in]],
                                        constant float *timer [[buffer(11)]])
{
    VertexOut vertexOut;
    vertexOut.posistion = vertexIn.position;
    vertexOut.posistion.y += *timer;
    vertexOut.color = vertexIn.color;
    vertexOut.point_size = 30;
    
    return vertexOut;
}

fragment float4 fragment_descriptor_main(const VertexOut vertexOut [[stage_in]] )
{
    return vertexOut.color;
}
