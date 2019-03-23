//
//  ViewController.swift
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/3/16.
//  Copyright © 2019 张思槐. All rights reserved.
//

import Cocoa
import MetalKit

struct Data {
    let title: String
    let vcClass: NSViewController.Type
}

class ViewController: NSViewController {
    
    @IBOutlet weak var contentView: NSView!
    
    @IBOutlet weak var tableView: NSTableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
    
    var currentIndex = -1
    var viewController: NSViewController?
    
    let datas: [Data] = [
        Data(title: "模型（.obj）加载", vcClass: LoadObjectViewController.self)
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidLayout() {
        super.viewDidLayout()
    }
    
    func selected(at index: Int){
        guard index != currentIndex else { return }
        
        self.viewController?.removeFromParent()
        
        let data = datas[index]
        
        let title = data.title
        print("select \(title)")
        
        let vcClass = data.vcClass
        let viewController = vcClass.init(nibName: nil, bundle: nil)
        
        self.addChild(viewController)
        viewController.view.frame = contentView.bounds
        
        contentView.subviews.forEach{ $0.removeFromSuperview() }
        
        contentView.addSubview(viewController.view)
        
        self.viewController = viewController
    }

}

// MARK: - NSTableViewDataSource
extension ViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return datas.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var cellView: NSView?
        
        guard let identifier = tableColumn?.identifier else { return nil; }
        
        if identifier.rawValue == "FunctionCell" {
            tableColumn?.width = tableView.bounds.width
            let cell = tableView.makeView(withIdentifier: identifier, owner: nil) as? NSTableCellView
            cell?.textField?.stringValue = datas[row].title
            cellView = cell
        }
        
        return cellView
    }
}

// MARK: - NSTableViewDelegate
extension ViewController: NSTableViewDelegate {
    func tableViewSelectionDidChange(_ notification: Notification) {
        let selectedRow = tableView.selectedRow
        
        selected(at: selectedRow)
    }
}


