//
//  VectorInputView.swift
//  GUI
//
//  Created by 张思槐 on 2019/4/12.
//  Copyright © 2019 张思槐. All rights reserved.
//

import Cocoa
import simd

@IBDesignable
class VectorInputView: NSView {
    
    @IBInspectable var margin: CGFloat = 3 {
        didSet {
            needsLayout = true
        }
    }
    
    
    @IBInspectable var width: Int = 3 {
        didSet {
            if self.width <= 0 || self.width > 4 {
                self.width = 4
            }
            reload()
        }
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        initializeSubViews()
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        
        initializeSubViews()
    }
    
    var float: Float {
        return self.values[0]
    }
    
    var float2Value: float2 {
        return float2(self.values[0], self.values[1])
    }
    
    var float3Value: float3 {
        return float3(self.values[0], self.values[1], self.values[2])
    }
    
    var float4Value: float4 {
        return float4(self.values[0], self.values[1], self.values[2], self.values[3])
    }
    
    var values: [Float] {
        var values: [Float] = []
        for textField in self.textFields {
            let stringValue = textField.stringValue
            if let floatValue = Float(stringValue) {
                values.append(floatValue)
            } else {
                values.append(0)
            }
        }
        return values
    }
    
    var x: Float = 0 {
        didSet {
            textFields[0].floatValue = x
        }
    }
    
    var y: Float = 0 {
        didSet {
            textFields[1].floatValue = x
        }
    }
    
    var z: Float = 0 {
        didSet {
            textFields[2].floatValue = x
        }
    }
    
    var w: Float = 0 {
        didSet {
            textFields[3].floatValue = x
        }
    }
    
    private var placeholders = ["X", "Y", "Z", "W"]
    
    private var textFields: [NSTextField] = []
    
    private func initializeSubViews() {
        for i in 0..<4 {
            let textField = inputTextField()
            textField.placeholderString = placeholders[i]
            addSubview(textField)
            textFields.append(textField)
        }
        
        reload()
    }
    
    private func reload() {
        textFields.forEach{ $0.isHidden = true }
        
        for i in 0..<width {
            textFields[i].isHidden = false
        }
    }
    
    private func inputTextField() -> NSTextField {
        let textField = NSTextField()
        textField.formatter = OnlyNumericFormatter()
        textField.alignment = .center
        textField.maximumNumberOfLines = 1
        return textField
    }
    
    override func layout() {
        super.layout()
        
        let viewHeight = self.bounds.height
        
        let w: CGFloat = 44
        let h: CGFloat = 22
        
        for i in 0..<textFields.count {
            
            let x = (w + margin) * CGFloat(i)
            let y = (viewHeight - h) * 0.5
            let view = textFields[i]
            view.frame = CGRect(x: x, y: y, width: w, height: h)
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    
}
