//
//  Utility.swift
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/3/27.
//  Copyright © 2019 张思槐. All rights reserved.
//

import Foundation

func random(range: CountableClosedRange<Int>) -> Int {
    var offset = 0
    if range.lowerBound < 0 {
        offset = abs(range.lowerBound)
    }
    let min = UInt32(range.lowerBound + offset)
    let max = UInt32(range.upperBound + offset)
    return Int(min + arc4random_uniform(max-min)) - offset
}
