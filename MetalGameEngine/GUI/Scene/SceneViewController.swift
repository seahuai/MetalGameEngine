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
    
    private lazy var addViewController = AddViewController()
    
    @IBOutlet weak var segmentedControl: NSSegmentedControl!
    
    @IBOutlet weak var addButton: NSButton!
    
    @IBAction func addButtonDidClick(_ sender: NSButton) {
        self.presentAsModalWindow(addViewController)
    }
    
    let scene: Scene
    
    let renderType: RenderType
    
    @IBOutlet weak var sceneNodesTableView: NSTableView! {
        didSet {
            self.sceneNodesTableView.dataSource = self
            self.sceneNodesTableView.delegate = self
            self.sceneNodesTableView.rowHeight = 26
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
        
        addViewController.delegate = self
    }
}

extension SceneViewController: AddViewControllerDelegate {
    func addViewController(viewController: AddViewController, add node: Node, parentNode: Node?) {
        scene.add(node: node, parentNode: parentNode)
    }
}

extension SceneViewController: NSTableViewDataSource, NSTableViewDelegate {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
//        return scene.nodes.count
        return 10
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let _ = tableColumn else { return nil }
        
        var sceneNodeCellView = tableView.makeView(withIdentifier: SceneNodeCellView.identifier, owner: nil) as? SceneNodeCellView
        if sceneNodeCellView == nil {
            sceneNodeCellView = SceneNodeCellView()
        }
        
        return sceneNodeCellView
    }
    
    
}
