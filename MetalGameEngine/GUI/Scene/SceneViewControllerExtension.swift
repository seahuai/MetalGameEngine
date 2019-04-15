//
//  SceneViewControllerExtension.swift
//  GUI
//
//  Created by 张思槐 on 2019/4/15.
//  Copyright © 2019 张思槐. All rights reserved.
//

import Cocoa

extension SceneViewController {
    func setupGestureRecognizer() {
        let pan = NSPanGestureRecognizer(target: self, action: #selector(handlePan(gesture:)))
        mtkView.addGestureRecognizer(pan)
    }
    
    @objc func handlePan(gesture: NSPanGestureRecognizer) {
        let x = Float(gesture.translation(in: gesture.view).x)
        let y = Float(gesture.translation(in: gesture.view).y)
        let translation = float2(x, y)
        gesturePan(translation)
        gesture.setTranslation(.zero, in: gesture.view)
    }

    override func scrollWheel(with event: NSEvent) {
        let delta = event.deltaY
        scene.sceneZooming(delta)
    }
    
   private func gesturePan(_ translation: float2) {
        scene.sceneRotate(translation)
    }
}
