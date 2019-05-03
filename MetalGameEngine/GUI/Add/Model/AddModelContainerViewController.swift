//
//  AddModelContainerViewController.swift
//  GUI
//
//  Created by 张思槐 on 2019/5/2.
//  Copyright © 2019 张思槐. All rights reserved.
//

import Cocoa

class AddModelBaseViewController: NSViewController {
    var model: Node!
    var parentNode: Node?
    var parentNodes: [Node] = []
}

class AddModelContainerViewController: NSViewController, EditableViewContoller {
    
    var model: Node!
    
    var parentNode: Node?
    var parentNodes: [Node] = []
    
    var isEdit = false
    
    var isRayTracing = false
    
    var vc: (AddModelBaseViewController & AddNodeVaildable & EditableViewContoller)!

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        vc = isRayTracing ? AddRayTracingModelViewController() : AddModelViewController()
        
        vc.model = model
        vc.isEdit = isEdit
        vc.parentNodes = parentNodes
        
        self.addChild(vc)
        self.view.addSubview(vc.view)
        vc.view.frame = self.view.bounds
    }
    
}

extension AddModelContainerViewController: AddNodeVaildable {
    func checkVaild() -> (isVaild: Bool, errorMsg: String?) {
        let msg = vc.checkVaild()
        model = vc.model
        parentNode = vc.parentNode
        return msg
    }
}
