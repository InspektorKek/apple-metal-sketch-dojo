//
//  Model.swift
//  MetalDojo
//
//  Created by Georgi Nikoloff on 25.01.23.
//

// swiftlint:disable force_try
// swiftlint:disable identifier_name

import MetalKit
import os

class Model: Transformable {
  var name: String
  var transform = Transform()
  var meshes: [Mesh]
  let hasTransparency: Bool
  var instanceCount: Int = 1
  var cullMode: MTLCullMode = .back
  var boundingBox = MDLAxisAlignedBoundingBox()
  var size: float3 {
    return boundingBox.maxBounds - boundingBox.minBounds
  }
  var currentTime: Float = 0
  let animations: [String: AnimationClip]

  private var uniformsBuffer: MTLBuffer

  init(name: String) {
    guard let assetURL = Bundle.main.url(
      forResource: name,
      withExtension: "usdz"
    ) else {
      fatalError("Model: \(name) not found")
    }
    let asset = MDLAsset(
      url: assetURL,
      vertexDescriptor: MDLVertexDescriptor.defaultLayout,
      bufferAllocator: MTKMeshBufferAllocator(device: Renderer.device)
    )
    asset.loadTextures()

    var mtkMeshes: [MTKMesh] = []
    let mdlMeshes = asset.childObjects(of: MDLMesh.self) as? [MDLMesh] ?? []

    _ = mdlMeshes.map { mdlMesh in
      mdlMesh.addTangentBasis(
        forTextureCoordinateAttributeNamed: MDLVertexAttributeTextureCoordinate,
        tangentAttributeNamed: MDLVertexAttributeTangent,
        bitangentAttributeNamed: MDLVertexAttributeBitangent
      )
      mtkMeshes.append(
        try! MTKMesh(
          mesh: mdlMesh,
          device: Renderer.device
        )
      )
    }
    meshes = zip(mdlMeshes, mtkMeshes).map {
      Mesh(
        mdlMesh: $0.0,
        mtkMesh: $0.1,
        startTime: asset.startTime,
        endTime: asset.endTime)
    }

    self.name = name
    hasTransparency = false
    boundingBox = asset.boundingBox
    // animations
    let assetAnimations = asset.animations.objects.compactMap {
      $0 as? MDLPackedJointAnimation
    }

    let animations
      = Dictionary(uniqueKeysWithValues: assetAnimations.map {
      ($0.name, AnimationComponent.load(animation: $0))
      })
    self.animations = animations

    uniformsBuffer = Renderer.device.makeBuffer(
      length: MemoryLayout<Uniforms>.stride,
      options: []
    )!
  }

  func update(deltaTime: Float) {
    currentTime += deltaTime
    for i in 0..<meshes.count {
      var mesh = meshes[i]
      if let animationClip = animations.first?.value {
        mesh.skeleton?.updatePose(
          animationClip: animationClip,
          at: currentTime
        )
      }
      mesh.transform?.getCurrentTransform(at: currentTime)
      meshes[i] = mesh
    }
  }

  func draw(encoder: MTLRenderCommandEncoder, useTextures: Bool = true) {

    encoder.setCullMode(.back)

    for mesh in meshes {
      if let paletteBuffer = mesh.skeleton?.jointMatrixPaletteBuffer {
        encoder.setVertexBuffer(
          paletteBuffer,
          offset: 0,
          index: JointBuffer.index)
      }
      let currentLocalTransform =
        mesh.transform?.currentTransform ?? .identity
      let uniformPtr = uniformsBuffer.contents().bindMemory(to: Uniforms.self, capacity: 1)
      let modelMatrix = transform.modelMatrix * currentLocalTransform
      uniformPtr.pointee.modelMatrix = modelMatrix
      uniformPtr.pointee.normalMatrix = float3x3(normalFrom4x4: modelMatrix)
      encoder.setVertexBuffer(
        uniformsBuffer,
        offset: 0,
        index: UniformsBuffer.index
      )
      for (index, vertexBuffer) in mesh.vertexBuffers.enumerated() {
        encoder.setVertexBuffer(
          vertexBuffer,
          offset: 0,
          index: index)
      }

      for submesh in mesh.submeshes {
        if useTextures {
          encoder.setFragmentTexture(
            submesh.textures.baseColor,
            index: BaseColor.index
          )
          encoder.setFragmentTexture(
            submesh.textures.normal,
            index: NormalTexture.index
          )
          encoder.setFragmentTexture(
            submesh.textures.roughness,
            index: RoughnessTexture.index
          )
          encoder.setFragmentTexture(
            submesh.textures.metallic,
            index: MetallicTexture.index
          )
          encoder.setFragmentTexture(
            submesh.textures.ambientOcclusion,
            index: AOTexture.index
          )
          encoder.setFragmentTexture(
            submesh.textures.opacity,
            index: OpacityTexture.index
          )
          var material = submesh.material
          encoder.setFragmentBytes(
            &material,
            length: MemoryLayout<Material>.stride,
            index: MaterialBuffer.index
          )
        }

        encoder.setCullMode(cullMode)

        encoder.drawIndexedPrimitives(
          type: .triangle,
          indexCount: submesh.indexCount,
          indexType: submesh.indexType,
          indexBuffer: submesh.indexBuffer,
          indexBufferOffset: submesh.indexBufferOffset,
          instanceCount: instanceCount
        )

      }
    }
//    encoder.popDebugGroup()
  }
}

