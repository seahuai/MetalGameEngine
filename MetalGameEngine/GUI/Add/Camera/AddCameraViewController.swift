//
//  AddCameraViewController.swift
//  GUI
//
//  Created by 张思槐 on 2019/4/11.
//  Copyright © 2019 张思槐. All rights reserved.
//

import Cocoa

class AddCameraViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}


extension AddCameraViewController: AddNodeVaildable {
    var isVaild: Bool {
        return false
    }
}
