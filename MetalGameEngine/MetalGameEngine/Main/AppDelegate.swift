//
//  AppDelegate.swift
//  MetalGameEngine
//
//  Created by 张思槐 on 2019/3/16.
//  Copyright © 2019 张思槐. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        guard let device = MTLCreateSystemDefaultDevice(),
            let commandQueue = device.makeCommandQueue() else {
                fatalError("GPU not available")
        }
        
        Renderer.device = device
        Renderer.library = device.makeDefaultLibrary()
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

