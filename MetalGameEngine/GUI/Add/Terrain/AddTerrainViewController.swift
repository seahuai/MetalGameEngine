//
//  AddTerrainViewController.swift
//  GUI
//
//  Created by 张思槐 on 2019/4/11.
//  Copyright © 2019 张思槐. All rights reserved.
//

import Cocoa

class AddTerrainViewController: NSViewController {
    
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
            
            terrain = Terrain(heightMapName: inputTextfield.stringValue, size: size, height: height)
            return (true, nil)
        } else {
            return (false, nil)
        }
    }
}

