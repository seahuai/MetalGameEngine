//
//  HistorySceneCellView.swift
//  GUI
//
//  Created by 张思槐 on 2019/4/10.
//  Copyright © 2019 张思槐. All rights reserved.
//

import Cocoa

class HistorySceneCellView: NSTableCellView {
    
    static let identifier = NSUserInterfaceItemIdentifier("HistorySceneCellView")
    
    var titleTextField: NSTextField!
    var lastModifiedTextField: NSTextField!
    var separator: CALayer!
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        self.identifier = HistorySceneCellView.identifier
        
        titleTextField = NSTextField()
        titleTextField.isEditable = false
        titleTextField.isBezeled = false
        titleTextField.backgroundColor = NSColor.clear
        
        lastModifiedTextField = NSTextField()
        lastModifiedTextField.isEditable = false
        lastModifiedTextField.isBezeled = false
        lastModifiedTextField.textColor = NSColor.lightGray
        lastModifiedTextField.backgroundColor = NSColor.clear
        lastModifiedTextField.font = NSFont.systemFont(ofSize: 10)
        
        separator = CALayer()
        separator.backgroundColor = NSColor.lightGray.withAlphaComponent(0.3).cgColor
        
        self.addSubview(titleTextField)
        self.addSubview(lastModifiedTextField)
    }
    
    override func layout() {
        super.layout()
        let boundsSize = self.bounds.size
        let padding: CGFloat = 5
        let margin: CGFloat = 2
        
        separator.frame = CGRect(x: padding, y: 0, width: boundsSize.width - padding, height: 1)
        
        lastModifiedTextField.frame = CGRect(x: padding, y: 0, width: boundsSize.width - 2 * padding, height: 18)
        titleTextField.frame.size.height = 20
        titleTextField.frame.size.width = lastModifiedTextField.bounds.width
        titleTextField.frame.origin.x = padding
        titleTextField.frame.origin.y = lastModifiedTextField.frame.maxY + margin
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        if separator.superlayer == nil {
            self.layer?.addSublayer(separator)
        }
    }
    
}
