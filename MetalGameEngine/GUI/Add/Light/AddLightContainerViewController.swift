//
//  AddLightContainerViewController.swift
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/5/2.
//  Copyright © 2019 张思槐. All rights reserved.
//

import Cocoa

class AddLightBaseViewController: NSViewController {
    var light: Light!
}

class AddLightContainerViewController: NSViewController, EditableViewContoller {
    
    var isAreaLight = false
    
    var isEdit = false
    
    var light: Light!
    
    var vc: (AddLightBaseViewController & EditableViewContoller & AddNodeVaildable)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
    }
    
    private func setup() {
        vc = isAreaLight ? AddAreaLightViewController() : AddLightViewController()
        
        vc.light = light
        vc.isEdit = isEdit
        
        self.addChild(vc)
        self.view.addSubview(vc.view)
        vc.view.frame = self.view.bounds
    }
}

extension AddLightContainerViewController: AddNodeVaildable {
    func checkVaild() -> (isVaild: Bool, errorMsg: String?) {
        let result = vc.checkVaild()
        
        light = vc.light
        
        return result
    }
}
