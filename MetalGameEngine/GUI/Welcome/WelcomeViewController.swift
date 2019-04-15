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
        let data = RowData(scene: scene, renderType: renderType, lastModifiedDateText: dateString)
        rowDatas.append(data)
        
        if open {
            openScene(rowData: data)
        }
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

