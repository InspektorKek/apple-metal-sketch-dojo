//
//  GameController.swift
//  MetalDojo
//
//  Created by Georgi Nikoloff on 27.12.22.
//

import MetalKit

final class GameController: NSObject {
  var renderer: Renderer
  var options: Options
  var fps: Double = 0
  var deltaTime: Double = 0
  var lastTime: Double = CFAbsoluteTimeGetCurrent()

  // Screens
  var screens: [ExampleScreen] = []

  init(metalView: MTKView, options: Options) {
    renderer = Renderer(metalView: metalView)
    self.options = options
    super.init()
    metalView.delegate = self
    fps = Double(metalView.preferredFramesPerSecond)

    screens.append(WelcomeScreen(options: options))
    screens.append(PointsShadowmap())
  }
}

extension GameController: MTKViewDelegate {
  func mtkView(_ metalView: MTKView, drawableSizeWillChange size: CGSize) {
    for screen in screens {
      var screen = screen
      screen.resize(view: metalView, size: size)
    }
  }
  func draw(in view: MTKView) {
    let currentTime = CFAbsoluteTimeGetCurrent()
    options.dt = Float(currentTime - lastTime)
    lastTime = currentTime

    for var screen in screens {
      screen.update(deltaTime: options.dt)
    }

    renderer.draw(screens: screens, in: view)
    options.mouseDown = false
  }

  func dismissSingleProject() {
//    scene.dismissSingleProject()
  }
}
