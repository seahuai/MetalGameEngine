//
//  Error.swift
//  GUI
//
//  Created by 张思槐 on 2019/4/10.
//  Copyright © 2019 张思槐. All rights reserved.
//

import Cocoa

enum InvaildError: Error {
    case inputInvaildError
    case custom(String)
}
