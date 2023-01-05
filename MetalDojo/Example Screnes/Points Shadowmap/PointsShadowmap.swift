//
//  PointsShadowmap.swift
//  MetalDojo
//
//  Created by Georgi Nikoloff on 31.12.22.
//

// swiftlint:disable identifier_name

import MetalKit

class PointsShadowmap: ExampleScreen {
  private static let SHADOW_PASS_LABEL = "Point Shadow Pass"
  private static let FORWARD_PASS_LABEL = "Point ShadowMap Pass"

  private var cubeRenderPipeline: MTLRenderPipelineState
  private let sphereRenderPipelineFront: MTLRenderPipelineState
  private let sphereRenderPipelineBack: MTLRenderPipelineState
  private let centerSphereRenderPipeline: MTLRenderPipelineState
  private let depthStencilState: MTLDepthStencilState?

  private var cube: Cube
  private var sphere0: SphereLightCaster
  private var sphere1: SphereLightCaster

  private var perspCameraUniforms = CameraUniforms()
  private var perspCamera = ArcballCamera()

  private var shadowCastersUniformsBuffer: MTLBuffer
  private var shadowCasrersUniformsBufferContents: UnsafeMutablePointer<PointsShadowmap_Light>

  init() {
    do {
      try cubeRenderPipeline = PointsShadowmapPipelineStates.createForwardPSO(
        colorPixelFormat: Renderer.viewColorFormat,
        isSolidColor: false,
        isShadedAndShadowed: true
      )
      try sphereRenderPipelineFront = PointsShadowmapPipelineStates.createForwardPSO(
        colorPixelFormat: Renderer.viewColorFormat,
        isCutOffAlpha: true
      )
      try sphereRenderPipelineBack = PointsShadowmapPipelineStates.createForwardPSO(
        colorPixelFormat: Renderer.viewColorFormat,
        isSolidColor: true,
        isCutOffAlpha: true
      )
      try centerSphereRenderPipeline = PointsShadowmapPipelineStates.createForwardPSO(
        colorPixelFormat: Renderer.viewColorFormat,
        isSolidColor: true
      )
    } catch {
      fatalError(error.localizedDescription)
    }

    perspCamera.distance = 3

    depthStencilState = Renderer.buildDepthStencilState()

    cube = Cube(size: [2, 2, 2])
    cube.cullMode = .front

    sphere0 = SphereLightCaster()
    sphere1 = SphereLightCaster()

    shadowCastersUniformsBuffer = Renderer.device.makeBuffer(
      length: MemoryLayout<PointsShadowmap_Light>.stride * 2
    )!
    shadowCasrersUniformsBufferContents = shadowCastersUniformsBuffer
      .contents()
      .bindMemory(to: PointsShadowmap_Light.self, capacity: 2)

    shadowCasrersUniformsBufferContents[0].color = float3(0.203, 0.596, 0.858)
    shadowCasrersUniformsBufferContents[0].cutoffDistance = 1.3
    shadowCasrersUniformsBufferContents[1].color = float3(0.905, 0.596, 0.235)
    shadowCasrersUniformsBufferContents[1].cutoffDistance = 1.3
  }

  func resize(view: MTKView, size: CGSize) {
    self.perspCamera.update(size: size)
  }

  func update(elapsedTime: Float, deltaTime: Float) {
    perspCamera.update(deltaTime: deltaTime)

    let moveRadius: Float = 0.4
    sphere0.position.x = sin(elapsedTime) * moveRadius
    sphere0.position.y = sin(elapsedTime + 10) * moveRadius
    sphere0.position.z = cos(elapsedTime) * moveRadius

    sphere0.rotation.x = elapsedTime * 0.2
    sphere0.rotation.y = elapsedTime * 0.2
    sphere0.rotation.z = -elapsedTime

    sphere1.position.x = sin(-elapsedTime) * moveRadius
    sphere1.position.y = sin(elapsedTime * 2) * moveRadius
    sphere1.position.z = cos(-elapsedTime + 10) * moveRadius

    sphere1.rotation.x = -elapsedTime * 0.8
    sphere1.rotation.y = elapsedTime * 0.8
    sphere1.rotation.z = -elapsedTime
  }

  func updateUniforms() {
    perspCameraUniforms.viewMatrix = perspCamera.viewMatrix
    perspCameraUniforms.projectionMatrix = perspCamera.projectionMatrix
    perspCameraUniforms.position = perspCamera.position

    shadowCasrersUniformsBufferContents[0].position = sphere0.position
    shadowCasrersUniformsBufferContents[1].position = sphere1.position
  }

  func drawShadowCubeMap(commandBuffer: MTLCommandBuffer) {
    sphere0.cullMode = .none
    sphere1.cullMode = .none
    sphere0.drawCubeShadow(
      commandBuffer: commandBuffer,
      idx: 0,
      shadowCastersBuffer: shadowCastersUniformsBuffer
    )
    sphere1.drawCubeShadow(
      commandBuffer: commandBuffer,
      idx: 1,
      shadowCastersBuffer: shadowCastersUniformsBuffer
    )
  }

  func draw(in view: MTKView, commandBuffer: MTLCommandBuffer) {
    drawShadowCubeMap(commandBuffer: commandBuffer)

    guard let descriptor = view.currentRenderPassDescriptor else {
      return
    }

//    view.clearColor = MTLClearColor(red: 1, green: 0.2, blue: 1, alpha: 1)

    var camUniforms = perspCameraUniforms
    updateUniforms()

    guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
      return
    }

    renderEncoder.setVertexBytes(
      &camUniforms,
      length: MemoryLayout<CameraUniforms>.stride,
      index: CameraUniformsBuffer.index
    )
    renderEncoder.setFragmentBuffer(
      shadowCastersUniformsBuffer,
      offset: 0,
      index: ShadowCameraUniformsBuffer.index
    )
    renderEncoder.setFragmentTextures(
      [sphere0.cubeShadowTexture, sphere1.cubeShadowTexture],
      range: 0..<2
    )

    renderEncoder.label = PointsShadowmap.FORWARD_PASS_LABEL
    renderEncoder.setDepthStencilState(depthStencilState)
    renderEncoder.setRenderPipelineState(cubeRenderPipeline)

    cube.instanceCount = 1
    cube.draw(renderEncoder: renderEncoder)

    renderEncoder.setRenderPipelineState(centerSphereRenderPipeline)
    sphere0.drawCenterSphere(renderEncoder: renderEncoder)
    sphere1.drawCenterSphere(renderEncoder: renderEncoder)

    renderEncoder.setRenderPipelineState(sphereRenderPipelineBack)
    sphere0.cullMode = .front
    sphere1.cullMode = .front
    sphere0.draw(renderEncoder: renderEncoder)
    sphere1.draw(renderEncoder: renderEncoder)

    renderEncoder.setRenderPipelineState(sphereRenderPipelineFront)

    sphere0.cullMode = .back
    sphere1.cullMode = .back
    sphere0.draw(renderEncoder: renderEncoder)
    sphere1.draw(renderEncoder: renderEncoder)


    renderEncoder.endEncoding()
  }

  func destroy() {
  }

}
