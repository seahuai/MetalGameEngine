//
//  SceneViewController.swift
//  GUI
//
//  Created by 张思槐 on 2019/4/11.
//  Copyright © 2019 张思槐. All rights reserved.
//

import Cocoa
import MetalKit

class SceneViewController: NSViewController {
    
    let scene: Scene
    
    let renderType: RenderType
    
    @IBOutlet weak var sceneNodesTableView: NSTableView! {
        didSet {
            self.sceneNodesTableView.dataSource = self
            self.sceneNodesTableView.delegate = self
            self.sceneNodesTableView.tableColumns.first?.width = self.sceneNodesTableView.bounds.width
        }
    }
    
    @IBOutlet weak var mtkView: MTKView!
    
    init(_ scene: Scene, renderType: RenderType) {
        self.scene = scene
        self.renderType = renderType
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = scene.name
    }
    
}

extension SceneViewController: NSTableViewDataSource, NSTableViewDelegate {
    
}
