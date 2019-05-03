//
//  AddRayTracingModelViewController.swift
//  GUI
//
//  Created by 张思槐 on 2019/5/2.
//  Copyright © 2019 张思槐. All rights reserved.
//

import Cocoa

class AddRayTracingModelViewController: AddModelBaseViewController, EditableViewContoller {
    
    var isEdit: Bool = false
    
    private var objModelNames: [String] = []

    @IBOutlet weak var nameTextfield: NSTextField!
    @IBOutlet weak var positionInputView: VectorInputView!
    @IBOutlet weak var selectModelButton: NSPopUpButton!
    
    @IBAction func selectModelButtonnClick(_ sender: NSPopUpButton) {
        changePopUpButtonTitle(titles: objModelNames, sender: sender)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        setupItem()
        setupData()
    }
    
    private func setupItem() {
        selectModelButton.removeAllItems()
        
        objModelNames = FileTool.filesNames(extension: "obj")
        selectModelButton.addItem(withTitle: "选择")
        selectModelButton.addItems(withTitles: objModelNames)
    }
    
    private func setupData() {
        guard let model = self.model as? RayTracingModel else { return }
        positionInputView.float3Value = model.position
        nameTextfield.stringValue = model.name
        selectModelButton.title = model.fileName ?? ""
        selectModelButton.isEnabled = !isEdit
    }
    
    private func changePopUpButtonTitle(titles: [String], sender: NSPopUpButton) {
        let index = sender.indexOfSelectedItem
        let title = titles[index - 1]
        sender.title = title
    }
    
}

extension AddRayTracingModelViewController: AddNodeVaildable {
    func checkVaild() -> (isVaild: Bool, errorMsg: String?) {
        
        if nameTextfield.stringValue.isEmpty {
            return (false, "名字不能为空")
        }
        
        if isEdit {
            model.position = positionInputView.float3Value
            model.name = nameTextfield.stringValue
        } else {
            if selectModelButton.indexOfSelectedItem <= 0 {
                return (false, "信息不完整")
            }
            
            let fileName = objModelNames[selectModelButton.indexOfSelectedItem - 1]
            model = RayTracingModel(name: fileName)
            model.name = nameTextfield.stringValue
            model.position = positionInputView.float3Value
        }
        
        return (true, nil)
    }
}
