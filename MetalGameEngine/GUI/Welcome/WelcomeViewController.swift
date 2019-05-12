//
//  ViewController.swift
//  GUI
//
//  Created by 张思槐 on 2019/4/10.
//  Copyright © 2019 张思槐. All rights reserved.
//

import Cocoa

class WelcomeViewController: NSViewController {
    
    var creatNewSceneViewController = CreatNewSceneViewController()
    
    struct RowData {
        var scene: Scene
        var renderType: RenderType
        var lastModifiedDateText: String
    }
    
    var rowDatas: [RowData] = [] {
        didSet {
            historyTableView.reloadData()
            historyTableView.needsDisplay = true
        }
    }
    
    @IBAction func newSceneAction(_ sender: NSButton) {
        self.presentAsModalWindow(creatNewSceneViewController)
    }
    
    @IBOutlet weak var historyTableView: NSTableView! {
        didSet {
            self.historyTableView.dataSource = self
            self.historyTableView.delegate = self
            self.historyTableView.rowHeight = 44
            self.historyTableView.doubleAction = #selector(tableViewDoubleClickRow(tableView:))
            self.historyTableView.tableColumns.first?.width = self.historyTableView.bounds.width
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        creatNewSceneViewController.delegete = self
        
        self.title = "Metal 游戏引擎"
    }
    
    func openScene(rowData: RowData) {
        let vc = SceneViewController(rowData.scene, renderType: rowData.renderType)
        let sceneWindow = NSWindow(contentViewController: vc)
        sceneWindow.makeKeyAndOrderFront(NSApp)
    }
}

extension WelcomeViewController: CreatNewSceneViewControllerDelegate {
    func creatNewSceneViewController(viewController: CreatNewSceneViewController, didCreatScene name: String, renderType: RenderType, open: Bool) {
        let date = Date()
        let dateString = date.yyyyMMdd() + " " + date.HHmm()
        let scene = Scene()
        scene.name = name
        createDefaultModels(renderType: renderType, scene: scene)
        let data = RowData(scene: scene, renderType: renderType, lastModifiedDateText: dateString)
        rowDatas.append(data)
        
        if open {
            openScene(rowData: data)
        }
    }
    
    func createDefaultModels(renderType: RenderType, scene: Scene) {
        switch renderType {
        case .rasterization:
            
            let plane = Model(name: "large-plane")!
            plane.tiling = 16
            
            let tree = Model(name: "tree")!
            let cottage = Model(name: "cottage1")!
            
            tree.position = [-2, 0, 0]
            cottage.position = [2, 0, 0]

            scene.add(node: plane)
            scene.add(node: tree, parentNode: plane)
            scene.add(node: cottage, parentNode: plane)
            
            let skybox = Skybox(textureName: "redSky")
            scene.skybox = skybox
            
            let camera = Camera()
            camera.name = "Camera"
            camera.position = [0, 1, -6]
            scene.add(node: camera)
            
            var sunlight = createDefaultLight()
            sunlight.position = [0, 3, 0.2]
            sunlight.type = Sunlight
            
            var otherLight = createDefaultLight()
            otherLight.position = camera.position
            otherLight.type = Sunlight
 
            var ambientLight = createDefaultLight()
            ambientLight.type = Ambientlight
            
            scene.lights.append(sunlight)
            scene.lights.append(otherLight)
            scene.lights.append(ambientLight)
            
        case .deffered:
            
            let plane = Model(name: "plane")!
            plane.scale = [8, 8, 8]
            plane.tiling = 16
            
            let train = Model(name: "train")!
            train.position = [-1, 0, 0]
            
            let tree = Model(name: "treefir")!
            tree.position = [1, 0, 0]
            
            scene.add(node: plane)
            scene.add(node: train)
            scene.add(node: tree)
            
            let camera = Camera()
            camera.name = "Camera"
            camera.position = [0, 1, -3]
//            camera.rotation = [-0.5, 0, 0]
            scene.add(node: camera)
            
            var sunlight = createDefaultLight()
            sunlight.type = Sunlight
            sunlight.position = [0, 4, -5]
            scene.lights.append(sunlight)
            
            let numbers = 2
            for _ in 0..<numbers {
                scene.lights.append(createRandomLight())
            }
            
        case .rayTracing:
            let train = RayTracingModel(name: "train")!
            let plane = RayTracingModel(name: "plane")!

            scene.add(node: train)
            scene.add(node: plane)
            
            var light = Light()
            light.type = Sunlight
            light.position = float3(0, 2, -1)
            light.forward = float3(0.0, -1.0, 0.0)
            light.right = float3(0.25, 0.0, 0.0)
            light.up = float3(0.0, 0.0, 0.25)
            light.color = float3(repeating: 2)
            light.isAreaLight = 1
            scene.lights.append(light)
            
            let camera = Camera()
            camera.name = "Camera"
            camera.position = [0, 1, -1.5]
            scene.add(node: camera)
            
        default:
            break
        }
    }
    
    func createDefaultLight() -> Light {
        var light = Light()
        /*255,250,205*/
        light.color = float3(x: 1.0, y: 250/255.0, z: 205/255.0)
        light.specularColor = light.color
        light.intensity = 0.1
        return light
    }
    
    func createRandomLight() -> Light {
        let min: float3 = [-5, 0.3, -5]
        let max: float3 = [5, 2.0, 5]
        
        let colors: [float3] = [
            float3(1, 0, 0),
            float3(1, 1, 0),
            float3(1, 1, 1),
            float3(0, 1, 0),
            float3(0, 1, 1),
            float3(0, 0, 1),
            float3(0, 1, 1),
            float3(1, 0, 1) ]
        
        var newMin: float3 = [min.x*100, min.y*100, min.z*100]
        var newMax: float3 = [max.x*100, max.y*100, max.z*100]
        
        let x = Float(random(range: Int(newMin.x)...Int(newMax.x))) * 0.01
        let y = Float(random(range: Int(newMin.y)...Int(newMax.y))) * 0.01
        let z = Float(random(range: Int(newMin.z)...Int(newMax.z))) * 0.01
        
        var light = Light()
        light.position = [x, y, z]
        light.color = colors[random(range: 0...colors.count)]
        light.intensity = 0.6
        light.attenuation = float3(1.5, 1, 1)
        light.type = Pointlight
        
        return light
    }
 
}

extension WelcomeViewController: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return rowDatas.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let column = tableColumn,
            column.identifier.rawValue == "HistoryDataColumn" else { return nil }
        
        column.title = "场景"
        
        var cell = tableView.makeView(withIdentifier: HistorySceneCellView.identifier, owner: nil) as? HistorySceneCellView
        if cell == nil {
            cell = HistorySceneCellView(frame: CGRect(x: 0, y: 0, width: column.width, height: 88))
            cell?.identifier = HistorySceneCellView.identifier
        }
        
        let rowData = rowDatas[row]
        cell?.titleTextField.stringValue = rowData.scene.name
        cell?.lastModifiedTextField.stringValue = rowData.lastModifiedDateText
        
        return cell
    }
    
    @objc func tableViewDoubleClickRow(tableView: NSTableView) {
        let clickedRow = tableView.clickedRow
        let rowData = rowDatas[clickedRow]
        openScene(rowData: rowData)
        updateRowDataLastModifiedDate(at: clickedRow)
    }
    
    
    private func updateRowDataLastModifiedDate(at index: Int) {
        if index >= rowDatas.count || index < 0 { return }
        let date = Date()
        let dateString = date.yyyyMMdd() + " " + date.HHmm()
        rowDatas[index].lastModifiedDateText = dateString
    }
}

