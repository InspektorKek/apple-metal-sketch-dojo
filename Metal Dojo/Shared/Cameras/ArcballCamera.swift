//
//  ArcballCamera.swift
//  MetalDojo
//
//  Created by Georgi Nikoloff on 04.01.23.
//

import CoreGraphics
import simd

enum Settings {
  static var rotationSpeed: Float { 2.0 }
  static var translationSpeed: Float { 3.0 }
  static var dollySensitivity: Float { 0.9 }
  static var mousePanSensitivity: Float { 0.008 }
}

struct ArcballCamera: Camera {
  var transform = Transform()

  var aspect: Float = 1.0
  var fov = Float(70).degreesToRadians
  var near: Float = 0.1
  var far: Float = 100
  var projectionMatrix: float4x4 {
    float4x4(
      projectionFov: fov,
      near: near,
      far: far,
      aspect: aspect)
  }

  var origDistance: Float?
  var distance: Float = 2.5
  var minDistance: Float = 1
  var maxDistance: Float = 1000

  var target: float3 = [0, 0, 0]
  var minPolarAngle: Float = -.pi / 2
  var maxPolarAngle: Float = .pi / 2

  init(distance: Float) {
    self.distance = distance
    self.origDistance = distance
  }

  mutating func update(size: CGSize) {
    aspect = Float(size.width / size.height)
  }

  var viewMatrix: float4x4 {
    let matrix: float4x4
    if target == position {
      matrix = (float4x4(translation: target) * float4x4(rotationYXZ: rotation)).inverse
    } else {
      matrix = float4x4(eye: position, center: target, up: [0, 1, 0])
    }
    return matrix
  }

  mutating func update(deltaTime: Float, pinchFactor: Float? = 0) {
    let input = InputController.shared

    distance = origDistance! + pinchFactor!
    distance = min(maxDistance, distance)
    distance = max(minDistance, distance)

    if input.leftMouseDown {
      let sensitivity = Settings.mousePanSensitivity
      rotation.x += input.mouseDelta.y * sensitivity
      rotation.y += input.mouseDelta.x * sensitivity
      rotation.x = max(minPolarAngle, min(rotation.x, maxPolarAngle))
    }
    let rotateMatrix = float4x4(
      rotationYXZ: [-rotation.x, rotation.y, 0])
    let distanceVector = float4(0, 0, -distance, 0)
    let rotatedVector = rotateMatrix * distanceVector
    position = target + rotatedVector.xyz
  }
}
