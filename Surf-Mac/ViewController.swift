//
//  ViewController.swift
//  Surf-Mac
//
//  Created by abigt on 15/12/22.
//  Copyright © 2015年 abigt. All rights reserved.
//

import Cocoa
import NetworkExtension
import AppKit
import SFSocket
import Xcon
import XRuler
//import SFSocket
func SSLog<T>(_ object: T, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
    //let fn = file.split { $0 == "/" }.last
    let fn = file.split { $0 == "/" }.map(String.init).last
    if let f = fn {
        let info = "\(f).\(function)[\(line)]:\(object)"
        NSLog(info)
    }
}
class MainViewController: NSViewController {

    @IBOutlet weak var hostField: NSTextField!
    @IBOutlet weak var portField: NSTextField!
    @IBOutlet weak var method: NSTextField!
    @IBOutlet weak var password: NSSecureTextField!
    @IBOutlet weak var actionButton: NSButton!
    @IBOutlet weak var statusView: NSImageView!
    var targetManager : NEVPNManager?
    
    //var proxy:SFProxy  = SFProxy.init(name: "Proxy", type: .SS, address: "", port: ""  , passwd:"", method: "", tls: false)
    
    @IBAction func saveServer(_ sender: AnyObject) {
        
        
        if let proxy = SFProxy.create(name: "server", type: .SS, address:self.hostField.stringValue, port: self.portField.stringValue, passwd: self.password.stringValue, method: self.method.stringValue, tls: false) {
            _ = ProxyGroupSettings.share.addProxy(proxy)
            do {
                try ProxyGroupSettings.share.save()
            }catch let e {
                print("\(e.localizedDescription)")
            }
        }else {
            //todo
        }
        
    }
    var  logUrl:NSURL = {
       

        let url = fm.containerURL(forSecurityApplicationGroupIdentifier: groupIdentifier)!
        return url.appendingPathComponent("Log") as NSURL
    }()
    
    /// A list of NEVPNManager objects for the packet tunnel configurations.
    var managers = [NEVPNManager]()
    override func viewDidLoad() {
        super.viewDidLoad()
        reloadManagers() 
        // Do any additional setup after loading the view.
    }
    
    @IBAction func showLog(_ sender: AnyObject) {
        
        NSWorkspace.shared.open(logUrl as URL)
        
    }
    @IBAction func showLogUseTerminal(_ sender: AnyObject) {
        
        if  NSWorkspace.shared.openFile(logUrl.path!, withApplication:"Terminal") {
            
        }else {
            SSLog("can't open")
        }
        
    }
    @IBAction func showAppDir(_ sender: AnyObject) {
        //let urls = FileManager.default.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let url = Bundle.main.bundleURL
        if  NSWorkspace.shared.openFile(url.path, withApplication:"Terminal") {
            
        }else {
            //SSLog("can't open")
        }
    }
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func reloadManagers() {
        SFVPNManager.shared.loadManager {[weak self] (m, error) in
            if let _ = m {
                 SFVPNManager.shared.xpc()
                if let ss = self {
                    ss.observeStatus()
                    ss.actionButton.isEnabled = true
                }
            }
           
            
        }
    }
    
 
    func readImage(name:String) ->NSImage?{
        
        guard let p = Bundle.main.path(forResource:name, ofType: "png")else {
            return nil
        }
        return NSImage(contentsOfFile: p)
   
    }
    func refreshProfile(){
        
    }
    func showStatus(_ status:NEVPNStatus){
        
        switch status{
        case .disconnected:
            statusView.image =  NSImage.init(named:NSImage.Name(rawValue: "GrayDot"))
            SSLog("Disconnected")
        case .invalid:
            statusView.image = NSImage.init(named: NSImage.Name(rawValue: "RedDot"))
            SSLog("Invalid")
        case .connected:
            statusView.image = NSImage.init(named:NSImage.Name(rawValue: "GreenDot"))
            SSLog("Connected")
        case .connecting:
            statusView.image = NSImage.init(named:NSImage.Name(rawValue: "GreenDot"))
            SSLog("Connecting")
        case .disconnecting:
            statusView.image = NSImage.init(named:NSImage.Name(rawValue: "RedDot"))
            SSLog("Disconnecting")
        case .reasserting:
            statusView.image = NSImage.init(named:NSImage.Name(rawValue: "RedDot"))
            SSLog("Reasserting")
        }
        
        
    }
    /// Register for configuration change notifications.
    func observeStatus() {
        if let m = SFVPNManager.shared.manager{
            NotificationCenter.default.addObserver(forName: NSNotification.Name.NEVPNStatusDidChange, object: m.connection, queue: OperationQueue.main, using: { [weak self ] notification in
                //self.tableView.reloadRowsAtIndexPaths([ NSIndexPath(forRow: index, inSection: 0) ], withRowAnimation: .Fade)
                print(index)
                if let s = self{
                    s.showStatus(m.connection.status)
                }
                print(m.connection.status)
           })
        }
    }
    /// De-register for configuration change notifications.
    func stopObservingStatus() {
        if let m = SFVPNManager.shared.manager {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NEVPNStatusDidChange, object: m.connection)
        }
        
    }
    @IBAction func connectVPN(_ sender: AnyObject){
        do {
             _ = try SFVPNManager.shared.startStopToggled("")
        }catch _ {
           
        }
        
    }
    
    
    @IBAction func addVPN(_ sender: AnyObject) {
        _ = SFVPNManager.shared.loadManager { [weak self](manager, error) in
            
            if let strong = self, let manager = manager {
                strong.test(manager)
            }
            
        }
     
    }
    func test(_ mangaer:NETunnelProviderManager){
        
    }
}

