//
//  AddModelViewController.swift
//  GUI
//
//  Created by 张思槐 on 2019/4/11.
//  Copyright © 2019 张思槐. All rights reserved.
//

import Cocoa

class AddModelViewController: NSViewController {
    
    struct ModelInformation {
        var modelName: String?
        var objFileName: String?
        var parentNode: Node?
        var position: float3 = [0 ,0, 0]
    }
    
    var modelInformation: ModelInformation = ModelInformation()
  
    var parentNodes: [Node] = []
    
    private var parentNodeNames: [String] = []
    private var objModelNames: [String] = []
    
    @IBOutlet weak var modelNameTextField: NSTextField!
    
    @IBOutlet weak var postitionTextfield: VectorInputView!
    
    @IBOutlet weak var selectModelButton: NSPopUpButton!
    
    @IBOutlet weak var selectParentNodeButton: NSPopUpButton!
    
    @IBAction func selectModelButtonClick(_ sender: NSPopUpButton) {
        changePopUpButtonTitle(titles: objModelNames, sender: sender)
        
        modelInformation.objFileName = objModelNames[sender.indexOfSelectedItem - 1]
    }
    
    @IBAction func selectParentNodeButtonClick(_ sender: NSPopUpButton) {
        changePopUpButtonTitle(titles: parentNodeNames, sender: sender)
        
        let index = sender.indexOfSelectedItem
        if index >= 1 {
            modelInformation.parentNode = parentNodes[index - 1]
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        selectParentNodeButton.addItems(withTitles: parentNodeNames)
    }
    
    private func changePopUpButtonTitle(titles: [String], sender: NSPopUpButton) {
        let index = sender.indexOfSelectedItem
        let title = titles[index - 1]
        sender.title = title
    }
    
}

extension AddModelViewController: AddNodeVaildable {
    var isVaild: Bool {
        
        if !modelNameTextField.stringValue.isEmpty {
            modelInformation.modelName = modelNameTextField.stringValue
        }
        
        return !modelNameTextField.stringValue.isEmpty
    }
}
