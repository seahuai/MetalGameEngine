//
//  AddTerrainViewController.swift
//  GUI
//
//  Created by 张思槐 on 2019/4/11.
//  Copyright © 2019 张思槐. All rights reserved.
//

import Cocoa

class AddTerrainViewController: NSViewController {

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
            return (true, nil)
        } else {
            return (false, nil)
        }
    }
    
}

