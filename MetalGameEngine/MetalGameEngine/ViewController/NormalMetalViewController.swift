//
//  NormalMetalViewController.swift
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/3/19.
//  Copyright © 2019 张思槐. All rights reserved.
//

import MetalKit

class NormalMetalViewController: NSViewController {
    
    private var renderer: Renderer!

    var mtkView: MTKView
    
    override func loadView() {
        self.view = NSView()
    }
    
    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        
        mtkView = MTKView()
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(mtkView)
        
        addGestureRecognizer()
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        
        mtkView.frame = self.view.bounds
    }
    
    private func addGestureRecognizer() {
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
    
    // need override
    func gesturePan(_ translation: float2) {}
}
