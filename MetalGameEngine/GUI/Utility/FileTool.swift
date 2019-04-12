//
//  FileTool.swift
//  GUI
//
//  Created by 张思槐 on 2019/4/12.
//  Copyright © 2019 张思槐. All rights reserved.
//

import Foundation

class FileTool {
    
    static func filesNames(extension: String) -> [String] {
        let urls = Bundle.main.urls(forResourcesWithExtension: `extension`, subdirectory: nil) ?? []
        let lastPathComponents = urls.map{ $0.lastPathComponent }
        let names = lastPathComponents.compactMap{ $0.split(separator: ".").first }
        return names.map{ String($0) }
    }
    
    
}
