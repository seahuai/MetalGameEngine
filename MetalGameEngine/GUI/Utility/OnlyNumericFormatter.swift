//
//  OnlyNumericFormatter.swift
//  GUI
//
//  Created by 张思槐 on 2019/4/12.
//  Copyright © 2019 张思槐. All rights reserved.
//

import Cocoa

class OnlyNumericFormatter: NumberFormatter {
    
    var isMinusEnabled = true
    
    override func isPartialStringValid(_ partialString: String, newEditingString newString: AutoreleasingUnsafeMutablePointer<NSString?>?, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        if partialString.isEmpty {
            return true
        }
        
        if isMinusEnabled && partialString == "-"  {
            return true
        }
       
        // Actual check
        return Float(partialString) != nil
    }

}
