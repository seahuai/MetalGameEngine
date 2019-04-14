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
        addViewController.paretnNodes = nodes
        self.presentAsModalWindow(addViewController)
    }
    
    @IBOutlet weak var sceneNodesTableView: NSTableView! {
        didSet {
            self.sceneNodesTableView.dataSource = self
            self.sceneNodesTableView.delegate = self
            self.sceneNodesTableView.rowHeight = 26
            self.sceneNodesTableView.tableColumns.first?.width = self.sceneNodesTableView.bounds.width
        }
    }
    
    @IBOutlet weak var mtkView: MTKView!
    
    @IBAction func segmentedControlValueChanged(_ sender: NSSegmentedControl) {
        sceneNodesTableView.reloadData()
    }
    
    
    var nodes: [Node] = []
    let scene: Scene
    let renderType: RenderType
    
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
        
        reloadNodes()
    }
    
    private func reloadNodes() {
        nodes = []
        for parent in scene.nodes {
            nodes.append(parent)
            nodes.append(contentsOf: parent.subNodes)
        }
        if segmentedControl.indexOfSelectedItem == 0 {
            sceneNodesTableView.reloadData()
        }
    }
}

extension SceneViewController: AddViewControllerDelegate {
    func addViewController(viewController: AddViewController, add node: Node, parentNode: Node?) {
        scene.add(node: node, parentNode: parentNode)
        reloadNodes()
    }
    
    func addViewController(viewController: AddViewController, add light: Light) {
        scene.lights.append(light)
        if segmentedControl.indexOfSelectedItem == 1 {
            sceneNodesTableView.reloadData()
        }
    }
}

extension SceneViewController: NSTableViewDataSource, NSTableViewDelegate {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        let index = segmentedControl.indexOfSelectedItem
        
        if index == 0 {
            return nodes.count
        }
        
        if index == 1 {
            return scene.lights.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let _ = tableColumn else { return nil }
        
        var view: NSView?
        
        let index = segmentedControl.indexOfSelectedItem
        
        if index == 0 {
            var sceneNodeCellView = tableView.makeView(withIdentifier: SceneNodeCellView.identifier, owner: nil) as? SceneNodeCellView
            if sceneNodeCellView == nil {
                sceneNodeCellView = SceneNodeCellView()
            }
            
            let node = nodes[row]
            sceneNodeCellView?.node = node
            view = sceneNodeCellView
        } else if index == 1 {
            var sceneLightCellView = tableView.makeView(withIdentifier: SceneLightCellView.identifier, owner: nil) as? SceneLightCellView
            if sceneLightCellView == nil {
                sceneLightCellView = SceneLightCellView()
                sceneLightCellView?.identifier = identifier
            }
            
            let light = scene.lights[row]
            sceneLightCellView?.light = light
            view = sceneLightCellView
        }
        
        return view
    }
}
