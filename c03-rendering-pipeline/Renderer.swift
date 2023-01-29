import MetalKit
import OSLog

class Renderer: NSObject {
    // swiftlint:disable implicitly_unwrapped_optional
    static var device: MTLDevice!
    static var commandQueue: MTLCommandQueue!
    static var library: MTLLibrary!
    var mesh: MTKMesh!
    var vertexBuffer: MTLBuffer!
    var vertexIndex: MTLBuffer!
    var renderPipelineState: MTLRenderPipelineState!
    let vertexPositionData: [Float] = [
        0.5, -0.5, 0.0, 1.0, 0.0, 0.0,
        -0.5, -0.5, 0.0, 0.0, 0.0, 1.0,
        0.0, 0.5, 0.0, 0.0, 1.0, 0.0
    ]

    let vertexIndexData: [UInt32] = [ // clockwise
        //        0, 1, 2, // clockwise
        0, 2, 1 // counter-clockwise
    ]
    init(metalView: MTKView) {
        guard
            let device = MTLCreateSystemDefaultDevice(),
            let commandQueue = device.makeCommandQueue()
        else {
            fatalError("GPU not available")
        }

        Renderer.device = device
        Renderer.commandQueue = commandQueue
        metalView.device = device

        // create a mesh
        let allocator = MTKMeshBufferAllocator(device: device)
        let size: Float = 1.0
        let mdlMesh = MDLMesh(boxWithExtent: [size, size, size],
                              segments: [1, 1, 1],
                              inwardNormals: false,
                              geometryType: .triangles,
                              allocator: allocator)

        do {
            mesh = try MTKMesh(mesh: mdlMesh, device: device)
        } catch
            let error {
            fatalError(error.localizedDescription)
        }

        let vertexPositionDataByteSize = MemoryLayout<Float>.size * vertexPositionData.count

        // set vertex buffer
        guard
            let vbo: MTLBuffer = device.makeBuffer(bytes: &vertexPositionData,
                                                   length: vertexPositionDataByteSize,
                                                   options: .storageModeShared)
        else
        {
            fatalError("Failed to create vertex position buffer")
        }

        vertexBuffer = vbo
        //        vertexBuffer = mesh.vertexBuffers[0].buffer

        // set vertex index
        let vertexIndexDataByteSize = MemoryLayout<UInt32>.size * vertexIndexData.count
        guard
            let ibo: MTLBuffer = device.makeBuffer(bytes: &vertexIndexData, length: vertexIndexDataByteSize, options: .storageModeShared)
        else
        {
            fatalError("Failed to create vertex index buffer")
        }
        vertexIndex = ibo

        // create the shader function library
        guard
            let library = device.makeDefaultLibrary()
        else
        {
            fatalError("Failed to make default library.")
        }
        Renderer.library = library
        let vertexFunction = library.makeFunction(name: "vertex_main")
        let fragmentFunction = library.makeFunction(name: "fragment_main")

        // create the pipeline state object
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        let colorAttachments: MTLRenderPipelineColorAttachmentDescriptorArray = pipelineDescriptor.colorAttachments
        let colorAttachment0 = colorAttachments[0]
        colorAttachment0?.pixelFormat = metalView.colorPixelFormat

        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].bufferIndex = 0
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[1].format = .float3
        vertexDescriptor.attributes[1].bufferIndex = 0
        vertexDescriptor.attributes[1].offset = MemoryLayout<Float>.size * 3
        vertexDescriptor.layouts[0].stride = MemoryLayout<Float>.size * 6
        pipelineDescriptor.vertexDescriptor = vertexDescriptor

        do {
            renderPipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch
            let error {
            fatalError(error.localizedDescription)
        }

        super.init()

        metalView.clearColor = MTLClearColor(red: 0.0,
                                             green: 0.0,
                                             blue: 0.0,
                                             alpha: 1.0)

        metalView.delegate = self
    }
}

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        os_log(.debug, log: OSLog.debug, "mtkView")
    }

    func draw(in view: MTKView) {
        os_log(.debug, log: OSLog.debug, "draw")

        guard
            let commandBuffer = Renderer.commandQueue.makeCommandBuffer()
        else
        {
            os_log(.error, log: OSLog.error, "Faile to make command buffer.")
            return
        }

        guard
            let renderPassDescriptor = view.currentRenderPassDescriptor
        else
        {
            os_log(.error, log: OSLog.error, "Faile to get render pass descriptor.")
            return
        }

        guard
            let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        else
        {
            os_log(.error, log: OSLog.error, "Failed to make render command encoder")
            return
        }

        renderCommandEncoder.setRenderPipelineState(renderPipelineState)
        renderCommandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderCommandEncoder.setCullMode(.back)
        renderCommandEncoder.setFrontFacing(.counterClockwise) // default is clockwise

        //        for submesh in mesh.submeshes {
        //            os_log(.info, log: OSLog.info, "Index count: %d", submesh.indexCount)
        //            os_log(.info, log: OSLog.info, "Index Buffer offset: %d", submesh.indexBuffer.offset)
        //            renderCommandEncoder.drawIndexedPrimitives(type: .triangle,
        //                                                     indexCount: 24,
        //                                                     indexType: submesh.indexType,
        //                                                     indexBuffer: submesh.indexBuffer.buffer,
        //                                                     indexBufferOffset: submesh.indexBuffer.offset)
        //        }

        renderCommandEncoder.drawIndexedPrimitives(type: .triangle,
                                                   indexCount: vertexIndexData.count, indexType: .uint32, indexBuffer: vertexIndex, indexBufferOffset: 0)
        os_log(.info, log: OSLog.info, "submesh count: %d", mesh.submeshes.count)

        // endEncoding function must be called before it is released.
        renderCommandEncoder.endEncoding()

        // get drawable
        guard
            let drawable: CAMetalDrawable = view.currentDrawable
        else
        {
            os_log(.error, log: OSLog.error, "Failed to get drawable")
            return
        }

        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
