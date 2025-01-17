//
//  PipelineStates.swift
//  MetalDojo
//
//  Created by Georgi Nikoloff on 27.12.22.
//

import Foundation
import Metal

protocol PipelineStates {}

extension PipelineStates {
  static func getFnConstants(
    hasSkeleton: Bool = false,
    rendersToTargetArray: Bool = false,
    rendersDepth: Bool = false,
    hasUv: Bool = true
  ) -> MTLFunctionConstantValues {
    var hasSkeleton = hasSkeleton
    var rendersToTargetArray = rendersToTargetArray
    var rendersDepth = rendersDepth
    var hasUv = hasUv

    let fnConstantValues = MTLFunctionConstantValues()
    fnConstantValues.setConstantValue(
      &hasSkeleton,
      type: .bool,
      index: IsSkeletonAnimation.index
    )
    fnConstantValues.setConstantValue(
      &rendersToTargetArray,
      type: .bool,
      index: RendersToTargetArray.index
    )
    fnConstantValues.setConstantValue(
      &rendersDepth,
      type: .bool,
      index: RendersDepth.index
    )
    fnConstantValues.setConstantValue(
      &hasUv,
      type: .bool,
      index: HasUV.index
    )
    return fnConstantValues
  }

  static func createPSO(descriptor: MTLRenderPipelineDescriptor)
    -> MTLRenderPipelineState {
    let pipelineState: MTLRenderPipelineState
    do {
      pipelineState =
      try Renderer.device.makeRenderPipelineState(
        descriptor: descriptor)
    } catch let error {
      fatalError(error.localizedDescription)
    }
    return pipelineState
  }

  static func buildDepthStencilState() -> MTLDepthStencilState? {
    let descriptor = MTLDepthStencilDescriptor()
    descriptor.depthCompareFunction = .less
    descriptor.isDepthWriteEnabled = true
    return Renderer.device.makeDepthStencilState(descriptor: descriptor)
  }

  static func buildSkyboxDepthStencilState() -> MTLDepthStencilState? {
    let descriptor = MTLDepthStencilDescriptor()
    descriptor.depthCompareFunction = .lessEqual
    descriptor.isDepthWriteEnabled = true
    return Renderer.device.makeDepthStencilState(descriptor: descriptor)
  }

}

