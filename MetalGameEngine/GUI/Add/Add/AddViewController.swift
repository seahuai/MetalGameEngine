//
//  AddViewController.swift
//  GUI
//
//  Created by 张思槐 on 2019/4/11.
//  Copyright © 2019 张思槐. All rights reserved.
//

import Cocoa

protocol AddViewControllerDelegate: class {
    func addViewController(_ viewController: AddViewController, didAddNode node: Node, parentNode: Node?)
    func addViewController(_ viewController: AddViewController, didAddLight light: Light)
    func addViewController(_ viewController: AddViewController, didAddSkybox skybox: Skybox)
}

class AddViewController: NSViewController {
    
    weak var delegate: AddViewControllerDelegate?
    
    var paretnNodes: [Node] = []

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
        guard let viewController = self.viewController as? AddNodeVaildable else {
            fatalError()
        }
        
        let vaildInformation = viewController.checkVaild()
        
        guard vaildInformation.isVaild else {
            if let errorMsg = vaildInformation.errorMsg {
                let alert = NSAlert(error: InvaildError.inputInvaildError)
                alert.messageText = "创建失败"
                alert.informativeText = errorMsg
                alert.runModal()
            }
            return
        }
        
        if let vc = viewController as? AddModelViewController {
            let model = vc.model!
            let parentNode = vc.parentNode
            delegate?.addViewController(self, didAddNode: model, parentNode: parentNode)
        }
        
        if let vc = viewController as? AddCameraViewController {
            let camera = vc.camera!
            let parentNode = vc.parentNode
            delegate?.addViewController(self, didAddNode: camera, parentNode: parentNode)
        }
        
        if let vc = viewController as? AddLightViewController {
            let light = vc.lightNode.light
            delegate?.addViewController(self, didAddLight: light)
        }
        
        if let vc = viewController as? AddSkyboxViewController {
            let skybox = vc.skybox!
            delegate?.addViewController(self, didAddSkybox: skybox)
        }
        
        if let vc = viewController as? AddTerrainViewController {
            let terrain = vc.terrain!
            delegate?.addViewController(self, didAddNode: terrain, parentNode: nil)
        }
        
        self.dismiss(self)
        
    }
    
    @IBAction func cancelButtonDidClick(_ sender: NSButton) {
        self.dismiss(self)
    }
    
    
    private var viewControllerTypes: [NSViewController.Type] =
        [
            AddModelViewController.self,
            AddLightViewController.self,
            AddCameraViewController.self,
            AddSkyboxViewController.self,
            AddTerrainViewController.self
        ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "添加"
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        self.segmentedControlValueChanged(sender: self.addTypeSegmentedControl)
    }
    
    @objc func segmentedControlValueChanged(sender: NSSegmentedControl) {
        let index = sender.selectedSegment
        
        viewController?.view.removeFromSuperview()
        viewController?.removeFromParent()
        
        viewController = viewControllerTypes[index].init()
        
        // TODO: Optimize
        (viewController as? AddModelViewController)?.parentNodes = self.paretnNodes
        (viewController as? AddCameraViewController)?.parentNodes = self.paretnNodes
        
        addChild(viewController!)
        containerView.addSubview(self.viewController!.view)
        viewController?.view.frame = containerView.bounds
    }
    
}
