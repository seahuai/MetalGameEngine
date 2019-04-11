//
//  AddViewController.swift
//  GUI
//
//  Created by 张思槐 on 2019/4/11.
//  Copyright © 2019 张思槐. All rights reserved.
//

import Cocoa

class AddViewController: NSViewController {

    @IBOutlet weak var addTypeSegmentedControl: NSSegmentedControl! {
        didSet {
            self.addTypeSegmentedControl.target = self
            self.addTypeSegmentedControl.action = #selector(segmentedControlValueChanged(sender:))
            self.addTypeSegmentedControl.selectedSegment = 0
        }
    }
    
    @IBOutlet weak var containerView: NSView! {
        didSet {
            let layer = CALayer()
            layer.frame = containerView.bounds
            containerView.layer = layer
            layer.cornerRadius = 5
            layer.backgroundColor = NSColor.black.withAlphaComponent(0.2).cgColor
        }
    }
    
    private var viewController: NSViewController?
    
    @IBOutlet weak var doneButton: NSButton!
    
    @IBAction func doneButtonDidClick(_ sender: NSButton) {
        
    }
    
    
    @IBAction func cancelButtonDidClick(_ sender: NSButton) {
        self.dismiss(self)
    }
    
    
    private var viewControllers: [NSViewController] =
        [
            AddModelViewController(),
            AddLightViewController(),
            AddCameraViewController(),
            AddSkyboxViewController(),
            AddTerrainViewController()
        ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for vc in viewControllers {
            self.addChild(vc)
        }
        
        self.segmentedControlValueChanged(sender: self.addTypeSegmentedControl)
        
        self.title = "添加"
    }
    
    @objc func segmentedControlValueChanged(sender: NSSegmentedControl) {
        let index = sender.selectedSegment
        
        viewController?.view.removeFromSuperview()
        
        viewController = viewControllers[index]
        
        containerView.addSubview(self.viewController!.view)
        viewController?.view.frame = containerView.bounds
    }
    
}
