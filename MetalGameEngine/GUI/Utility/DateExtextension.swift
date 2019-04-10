//
//  DateExtextension.swift
//  GUI
//
//  Created by 张思槐 on 2019/4/10.
//  Copyright © 2019 张思槐. All rights reserved.
//

import Foundation

extension Date {
    static let dateFormatter = DateFormatter()
    
    func yyyyMMdd(joined: String = "-") -> String {
        let dateFormat = ["yyyy", "MM", "dd"].joined(separator: joined)
        return dateString(format: dateFormat)
    }
    
    func HHmm(joined: String = ":") -> String {
        let dateFormat = ["HH", "mm"].joined(separator: joined)
        return dateString(format: dateFormat)
    }
    
    private func dateString(format: String) -> String {
        Date.dateFormatter.dateFormat = format
        let dateString = Date.dateFormatter.string(from: self)
        return dateString
    }
}
