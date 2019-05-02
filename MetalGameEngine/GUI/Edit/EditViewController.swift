//
//  EditViewController.swift
//  GUI
//
//  Created by 张思槐 on 2019/4/16.
//  Copyright © 2019 张思槐. All rights reserved.
//

import Cocoa

protocol EditViewControllerDelegate: class {
    func editViewController(_ editViewController: EditViewController, didEditNode node: Node)
    func editViewConttoller(_ editViewController: EditViewController, didEditSkybox skybox: Skybox)
    func editViewController(_ editViewController: EditViewController, didEditLight light: Light)
}

class EditViewController: NSViewController {
    
    @IBOutlet weak var containerView: NSView!
    
    @IBAction func doneButtonClick(_ sender: NSButton) {
        guard let vaildVC = viewController as? AddNodeVaildable,
            vaildVC.checkVaild().isVaild else {
            self.dismiss(self)
            return
        }
        
        if let vc = viewController as? AddModelViewController
        {
            delegate?.editViewController(self, didEditNode: vc.model!)
        }
        else if let vc = viewController as? AddCameraViewController
        {
            delegate?.editViewController(self, didEditNode: vc.camera)
        }
        else if let vc = viewController as? AddLightViewController
        {
            delegate?.editViewController(self, didEditLight: vc.light)
        }
        else if let vc = viewController as? AddTerrainViewController
        {
            delegate?.editViewController(self, didEditNode: vc.terrain)
        }
        else if let vc = viewController as? AddSkyboxViewController
        {
            delegate?.editViewConttoller(self, didEditSkybox: vc.skybox)
        }
        
        self.dismiss(self)
    }
    
    weak var delegate: EditViewControllerDelegate?
    
    var viewController: NSViewController?
    
    var editObject: Any?
    
    private func configureView(with object: Any) {
        
        viewController?.view.removeFromSuperview()
        
        if let model = object as? Model
        {
            let addModelVC = AddModelViewController()
            addModelVC.model = model
            viewController = addModelVC
        }
        else if let camera = object as? Camera
        {
            let addCameraVC = AddCameraViewController()
            addCameraVC.camera = camera
            viewController = addCameraVC
        }
        else if let light = object as? Light
        {
            let isAreaLight = light.isAreaLight == 1
            let addLightVC = AddLightContainerViewController()
            addLightVC.isAreaLight = isAreaLight
            addLightVC.light = light
            viewController = addLightVC
        }
        else if let terrain = object as? Terrain
        {
            let addTerrainVC = AddTerrainViewController()
            addTerrainVC.terrain = terrain
            viewController = addTerrainVC
        }
        else if let skybox = object as? Skybox
        {
            let addSkyboxVC = AddSkyboxViewController()
            addSkyboxVC.skybox = skybox
            viewController = addSkyboxVC
        }
        
        guard let vc = viewController,
            var editVC = vc as? EditableViewContoller else { return }
        
        editVC.isEdit = true
        
        containerView.addSubview(vc.view)
        vc.view.frame = containerView.bounds
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        guard let editObject = self.editObject else {
            self.dismiss(self)
            return
        }
        
        configureView(with: editObject)
    }
    
}
