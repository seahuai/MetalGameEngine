//
//  AddNodeVaildable.swift
//  GUI
//
//  Created by 张思槐 on 2019/4/13.
//  Copyright © 2019 张思槐. All rights reserved.
//

import Foundation

protocol AddNodeVaildable {
    
    func checkVaild() -> (isVaild: Bool, errorMsg: String?)
}

extension AddNodeVaildable{
    func checkVaild() -> (isVaild: Bool, errorMsg: String?) {
        return (false, nil)
    }
}
