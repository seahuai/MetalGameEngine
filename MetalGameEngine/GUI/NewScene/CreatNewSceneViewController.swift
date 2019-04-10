//
//  CreatNewSceneViewController.swift
//  GUI
//
//  Created by 张思槐 on 2019/4/10.
//  Copyright © 2019 张思槐. All rights reserved.
//

import Cocoa

class CreatNewSceneViewController: NSViewController {
    
    var shaderTypeIndex = 0
    
    var shaders = ["选择", "Rasterization", "Ray Tracing", "Deffered Rendering"]

    @IBOutlet weak var sceneNameTextField: NSTextField! {
        didSet {
            sceneNameTextField.delegate = self
        }
    }
    
    @IBOutlet weak var sceneShaderSelectButton: NSPopUpButton!
    
    @IBOutlet weak var doneButton: NSButton!
    
    @IBOutlet weak var cancelButton: NSButton!
    
    @IBAction func done(_ sender: NSButton) {
        
        if shaderTypeIndex == 0 {
            let error: InvaildError = .inputInvaildError
            let alert = NSAlert(error: error)
            alert.messageText = "场景信息不完整"
            alert.informativeText = "未选择着色器类型"
            alert.runModal()
        }
        
        if sceneNameTextField.stringValue.isEmpty {
            let error: InvaildError = .inputInvaildError
            let alert = NSAlert(error: error)
            alert.messageText = "场景信息不完整"
            alert.informativeText = "场景名称不能为空"
            alert.runModal()
        }
        
    }
    
    @IBAction func cancel(_ sender: NSButton) {
        self.dismiss(self)
    }
    
    @IBAction func selectShaderType(_ sender: NSPopUpButton) {
        shaderTypeIndex = sender.indexOfSelectedItem
        sender.title = shaders[shaderTypeIndex]
        reloadDoneButtonState()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "创建场景"
        
        self.sceneShaderSelectButton.removeAllItems()
        self.sceneShaderSelectButton.addItems(withTitles: shaders)
    }
    
    private func reloadDoneButtonState() {
        self.doneButton.isEnabled = !self.sceneNameTextField.stringValue.isEmpty && shaderTypeIndex != 0
    }
    
}

extension CreatNewSceneViewController: NSTextFieldDelegate {
    func controlTextDidChange(_ obj: Notification) {
        reloadDoneButtonState()
    }
}
