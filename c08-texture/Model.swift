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

// swiftlint:disable force_try
// swiftlint:disable vertical_whitespace_opening_braces

import MetalKit
import OSLog

class Model: Transformable {

    var transform = Transform()
    let meshes: [Mesh]
    let name: String
    var tiling: UInt32 = 1

    init(name: String) {
        guard let assetURL = Bundle.main.url(forResource: name,
                                             withExtension: nil)
        else {
            fatalError("Model: \(name) not found")
        }
        let allocator = MTKMeshBufferAllocator(device: Renderer.device)
        let asset = MDLAsset(url: assetURL,
                             vertexDescriptor: .defaultLayout,
                             bufferAllocator: allocator)
        let newMeshes = try! MTKMesh.newMeshes(asset: asset,
                                               device: Renderer.device)
        meshes = zip(newMeshes.modelIOMeshes, newMeshes.metalKitMeshes).map { meshs in
            Mesh(mdlMesh: meshs.0, mtkMesh: meshs.1)
        }
        self.name = name
    }
}

// Rendering
extension Model {

    func render(
        encoder: MTLRenderCommandEncoder,
        uniforms vertex: Uniforms,
        params fragment: Params
    ) {
        var uniforms = vertex
        var params = fragment
        params.tiling = tiling

        uniforms.modelMatrix = transform.modelMatrix

        encoder.setVertexBytes(
            &uniforms,
            length: MemoryLayout<Uniforms>.stride,
            index: UniformsBuffer.index)

        encoder.setFragmentBytes(
            &params,
            length: MemoryLayout<Uniforms>.stride,
            index: ParamsBuffer.index)

        //        os_log(.debug, log: OSLog.info, "meshes count: %d", meshes.count)
        for mesh in meshes {
            for (index, vertexBuffer) in mesh.vertexBuffers.enumerated() {
                //                os_log(.debug, log: OSLog.debug, "index: %d", index)
                //                if index == 1 {continue}
                encoder.setVertexBuffer(
                    vertexBuffer,
                    offset: 0,
                    index: index)
            }
            //            os_log(.debug, log: OSLog.info, "submesh count: %d", mesh.submeshes.count)
            for submesh in mesh.submeshes {
                //                count += 1
                // set the fragment texture here
                encoder.setFragmentTexture(
                    submesh.textures.baseColor,
                    index: BaseColor.index)

                //                os_log(.debug, log: OSLog.info, "submesh.indexBufferOffset: %d", submesh.indexBufferOffset)
                //                os_log(.debug, log: OSLog.info, "submesh.indexCount: %d", submesh.indexCount)
                encoder.drawIndexedPrimitives(
                    type: .triangle,
                    indexCount: submesh.indexCount,
                    indexType: submesh.indexType,
                    indexBuffer: submesh.indexBuffer,
                    indexBufferOffset: submesh.indexBufferOffset
                )
            }
        }
    }
}
