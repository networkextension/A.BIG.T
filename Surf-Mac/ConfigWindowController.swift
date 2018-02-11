//
//  ConfigWindowController.swift
//  Surf
//
//  Created by 孔祥波 on 21/11/2016.
//  Copyright © 2016 abigt. All rights reserved.
//

import Cocoa

class ConfigWindowController: NSWindowController,NSTableViewDelegate,NSTableViewDataSource {

    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    deinit {
        print("window deinit")
    }
}
