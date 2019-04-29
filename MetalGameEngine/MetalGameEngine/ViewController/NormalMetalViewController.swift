//
//  NormalMetalViewController.swift
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/3/19.
//  Copyright © 2019 张思槐. All rights reserved.
//

import MetalKit

class NormalMetalViewController: NSViewController {
    
    var renderer: Renderer!

    var mtkView: GameView
    
    override func loadView() {
        self.view = NSView()
        self.view.postsFrameChangedNotifications = true
    }
    
    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        
        mtkView = GameView()
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(mtkView)
        
        addGestureRecognizer()
        
        NotificationCenter.default.addObserver(forName: NSView.frameDidChangeNotification, object: self.view, queue: OperationQueue.main) { notification in
            self.viewChangeSize(view: self.view)
        }
    }
    
    func viewChangeSize(view: NSView) {
        self.mtkView.frame = self.view.bounds
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        
        mtkView.frame = self.view.bounds
    }
    
    private func addGestureRecognizer() {
        let pan = NSPanGestureRecognizer(target: self, action: #selector(handlePan(gesture:)))
        mtkView.addGestureRecognizer(pan)
    }
    
    @objc func handlePan(gesture: NSPanGestureRecognizer) {
        let x = Float(gesture.translation(in: gesture.view).x)
        let y = Float(gesture.translation(in: gesture.view).y)
        let translation = float2(x, y)
        gesturePan(translation)
        gesture.setTranslation(.zero, in: gesture.view)
    }
    
    // need override
    func gesturePan(_ translation: float2) {}
}
