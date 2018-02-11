//
//  MainWindow.swift
//  Kwazii
//
//  Created by abigt on 2018/1/17.
//  Copyright © 2018年 A.BIG.T. All rights reserved.
//

import Cocoa

class MainWindow: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
        
        //window?.titleVisibility = .hidden
        //window?.titlebarAppearsTransparent = true
        
       // window?.styleMask.insert(.fullSizeContentView)
       //disable close
        window?.styleMask.remove(.closable)
        //window?.styleMask.remove(.fullScreen)
        //window?.styleMask.remove(.miniaturizable)
        //window?.styleMask.remove(.resizable)
        //NSWindow.StyleMask(rawValue: NSWindow.StyleMask.RawValue(~(UInt8(NSClosableWindowMask.rawValue) | UInt8(NSMiniaturizableWindowMask.rawValue) | UInt8(NSResizableWindowMask.rawValue))))
//        let st = NSStoryboard.init(name: NSStoryboard.Name(rawValue: "RequestBasic"), bundle:nil)
//        let vc = self.storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "request")) as! RequestsVC
//        //let vc = st.instantiateInitialController() as! RequestsVC
//        self.window!.contentView?.addSubview(vc.view)
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    @IBAction func addProxy(_ sender:Any){
    
    }
    @IBAction func cancel(_ sender: NSButton) {
        //window?.performClose(self)
    }
}
