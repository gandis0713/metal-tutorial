import MetalKit
import OSLog

class Renderer: NSObject
{
    // swiftlint:disable implicitly_unwrapped_optional
    static var device: MTLDevice!
    static var commandQueue: MTLCommandQueue!
    static var library: MTLLibrary!
    var mesh: MTKMesh!
    var vertexBuffer: MTLBuffer!
    var vertexIndex: MTLBuffer!
    var renderPipelineState: MTLRenderPipelineState!
    lazy var quad: Quad = {
      Quad(device: Renderer.device, scale: 0.8)
    }()
    var timer: Float = 0
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
        
        // create the shader function library
        guard
            let library = device.makeDefaultLibrary()
        else
        {
            fatalError("Failed to make default library.")
        }
        Renderer.library = library
        let vertexFunction = library.makeFunction(name: "vertex_descriptor_main")
        let fragmentFunction = library.makeFunction(name: "fragment_descriptor_main")
//        let vertexFunction = library.makeFunction(name: "vertex_main")
//        let fragmentFunction = library.makeFunction(name: "fragment_main")

        // create the pipeline state object
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        let colorAttachments: MTLRenderPipelineColorAttachmentDescriptorArray = pipelineDescriptor.colorAttachments
        let colorAttachment0 = colorAttachments[0]
        colorAttachment0?.pixelFormat = metalView.colorPixelFormat

        pipelineDescriptor.vertexDescriptor = MTLVertexDescriptor.defaultDescriptor

        do
        {
            renderPipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        }
        catch
            let error
        {
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

extension Renderer: MTKViewDelegate
{
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize)
    {
        os_log(.debug, log: OSLog.debug, "mtkView")
    }

    func draw(in view: MTKView)
    {
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
//        renderCommandEncoder.setCullMode(.back)
//        renderCommandEncoder.setFrontFacing(.counterClockwise) // default is clockwise

        // use setVertexBytes because byte size of vertices is less than 4KB.
        renderCommandEncoder.setVertexBytes(quad.vertices,
                                            length: MemoryLayout<Float>.stride * quad.vertices.count,
                                            index: MTLVertexDescriptor.defaultBufferIndex)
        renderCommandEncoder.setVertexBytes(quad.colors,
                                            length: MemoryLayout<SIMD3<Float>>.stride * quad.colors.count,
                                            index: MTLVertexDescriptor.defaultColorIndex)
        //        renderCommandEncoder.setVertexBuffer(quad.vertexBuffer, offset: 0, index: MTLVertexDescriptor.defaultBufferIndex)
        //        renderCommandEncoder.setVertexBuffer(quad.colorBuffer, offset: 0, index: MTLVertexDescriptor.defaultColorIndex)
        
        // for drawPrimitives function
//        renderCommandEncoder.setVertexBuffer(quad.indexBuffer, offset: 0, index: 1)
        timer += 0.005
        var currentTime: Float = sin(timer)
        renderCommandEncoder.setVertexBytes(&currentTime, length: MemoryLayout<Float>.stride, index: 11)
//        renderCommandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: quad.indices.count)
        
        // for drawIndexedPrimitives function
        renderCommandEncoder.drawIndexedPrimitives(type: .point,
                                                   indexCount: quad.indices.count,
                                                   indexType: .uint16,
                                                   indexBuffer: quad.indexBuffer,
                                                   indexBufferOffset: 0)
        

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
