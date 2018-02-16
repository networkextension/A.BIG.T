//
//  AdvancedWindowController.swift
//  Surf
//
//  Created by abigt on 2016/11/22.
//  Copyright © 2016年 abigt. All rights reserved.
//

import Cocoa
import SFSocket
import XRuler
class AdvancedWindowController: NSWindowController {

    @IBOutlet weak var historyButton:NSButton!
    @IBOutlet weak var flagButton:NSButton!
    @IBOutlet weak var iCloudButton:NSButton!
    override func windowDidLoad() {
        super.windowDidLoad()
        if ProxyGroupSettings.share.showCountry {
            flagButton.state = NSControl.StateValue(rawValue: 1)
        }else {
            flagButton.state = NSControl.StateValue(rawValue: 0)
        }
        if ProxyGroupSettings.share.historyEnable {
            historyButton.state = NSControl.StateValue(rawValue: 1)
        }else {
            historyButton.state = NSControl.StateValue(rawValue: 0)
        }
        if ProxyGroupSettings.share.iCloudSyncEnabled(){
            iCloudButton.state = NSControl.StateValue(rawValue: 1)
        }else {
            iCloudButton.state = NSControl.StateValue(rawValue: 0)
        }
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    func alertMesage(_ msg:String){
        let alert = NSAlert.init()
        alert.addButton(withTitle: "OK")
        
        alert.messageText = msg
        alert.icon = NSImage.init(named: NSImage.Name(rawValue: "AppIcon"))
        alert.alertStyle = .warning
        alert.beginSheetModal(for: self.window!, completionHandler: { (r) in
            print(r)
        })
    }
    @IBAction func ok(_ sender:AnyObject){
        if historyButton.state.rawValue == 1 {
            ProxyGroupSettings.share.historyEnable = true
        }else {
            ProxyGroupSettings.share.historyEnable = false
        }
        if flagButton.state.rawValue == 1 {
            ProxyGroupSettings.share.showCountry = true
        }else {
            ProxyGroupSettings.share.showCountry = false
        }
        
        let x = UserDefaults.standard.object(forKey: "com.yarshure.surf.UbiquityIdentityToken")
        if x == nil {
            iCloudButton.state = NSControl.StateValue(rawValue: 0)
            alertMesage("Invalid iCloud token")
        }
        if iCloudButton.state.rawValue == 1 {
            let delegate = NSApp.delegate as! AppDelegate
            delegate.sync()
            
            ProxyGroupSettings.share.saveiCloudSync(true)
        }else {
            ProxyGroupSettings.share.saveiCloudSync(false)
        }
        do {
            try ProxyGroupSettings.share.save()
        }catch let e {
            alertMesage(e.localizedDescription)
        }
        
        window?.performClose(nil)
    }
    
}
