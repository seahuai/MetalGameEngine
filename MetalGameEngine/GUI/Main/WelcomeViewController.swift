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
        var title: String
        var lastModifiedDate: String
    }
    
    var rowDatas: [RowData] = []
    
    @IBAction func newSceneAction(_ sender: NSButton) {
        self.presentAsModalWindow(creatNewSceneViewController)
    }
    
    @IBOutlet weak var historyTableView: NSTableView! {
        didSet {
            self.historyTableView.dataSource = self
            self.historyTableView.delegate = self
            self.historyTableView.rowHeight = 44
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        creatNewSceneViewController.delegete = self
    }
}

extension WelcomeViewController: CreatNewSceneViewControllerDelegate {
    func creatNewSceneViewController(viewController: CreatNewSceneViewController, didCreatScene name: String, renderType: RenderType) {
        
    }
}

extension WelcomeViewController: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return 10
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let column = tableColumn else { return nil }
        
        column.width = tableView.bounds.width
        column.title = "场景"
        
        var cell = tableView.makeView(withIdentifier: HistorySceneCellView.identifier, owner: nil) as? HistorySceneCellView
        if cell == nil {
            cell = HistorySceneCellView(frame: CGRect(x: 0, y: 0, width: column.width, height: 88))
            cell?.identifier = HistorySceneCellView.identifier
        }
        
        return cell
    }
}

