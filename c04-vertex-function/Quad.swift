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
    
    var indices: [Float] = [
        0, 3, 2,
        0, 1, 3
    ]
    
    var colors: [simd_float3] = [ // simd_float3 ????
      [1, 0, 0], // red
      [0, 1, 0], // green
      [0, 0, 1], // blue
      [1, 1, 0]  // yellow
    ]
    
    init(device: MTLDevice, scale: Float = 1)
    {
        
    }
}
