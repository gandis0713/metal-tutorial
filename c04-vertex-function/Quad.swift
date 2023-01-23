//
//  Quad.swift
//  c04-vertex-function
//
//  Created by user on 2023/01/23.
//

import MetalKit

struct Quad
{
    var vertices: [Float] = [
      -1,  1,  0,
       1,  1,  0,
      -1, -1,  0,
       1, -1,  0
    ]
    
    var indices: [UInt16] = [
        0, 3, 2,
        0, 1, 3
    ]
    
    var colors: [simd_float3] = [ // simd_float3 ???? is same with SIMD3<Float>
      [1, 0, 0], // red
      [0, 1, 0], // green
      [0, 0, 1], // blue
      [1, 1, 0]  // yellow
    ]
    
    let vertexBuffer: MTLBuffer
    let indexBuffer: MTLBuffer
    let colorBuffer: MTLBuffer
    
    init(device: MTLDevice, scale: Float = 1)
    {
        vertices = vertices.map
        {
            $0 * scale
        }
        
        guard
            let vertexBuffer = device.makeBuffer(bytes: &vertices, length: MemoryLayout<Float>.size * vertices.count, options: .storageModeShared)
        else
        {
            fatalError("Failed to create vertex buffer for quad.")
        }
        self.vertexBuffer = vertexBuffer
        
        guard
            let indexBuffer = device.makeBuffer(bytes: &indices, length: MemoryLayout<UInt16>.size * indices.count, options: .storageModeShared)
        else
        {
            fatalError("Failed to create index buffer for quad.")
        }
        self.indexBuffer = indexBuffer
        
        guard
            let colorBuffer = device.makeBuffer(bytes: &colors, length: MemoryLayout<simd_float3>.size * colors.count, options: .storageModeShared)
        else
        {
            fatalError("Failed to create color buffer for quad.")
        }
        self.colorBuffer = colorBuffer
    }
}
