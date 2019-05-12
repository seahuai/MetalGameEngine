//
//  CreatNewSceneViewController.swift
//  GUI
//
//  Created by 张思槐 on 2019/4/10.
//  Copyright © 2019 张思槐. All rights reserved.
//

import Cocoa

protocol CreatNewSceneViewControllerDelegate: class {
    func creatNewSceneViewController(viewController: CreatNewSceneViewController,
                                     didCreatScene name: String,
                                     renderType: RenderType,
                                     open: Bool)
}

class CreatNewSceneViewController: NSViewController {
    
    weak var delegete: CreatNewSceneViewControllerDelegate?
    
    private var shaderTypeIndex = 0
    
    private var renderType: RenderType = .unknown
    
    private var shaders = ["选择", "正向渲染", "延迟渲染", "光线追踪"]

    @IBOutlet weak var sceneNameTextField: NSTextField! {
        didSet {
            sceneNameTextField.delegate = self
        }
    }
    
    @IBOutlet weak var sceneShaderSelectButton: NSPopUpButton!
    
    @IBOutlet weak var doneButton: NSButton!
    
    @IBOutlet weak var cancelButton: NSButton!
    
    @IBOutlet weak var openImmediatelyCheckBox: NSButton!
    
    @IBAction func done(_ sender: NSButton) {
        
        self.dismiss(self)
        
        delegete?.creatNewSceneViewController(viewController: self, didCreatScene: self.sceneNameTextField.stringValue, renderType: renderType, open: openImmediatelyCheckBox.state == .on)

    }
    
    @IBAction func cancel(_ sender: NSButton) {
        self.dismiss(self)
    }
    
    @IBAction func selectShaderType(_ sender: NSPopUpButton) {
        shaderTypeIndex = sender.indexOfSelectedItem
        if shaderTypeIndex == 1 { renderType = .rasterization}
        if shaderTypeIndex == 2 { renderType = .deffered }
        if shaderTypeIndex == 3 { renderType = .rayTracing }
        sender.title = shaders[shaderTypeIndex]
        reloadDoneButtonState()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "创建新场景"
        
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
