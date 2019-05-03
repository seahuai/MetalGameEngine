//
//  AddModelViewController.swift
//  GUI
//
//  Created by 张思槐 on 2019/4/11.
//  Copyright © 2019 张思槐. All rights reserved.
//

import Cocoa

class AddModelViewController: AddModelBaseViewController, EditableViewContoller {
    
    var isEdit = false
    
    private var parentNodeNames: [String] = []
    private var objModelNames: [String] = []
    
    @IBOutlet weak var modelNameTextField: NSTextField!
    @IBOutlet weak var postitionTextfield: VectorInputView!
    @IBOutlet weak var selectModelButton: NSPopUpButton!
    @IBOutlet weak var selectParentNodeButton: NSPopUpButton!
    @IBOutlet weak var checkingCollideButton: NSButton!
    
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
        
        setupData()
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
    
    private func setupData() {
        guard let model = self.model as? Model else { return }
        
        modelNameTextField.stringValue = model.name
        
        postitionTextfield.x = model.position.x
        postitionTextfield.y = model.position.y
        postitionTextfield.z = model.position.z
        
        selectModelButton.isEnabled = !isEdit
        selectParentNodeButton.isEnabled = !isEdit
        
        if isEdit {
            if let fileName = model.fileName {
                selectModelButton.title = fileName
            }
            
            selectParentNodeButton.title = model.parent?.name ?? "无"
        }
        
        checkingCollideButton.state = model.isCheckingCollide ? .on : .off
    }
    
    private func changePopUpButtonTitle(titles: [String], sender: NSPopUpButton) {
        let index = sender.indexOfSelectedItem
        let title = titles[index - 1]
        sender.title = title
    }
    
}

extension AddModelViewController: AddNodeVaildable {
    
    func checkVaild() -> (isVaild: Bool, errorMsg: String?) {
        
        let name = modelNameTextField.stringValue
        if parentNodeNames.contains(name) {
            return (false, "名称 \"\(name)\" 已存在")
        }
        
        if !isEdit {
            if selectModelButton.indexOfSelectedItem <= 0 || selectParentNodeButton.indexOfSelectedItem <= 0 {
                return (false, "信息不完整")
            }
            
            let selectModelButtonIndex = selectModelButton.indexOfSelectedItem
            let objFileName = objModelNames[selectModelButtonIndex - 1]
            
            guard let model = Model(name: objFileName) else {
                return (false, "创建失败")
            }
            model.isCheckingCollide = checkingCollideButton.state == .on
            self.model = model
            let selectParentNodeButtonIndex = selectParentNodeButton.indexOfSelectedItem
            let index = selectParentNodeButtonIndex - 1
            var parentNode: Node? = nil
            if index >= 1 {
                parentNode = parentNodes[index - 1]
            }
            self.parentNode = parentNode
        }
        
        self.model!.position = postitionTextfield.float3Value
        self.model!.name = name
        
        return (true, nil)
    }
}
