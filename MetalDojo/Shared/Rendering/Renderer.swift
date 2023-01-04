//
//  Renderer.swift
//  MetalDojo
//
//  Created by Georgi Nikoloff on 27.12.22.
//

import MetalKit

final class Renderer {
  static var device: MTLDevice!
  static var commandQueue: MTLCommandQueue!
  static var library: MTLLibrary!
  static var meshAllocator: MTKMeshBufferAllocator!
  static var viewColorFormat: MTLPixelFormat!

  static func buildDepthStencilState() -> MTLDepthStencilState? {
    let descriptor = MTLDepthStencilDescriptor()
    descriptor.depthCompareFunction = .less
    descriptor.isDepthWriteEnabled = true
    return Renderer.device.makeDepthStencilState(
      descriptor: descriptor)
  }

  var perspCameraUniforms = CameraUniforms()

  init(metalView: MTKView) {
    guard
      let device = MTLCreateSystemDefaultDevice(),
      let commandQueue = device.makeCommandQueue() else {
      fatalError("GPU not available")
    }
    Renderer.device = device
    Renderer.commandQueue = commandQueue
    Renderer.library = device.makeDefaultLibrary()
    Renderer.meshAllocator = MTKMeshBufferAllocator(device: device)
    Renderer.viewColorFormat = metalView.colorPixelFormat

    metalView.device = device
//    metalView.clearColor = MTLClearColor(red: 1, green: 0.2, blue: 0.2, alpha: 1)
    metalView.depthStencilPixelFormat = .depth32Float

    mtkView(metalView, drawableSizeWillChange: metalView.bounds.size)
  }
}

extension Renderer {
  func mtkView(_ metalView: MTKView, drawableSizeWillChange size: CGSize) {

  }

  func draw(screens: [ExampleScreen], in view: MTKView) {
    guard
      var descriptor = view.currentRenderPassDescriptor,
      let commandBuffer = Renderer.commandQueue.makeCommandBuffer() else {
      return
    }

    for var screen in screens {
      screen.draw(in: view, commandBuffer: commandBuffer)
    }

    guard let drawable = view.currentDrawable else {
      return
    }
    commandBuffer.present(drawable)
    commandBuffer.commit()
  }
}
