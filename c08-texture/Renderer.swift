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

import MetalKit

// swiftlint:disable implicitly_unwrapped_optional

class Renderer: NSObject {
    static var device: MTLDevice!
    static var commandQueue: MTLCommandQueue!
    static var library: MTLLibrary!
    var options: Options

    var pipelineState: MTLRenderPipelineState!
    let depthStencilState: MTLDepthStencilState?
    let samplerState: MTLSamplerState?

    var timer: Float = 0
    var uniforms = Uniforms()
    var params = Params()

    // the models to render
    lazy var plane: Model = { Model(name: "bw.obj") }()
    lazy var house: Model = { Model(name: "lowpoly-house.obj") }()
    lazy var ground: Model = {
        var ground = Model(name: "plane.obj")
        ground.tiling = 4
        return ground
    }()

    init(metalView: MTKView, options: Options) {
        guard
            let device = MTLCreateSystemDefaultDevice(),
            let commandQueue = device.makeCommandQueue() else {
            fatalError("GPU not available")
        }
        Renderer.device = device
        Renderer.commandQueue = commandQueue
        metalView.device = device

        // create the shader function library
        let library = device.makeDefaultLibrary()
        Self.library = library
        let vertexFunction = library?.makeFunction(name: "vertex_main")
        let fragmentFunction =
            library?.makeFunction(name: "fragment_main")

        // create the pipeline state
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = metalView.colorPixelFormat
        pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        do {
            pipelineDescriptor.vertexDescriptor = MTLVertexDescriptor.defaultLayout
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch let error {
            fatalError(error.localizedDescription)
        }
        self.options = options
        depthStencilState = Renderer.buildDepthStencilState()
        samplerState = Renderer.buildSamplerState()
        super.init()
        metalView.clearColor = MTLClearColor(red: 0.0,
                                             green: 0.0,
                                             blue: 0.0,
                                             alpha: 1.0)
        metalView.depthStencilPixelFormat = .depth32Float
        metalView.delegate = self
        mtkView(metalView, drawableSizeWillChange: metalView.bounds.size)
    }

    private static func buildDepthStencilState() -> MTLDepthStencilState? {
        let descriptor = MTLDepthStencilDescriptor()
        descriptor.depthCompareFunction = .less
        descriptor.isDepthWriteEnabled = true
        return Renderer.device.makeDepthStencilState(
            descriptor: descriptor)
    }

    private static func buildSamplerState() -> MTLSamplerState? {
        let descriptor = MTLSamplerDescriptor()
        // repeat
        descriptor.sAddressMode = .repeat
        descriptor.tAddressMode = .repeat
        //        descriptor.rAddressMode = .repeat

        // filter
        descriptor.minFilter = .linear
        descriptor.magFilter = .linear
        // mip filter
        descriptor.mipFilter = .linear
        // anisotropy
        descriptor.maxAnisotropy = 8
        let samplerState =
            Renderer.device.makeSamplerState(descriptor: descriptor)
        return samplerState
    }
}

extension Renderer: MTKViewDelegate {
    func mtkView(
        _ view: MTKView,
        drawableSizeWillChange size: CGSize
    ) {
        let aspect =
            Float(view.bounds.width) / Float(view.bounds.height)
        let projectionMatrix = float4x4(projectionFov: Float(70).degreesToRadians,
                                        near: 0.1,
                                        far: 100,
                                        aspect: aspect)
        uniforms.projectionMatrix = projectionMatrix

        params.width = UInt32(size.width)
        params.height = UInt32(size.height)
    }

    func draw(in view: MTKView) {
        guard
            let commandBuffer = Renderer.commandQueue.makeCommandBuffer(),
            let descriptor = view.currentRenderPassDescriptor,
            let renderEncoder =
                commandBuffer.makeRenderCommandEncoder(
                    descriptor: descriptor) else {
            return
        }

        renderEncoder.setDepthStencilState(depthStencilState)
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setFragmentSamplerState(samplerState, index: 0)

        // plane

        //        uniforms.viewMatrix = float4x4(translation: [0, -0, -1]).inverse
        //
        //        plane.rotation.x = sin(1.71)
        //        plane.render(encoder: renderEncoder, uniforms: uniforms, params: params)

        // house

        timer += 0.005
        uniforms.viewMatrix = float4x4(translation: [0, 1.5, -5]).inverse

        house.rotation.y = sin(timer)
        house.render(encoder: renderEncoder, uniforms: uniforms, params: params)

        ground.scale = 40
        ground.rotation.y = sin(timer)
        ground.render(
            encoder: renderEncoder,
            uniforms: uniforms,
            params: params)

        renderEncoder.endEncoding()
        guard let drawable = view.currentDrawable else {
            return
        }
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
