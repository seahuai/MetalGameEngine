//
//  AddAreaLightViewController.swift
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/5/2.
//  Copyright © 2019 张思槐. All rights reserved.
//

import Cocoa

class AddAreaLightViewController: AddLightBaseViewController, EditableViewContoller {
    
    var isEdit = false
    
    @IBOutlet weak var positionInputView: VectorInputView!
    @IBOutlet weak var upInputView: VectorInputView!
    @IBOutlet weak var rightInputView: VectorInputView!
    @IBOutlet weak var forwardInputView: VectorInputView!
    @IBOutlet weak var lightColorWell: NSColorWell!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        setupData()
    }
    
    private func setupData() {
        if let light = self.light {
            positionInputView.float3Value = light.position
            upInputView.float3Value = light.up
            rightInputView.float3Value = light.right
            forwardInputView.float3Value = light.forward
            lightColorWell.color = NSColor(deviceRed: CGFloat(light.color.x),
                                           green: CGFloat(light.color.y),
                                           blue: CGFloat(light.color.z),
                                           alpha: 1.0)
        } else {
            setupDefaultValue()
        }
    }
    
    private func setupDefaultValue() {
        upInputView.float3Value = [0, 0.25, 0]
        rightInputView.float3Value = [0.25, 0, 0]
        forwardInputView.float3Value = [0, 0, -1]
    }
}

extension AddAreaLightViewController: AddNodeVaildable {
    func checkVaild() -> (isVaild: Bool, errorMsg: String?) {
        return (false, "")
    }
}
