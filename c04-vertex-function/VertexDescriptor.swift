//
//  VertexDescriptor.swift
//  c04-vertex-function
//
//  Created by user on 2023/01/23.
//

import MetalKit

extension MTLVertexDescriptor
{
    static let defaultBufferIndex = 0
    static let defaultColorIndex = 1
    static var defaultDescriptor: MTLVertexDescriptor
    {
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = MTLVertexDescriptor.defaultBufferIndex
        
        vertexDescriptor.attributes[1].format = .float3
        vertexDescriptor.attributes[1].offset = 0
        vertexDescriptor.attributes[1].bufferIndex = MTLVertexDescriptor.defaultColorIndex
        
        // layout index is same with bufferIndex in attribute.
        vertexDescriptor.layouts[MTLVertexDescriptor.defaultBufferIndex].stride = MemoryLayout<Float>.stride * 3
        vertexDescriptor.layouts[MTLVertexDescriptor.defaultColorIndex].stride = MemoryLayout<SIMD3<Float>>.stride
        
        return vertexDescriptor
    }
}
