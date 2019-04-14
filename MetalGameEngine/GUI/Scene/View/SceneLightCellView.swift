//
//  SceneLightCellView.swift
//  GUI
//
//  Created by 张思槐 on 2019/4/14.
//  Copyright © 2019 张思槐. All rights reserved.
//

import Cocoa

class SceneLightCellView: NSView {
    
    static let identifier = NSUserInterfaceItemIdentifier("SceneLightCellView")
    
    var light: Light! {
        didSet {
            
            var iconName: String?
            var lightName: String?
            
            switch light.type {
            case Sunlight:
                iconName = "sunlight"
                lightName = "直射光"
            case Spotlight:
                iconName = "spotlight"
                lightName = "聚光灯光"
            case Ambientlight:
                iconName = "ambientlight"
                lightName = "环境光"
            case Pointlight:
                iconName = "pointlight"
                lightName = "点光源"
            default:
                break
            }
            
            guard let _iconName = iconName, let _lightName = lightName else { fatalError() }
            
            let image = NSImage(named: _iconName)!
            self.iconImageView.image = image
            
            self.label.stringValue = _lightName
            
            needsLayout = true
        }
    }
    
    var iconImageView: NSImageView!
    var label: NSTextField!
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        initializeSubviews()
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        
        initializeSubviews()
    }
    
    
    private func initializeSubviews() {
        iconImageView = NSImageView()
        
        label = NSTextField()
        label.isEditable = false
        label.isBezeled = false
        label.backgroundColor = NSColor.clear
        
        addSubview(iconImageView)
        addSubview(label)
    }
    
    override func layout() {
        super.layout()
        
        let boundsSize = self.bounds.size
        let margin: CGFloat = 3
        let padding: CGFloat = 5
        
        let iconImageViewHeight: CGFloat = 16
        let iconImageViewY = (boundsSize.height - iconImageViewHeight) * 0.5
        iconImageView.frame = CGRect(x: padding, y: iconImageViewY, width: iconImageViewHeight, height: iconImageViewHeight)
        iconImageView.layer?.cornerRadius = 5
        
        label.sizeToFit()
        let labelY = (boundsSize.height - label.frame.height) * 0.5
        label.frame.origin = CGPoint(x: iconImageView.frame.maxX + margin, y: labelY)
        label.frame.size.width = (boundsSize.width - iconImageView.frame.maxX - padding - margin)
    }
    
}
