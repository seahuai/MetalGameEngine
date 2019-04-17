//
//  AddTerrainViewController.swift
//  GUI
//
//  Created by 张思槐 on 2019/4/11.
//  Copyright © 2019 张思槐. All rights reserved.
//

import Cocoa

class AddTerrainViewController: NSViewController, EditableViewContoller {
    
    var isEdit: Bool = false
    
    var terrain: Terrain!

    @IBOutlet weak var inputTextfield: NSTextField!
    @IBOutlet weak var positionInputView: VectorInputView!
    @IBOutlet weak var warningLabel: NSTextField!
    @IBOutlet weak var heightTextField: NSTextField!
    @IBOutlet weak var sizeXTextField: NSTextField!
    @IBOutlet weak var sizeZTextField: NSTextField!
    @IBOutlet weak var previewLabel: NSTextField!
    @IBOutlet weak var previewImageView: NSImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inputTextfield.delegate = self
        
        let formatter = OnlyNumericFormatter()
        formatter.isMinusEnabled = false
        heightTextField.formatter = formatter
        sizeXTextField.formatter = formatter
        sizeZTextField.formatter = formatter
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        setupData()
    }
    
    private func setupData() {
        guard let terrain = self.terrain else { return }
        
        inputTextfield.stringValue = terrain.name
        
        positionInputView.float3Value = terrain.position
        heightTextField.floatValue = terrain.height
        sizeXTextField.floatValue = terrain.patchSize.x
        sizeZTextField.floatValue = terrain.patchSize.y
        previewImageView.image = NSImage(named: terrain.name)
    }
    
}

extension AddTerrainViewController: NSTextFieldDelegate {
    func controlTextDidEndEditing(_ obj: Notification) {
        let textFiled = obj.object as? NSTextField
        if textFiled == inputTextfield {
            warningLabel.stringValue = ""
            let imageName = inputTextfield.stringValue
            if !imageName.isEmpty {
                if let image = NSImage(named: imageName) {
                    previewImageView.image = image
                } else {
                    warningLabel.stringValue = "未找到 \(imageName)"
                }
            } else {
                warningLabel.stringValue = "不得为空"
            }
        }
    }
}

extension AddTerrainViewController: AddNodeVaildable {
    func checkVaild() -> (isVaild: Bool, errorMsg: String?) {
        if let _ = previewImageView.image {
            let size: float2 = [sizeXTextField.floatValue, sizeZTextField.floatValue]
            let height = heightTextField.floatValue
            
            if height == Float.zero {
                return(false, "高度不能为 0")
            }
            
            if size == float2.zero {
                return(false, "尺寸不能为 0")
            }
            
            // for safe
            let imageName = inputTextfield.stringValue
            if imageName.isEmpty {
                return (false, "")
            }
                
            // 如果图片不一样则需重新创建对象
            if self.terrain == nil || self.terrain.name != imageName {
                terrain = Terrain(heightMapName: imageName, size: size, height: height)
            } else {
                terrain.patchSize = size
                terrain.height = height
            }
            
            terrain.position = positionInputView.float3Value
            
            return (true, nil)
        } else {
            return (false, nil)
        }
    }
}

