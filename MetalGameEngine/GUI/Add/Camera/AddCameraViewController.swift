//
//  AddCameraViewController.swift
//  GUI
//
//  Created by 张思槐 on 2019/4/11.
//  Copyright © 2019 张思槐. All rights reserved.
//

import Cocoa

class AddCameraViewController: NSViewController, EditableViewContoller {
    
    var isEdit: Bool = false
    
    var camera: Camera!
    var parentNode: Node?
    
    var parentNodes: [Node] = []
    private var parentNodeNames: [String] = []
    
    @IBOutlet weak var cameraNameTextField: NSTextField!
    @IBOutlet weak var positionInputView: VectorInputView!
    @IBOutlet weak var rotationInputView: VectorInputView!
    @IBOutlet weak var fovDegreeLabel: NSTextField!
    @IBOutlet weak var nearPlaneTextField: NSTextField! {
        didSet {
            self.nearPlaneTextField.formatter = OnlyNumericFormatter()
        }
    }
    @IBOutlet weak var farPlaneTextField: NSTextField! {
        didSet {
            self.farPlaneTextField.formatter = OnlyNumericFormatter()
        }
    }
    
    @IBOutlet weak var forDegreeSlider: NSSlider!
    @IBAction func fovDegreeSliderValueChanged(_ sender: NSSlider) {
        fovDegreeLabel.stringValue = "\(sender.integerValue)°"
    }
    
    @IBOutlet weak var selectParentNodeButton: NSPopUpButton!
    @IBAction func selectParentNodeButtonClick(_ sender: NSPopUpButton) {
        let index = sender.indexOfSelectedItem - 1
        sender.title = parentNodeNames[index]
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDefaultValues()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        setupItems()
        
        setupData()
    }
    
    private func setupItems() {
        parentNodeNames = parentNodes.map{ $0.name }
        parentNodeNames.insert("无", at: 0)
        selectParentNodeButton.removeAllItems()
        selectParentNodeButton.addItem(withTitle: "选择")
        selectParentNodeButton.addItems(withTitles: parentNodeNames)
    }
    
    private func setupData() {
        guard let camera = self.camera else { return }
        
        cameraNameTextField.stringValue = camera.name
        
        positionInputView.x = camera.position.x
        positionInputView.y = camera.position.y
        positionInputView.z = camera.position.z
        
        rotationInputView.x = camera.rotation.x
        rotationInputView.y = camera.rotation.y
        rotationInputView.z = camera.rotation.z
        
        selectParentNodeButton.isEnabled = !isEdit
        
        if isEdit {
            selectParentNodeButton.title = camera.parent?.name ?? "无"
        }
    }
    
    private func setupDefaultValues() {
        nearPlaneTextField.stringValue = "0.01"
        farPlaneTextField.stringValue = "150"
    }
    
}

extension AddCameraViewController: AddNodeVaildable {
    func checkVaild() -> (isVaild: Bool, errorMsg: String?) {
        let name = cameraNameTextField.stringValue
        if name.isEmpty {
            return (false, "名称不能为空")
        }
        
        if nearPlaneTextField.stringValue.isEmpty || farPlaneTextField.stringValue.isEmpty {
            return (false, "信息不完整")
        }
        
        if !isEdit {
            
            if selectParentNodeButton.indexOfSelectedItem <= 0 {
                return (false, "信息不完整")
            }
            
            self.camera = Camera()
            var parentNode: Node? = nil
            let index = selectParentNodeButton.indexOfSelectedItem - 1
            if index >= 1 {
                parentNode = parentNodes[index - 1]
            }
            
            self.parentNode = parentNode
        }
        
        camera.name = name
        camera.position = positionInputView.float3Value
        camera.rotation = rotationInputView.float3Value
        camera.near = nearPlaneTextField.floatValue
        camera.far = farPlaneTextField.floatValue
        camera.fovDegrees = Float(forDegreeSlider.integerValue)
        

        return (true, nil)
        
    }
}

