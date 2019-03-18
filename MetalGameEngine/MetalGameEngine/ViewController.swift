//
//  ViewController.swift
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/3/16.
//  Copyright © 2019 张思槐. All rights reserved.
//

import Cocoa
import MetalKit

class ViewController: NSViewController {
    
    @IBOutlet weak var contentView: NSView!
    
    @IBOutlet weak var tableView: NSTableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
    
    var mtkView: MTKView!
    var renderer: Renderer!
    
    let titles = ["基本图形加载", "模型加载", "光照渲染"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mtkView = MTKView()
        contentView.addSubview(mtkView)
        renderer = LoadObjectRenderer(metalView: mtkView)
    }

    override func viewDidLayout() {
        super.viewDidLayout()
        
        mtkView.frame = contentView.bounds
    }

}

// MARK: - NSTableViewDataSource
extension ViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var cellView: NSView?
        
        guard let identifier = tableColumn?.identifier else { return nil; }
        
        if identifier.rawValue == "FunctionCell" {
            tableColumn?.width = tableView.bounds.width
            let cell = tableView.makeView(withIdentifier: identifier, owner: nil) as? NSTableCellView
            cell?.textField?.stringValue = titles[row]
            cellView = cell
        }
        
        return cellView
    }
}

// MARK: - NSTableViewDelegate
extension ViewController: NSTableViewDelegate {
    func tableViewSelectionDidChange(_ notification: Notification) {
        let selectedRow = tableView.selectedRow
        print(titles[selectedRow])
    }
}



