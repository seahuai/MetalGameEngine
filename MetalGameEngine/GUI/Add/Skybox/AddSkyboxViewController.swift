//
//  AddSkyboxViewController.swift
//  GUI
//
//  Created by 张思槐 on 2019/4/11.
//  Copyright © 2019 张思槐. All rights reserved.
//

import Cocoa

class AddSkyboxViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}

extension AddSkyboxViewController: AddNodeVaildable {
    var isVaild: Bool {
        return false
    }
}

