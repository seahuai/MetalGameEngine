//
//  AddModelViewController.swift
//  GUI
//
//  Created by 张思槐 on 2019/4/11.
//  Copyright © 2019 张思槐. All rights reserved.
//

import Cocoa

class AddModelViewController: NSViewController {
    
    var model: Model?
    var parentNode: Node?
    
    var parentNodes: [Node] = []
    
    private var parentNodeNames: [String] = []
    private var objModelNames: [String] = []
    
    @IBOutlet weak var modelNameTextField: NSTextField!
    @IBOutlet weak var postitionTextfield: VectorInputView!
    @IBOutlet weak var selectModelButton: NSPopUpButton!
    @IBOutlet weak var selectParentNodeButton: NSPopUpButton!
    
    @IBAction func selectModelButtonClick(_ sender: NSPopUpButton) {
        changePopUpButtonTitle(titles: objModelNames, sender: sender)
    }
    
    @IBAction func selectParentNodeButtonClick(_ sender: NSPopUpButton) {
        changePopUpButtonTitle(titles: parentNodeNames, sender: sender)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        setupItems()
    }
    
    private func setupItems() {
        selectModelButton.removeAllItems()
        selectParentNodeButton.removeAllItems()
        
        objModelNames = FileTool.filesNames(extension: "obj")
        selectModelButton.addItem(withTitle: "选择")
        selectModelButton.addItems(withTitles: objModelNames)
        
        parentNodeNames = parentNodes.map{ $0.name }
        parentNodeNames.insert("无", at: 0)
        selectParentNodeButton.addItem(withTitle: "选择")
        selectParentNodeButton.addItems(withTitles: parentNodeNames)
    }
    
    private func changePopUpButtonTitle(titles: [String], sender: NSPopUpButton) {
        let index = sender.indexOfSelectedItem
        let title = titles[index - 1]
        sender.title = title
    }
    
}

extension AddModelViewController: AddNodeVaildable {
    
    func checkVaild() -> (isVaild: Bool, errorMsg: String?) {
    
        if selectModelButton.indexOfSelectedItem <= 0 || selectParentNodeButton.indexOfSelectedItem <= 0 {
            return (false, "信息不完整")
        }
        
        let name = modelNameTextField.stringValue
        if parentNodeNames.contains(name) {
            return (false, "名称 \"\(name)\" 已存在")
        }
        
        let selectModelButtonIndex = selectModelButton.indexOfSelectedItem
        let objFileName = objModelNames[selectModelButtonIndex - 1]
        
        // 如果 model 未空才创建新的对象
        if self.model == nil {
            guard let model = Model(name: objFileName) else {
                return (false, "创建失败")
            }
            self.model = model
        }
        
        let selectParentNodeButtonIndex = selectParentNodeButton.indexOfSelectedItem
        let index = selectParentNodeButtonIndex - 1
        var parentNode: Node? = nil
        if index >= 1 {
            parentNode = parentNodes[index - 1]
        }
        
        self.model!.position = postitionTextfield.float3Value
        self.model!.name = name
        self.parentNode = parentNode
        
        return (true, nil)
    }
}
