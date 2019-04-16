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
    
    @IBOutlet weak var segmentedControl: NSSegmentedControl! {
        didSet {
            self.segmentedControl.selectedSegment = 0
        }
    }
    @IBOutlet weak var addButton: NSButton!
    @IBOutlet weak var mtkView: MTKView!
    @IBOutlet weak var sceneNodesTableView: NSTableView! {
        didSet {
            self.sceneNodesTableView.dataSource = self
            self.sceneNodesTableView.delegate = self
            self.sceneNodesTableView.rowHeight = 26
            self.sceneNodesTableView.tableColumns.first?.width = self.sceneNodesTableView.bounds.width
        }
    }

    @IBAction func addButtonDidClick(_ sender: NSButton) {
        // 地形不能作为父节点也不能作为子节点
        var nodesExcludedTerrain = nodes
        nodesExcludedTerrain.removeAll { (node) -> Bool in
            if let _ = node as? Terrain { return true }
            return false
        }
        addViewController.paretnNodes = nodesExcludedTerrain
        self.presentAsModalWindow(addViewController)
        let windowSize = NSSize(width: 480, height: 420)
        NSApp.mainWindow?.contentMinSize = windowSize
        NSApp.mainWindow?.contentMaxSize = windowSize
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: NSSegmentedControl) {
        sceneNodesTableView.reloadData()
    }
    
    // MARK: - 变量
    private lazy var addViewController = AddViewController()
    private lazy var editViewController = EditViewController()
    
    private var nodes: [Node] = []
    private var skyboxs: [Skybox] = []
    
    private var renderer: Renderer!
    let scene: Scene
    let renderType: RenderType
    
    private var segmentIndex: Int {
        get {
            return segmentedControl.indexOfSelectedItem
        }
        
        set {
            segmentedControl.selectedSegment = newValue
        }
    }
    
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
        
        self.title = "场景 \"\(scene.name)\" "
        
        addViewController.delegate = self
        editViewController.delegate = self
        
        reloadNodes()
        
        setupGestureRecognizer()
        setupMenu()
        setupRenderer()
    }
    
    private func setupRenderer() {
        switch renderType {
        case .rasterization:
            renderer = RasterizationRenderer(metalView: mtkView, scene: scene)
        case .rayTracing:
            fallthrough
        case .deffered:
            fallthrough
        default:
            fatalError()
        }
    }
    
    private func reloadNodes() {
        nodes = []
        for parent in scene.nodes {
            nodes.append(parent)
            nodes.append(contentsOf: parent.subNodes)
        }
        if segmentIndex == 0 {
            sceneNodesTableView.reloadData()
        }
    }
}

// MARK: - Menu
extension SceneViewController {
    func setupMenu() {
        let menu = NSMenu(title: "操作")
        let editMenuItem = NSMenuItem(title: "编辑", action: #selector(editNode), keyEquivalent: "")
        let deleteMenuItem = NSMenuItem(title: "删除", action: #selector(deleteNode), keyEquivalent: "")
        menu.items = [editMenuItem, deleteMenuItem]
        sceneNodesTableView.menu = menu
    }
    
    @objc func deleteNode() {
        let clickedRow = sceneNodesTableView.clickedRow
        if segmentIndex == 0 {
            let node = nodes[clickedRow]
            scene.remove(node: node)
            reloadNodes()
        } else if segmentIndex == 1 {
            scene.lights.remove(at: clickedRow)
            sceneNodesTableView.reloadData()
        } else if segmentIndex == 2 {
            skyboxs.remove(at: clickedRow)
            scene.skybox = skyboxs.first
            sceneNodesTableView.reloadData()
        }
    }
    
    @objc func editNode() {
        var editObject: Any?
        let clickedRow = sceneNodesTableView.clickedRow
        if segmentIndex == 0 {
            editObject = nodes[clickedRow]
        } else if segmentIndex == 1 {
            editObject = scene.lights[clickedRow]
        } else if segmentIndex == 2 {
            editObject = skyboxs[clickedRow]
        }
        
        if let object = editObject {
            editViewController.editObject = object
            self.presentAsModalWindow(editViewController)
        }
    }
}

// MARK: - AddViewControllerDelegate
extension SceneViewController: AddViewControllerDelegate {
    func addViewController(_ viewController: AddViewController, didAddNode node: Node, parentNode: Node?) {
        scene.add(node: node, parentNode: parentNode)
        segmentIndex = 0
        reloadNodes()
    }
    
    func addViewController(_ viewController: AddViewController, didAddLight light: Light) {
        scene.lights.append(light)
        segmentIndex = 1
        sceneNodesTableView.reloadData()
    }
    
    func addViewController(_ viewController: AddViewController, didAddSkybox skybox: Skybox) {
        scene.skybox = skybox
        skyboxs.append(skybox)
        segmentIndex = 2
        sceneNodesTableView.reloadData()
    }
}

// MARK: - EditViewControllerDelegate
extension SceneViewController: EditViewControllerDelegate {
    func editViewController(_ editViewController: EditViewController, didEditNode node: Node) {
        scene.remove(node: node)
        scene.add(node: node)
        reloadNodes()
    }
    
    func editViewController(_ editViewController: EditViewController, didEditLight light: Light, origin: Light) {
//        guard let index = (scene.lights.firstIndex{ $0 === origin }) else  { return }
    }
    
    func editViewConttoller(_ editViewController: EditViewController, didEditSkybox skybox: Skybox) {
        scene.skybox = skybox
        skyboxs.removeAll()
        skyboxs.insert(skybox, at: 0)
        segmentIndex = 2
        sceneNodesTableView.reloadData()
    }
}

// MARK: - NSTableViewDataSource, NSTableViewDelegate
extension SceneViewController: NSTableViewDataSource, NSTableViewDelegate {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        let index = self.segmentIndex
        
        if index == 0 {
            return nodes.count
        } else if index == 1 {
            return scene.lights.count
        } else if index == 2 {
            return skyboxs.count
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
        } else if index == 2 {
            let identifier = NSUserInterfaceItemIdentifier("SkyboxTextfield")
            var textfield = tableView.makeView(withIdentifier: identifier, owner: nil) as? NSTextField
            if textfield == nil {
                textfield = NSTextField()
                textfield?.identifier = identifier
            }
            
            let skybox = skyboxs[row]
            textfield?.stringValue = skybox.name
            view = textfield
        }
        
        return view
    }
}
