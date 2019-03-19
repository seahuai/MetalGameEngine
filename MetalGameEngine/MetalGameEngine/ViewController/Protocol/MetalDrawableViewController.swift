//
//  MetalDrawableViewController.swift
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/3/19.
//  Copyright © 2019 张思槐. All rights reserved.
//

import MetalKit

protocol MetalDrawableViewController {
    var mtkView: MTKView { get set }
    
    func setUpRenderer(_ renderer: Renderer)
}
