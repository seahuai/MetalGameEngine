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
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        
        mtkView.frame = self.view.bounds
    }
    
    func setUpRenderer(_ renderer: Renderer) {
        
        self.renderer = renderer
        
        mtkView.delegate = renderer
    }
    
}
