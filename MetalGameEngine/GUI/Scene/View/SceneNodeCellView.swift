//
//  SceneNodeCellView.swift
//  GUI
//
//  Created by 张思槐 on 2019/4/12.
//  Copyright © 2019 张思槐. All rights reserved.
//

import Cocoa

class SceneNodeCellView: NSView {
    
    static let identifier = NSUserInterfaceItemIdentifier("SceneNodeCellView")
    
    var node: Node! {
        didSet {
            
        }
    }
    
    private var hierarchyLabel: NSTextField!
    
    private var typeLabel: NSTextField!
    
    private var nameLabel: NSTextField!
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        initializeSubviews()
        
        self.identifier = SceneNodeCellView.identifier
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initializeSubviews() {
        hierarchyLabel = NSTextField()
        hierarchyLabel.isEditable = false
        hierarchyLabel.isBezeled = false
        hierarchyLabel.maximumNumberOfLines = 1
        hierarchyLabel.alignment = .center
        hierarchyLabel.backgroundColor = NSColor.lightGray
        hierarchyLabel.font = NSFont.systemFont(ofSize: 12, weight: .bold)
        addSubview(hierarchyLabel)
        
        typeLabel = NSTextField()
        typeLabel.isEditable = false
        typeLabel.isBezeled = false
        typeLabel.maximumNumberOfLines = 1
        typeLabel.alignment = .center
        typeLabel.backgroundColor = NSColor.darkGray
        typeLabel.font = NSFont.systemFont(ofSize: 12, weight: .bold)
        addSubview(typeLabel)
        
        nameLabel = NSTextField()
        nameLabel.isEditable = false
        nameLabel.isBezeled = false
        nameLabel.maximumNumberOfLines = 1
        nameLabel.backgroundColor = NSColor.clear
        addSubview(nameLabel)
        
        hierarchyLabel.stringValue = "111"
        typeLabel.stringValue = "M"
        nameLabel.stringValue = "魔性信息学理性"
    }
    
    override func layout() {
        super.layout()
        
        let boundsSize = self.bounds.size
        let padding: CGFloat = 5
        let margin: CGFloat = 3
        let height: CGFloat = 16
        
        hierarchyLabel.sizeToFit()
        hierarchyLabel.frame.origin = CGPoint(x: padding, y: padding)
        hierarchyLabel.frame.size.height = height
        hierarchyLabel.layer?.cornerRadius = 2
        
        typeLabel.sizeToFit()
        typeLabel.frame.origin = CGPoint(x: hierarchyLabel.frame.maxX + margin, y: hierarchyLabel.frame.origin.y)
        typeLabel.frame.size.height = height
        typeLabel.layer?.cornerRadius = 2
        
        nameLabel.frame.origin = CGPoint(x: typeLabel.frame.maxX + margin, y: padding)
        nameLabel.frame.size = CGSize(width: boundsSize.width - padding - typeLabel.frame.maxX - margin, height: height)
    }
    
}
