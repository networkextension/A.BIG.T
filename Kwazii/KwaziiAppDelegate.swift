//
//  AppDelegate.swift
//  Kwazii
//
//  Created by abigt on 2018/1/17.
//  Copyright © 2018年 A.BIG.T. All rights reserved.
//

import Cocoa
let appgroup = "745WQDK4L7.com.abigt.Surf"
import XRuler
import Xcon
import Sparkle
import Fabric
import Crashlytics
@NSApplicationMain
class KwaziiAppDelegate: NSObject, NSApplicationDelegate,NSMenuDelegate {

    var configWindow:PreferencesWindowController!
    var helpWindow:HelpWindowController!
    var  updateWindows:UpdateWindowController!
    var serversMenuItem:NSMenu!
    @IBAction func addProxy(_ sender:Any){
        if configWindow  == nil {
            configWindow = PreferencesWindowController(windowNibName: NSNib.Name(rawValue: "PreferencesWindowController"))
        }
        configWindow.showWindow(self)
        NSApp.activate(ignoringOtherApps: true)
        configWindow.window?.makeKeyAndOrderFront(self)
    }

    @IBAction func openHelp(_ sender: Any) {
        if helpWindow  == nil {
            helpWindow = HelpWindowController(windowNibName: NSNib.Name(rawValue: "HelpWindow"))
        }
        helpWindow.showWindow(self)
        NSApp.activate(ignoringOtherApps: true)
        helpWindow.window?.makeKeyAndOrderFront(self)
    }
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        Fabric.with([Crashlytics.self])
        
       // Fabric.with([Answers.self])
        Answers.logCustomEvent(withName: "Kwazii",
                               customAttributes: [
                                "Started": "",
                                
                                ])
        // Insert code here to initialize your application
        var url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appgroup)!
      
        if !FileManager.default.fileExists(atPath: url.path){
           try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            
        }else {
            print("exist \(url)")
        }
        
        
        url.appendPathComponent("abigt.conf")
        if !FileManager.default.fileExists(atPath: url.path){
            let p = Bundle.main.path(forResource: "abigt.conf", ofType: nil)
            try! FileManager.default.copyItem(at: URL.init(fileURLWithPath: p!), to: url)
        }else {
            print("\(url)")
        }
        XRuler.groupIdentifier = appgroup
        SFSettingModule.setting.config(url.path)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    
    func menuNeedsUpdate(_ menu: NSMenu){
        if serversMenuItem == nil{
            serversMenuItem = menu
        }
        self.updateServersMenu(true)
    }

    
    func updateServersMenu(_ update:Bool) {
    
        
        
        guard let menu = serversMenuItem else {return}
        menu.removeAllItems()
        var index = 0
        let profile = ProxyGroupSettings.share
        for p in profile.proxys {
            var title = ""
            if profile.showCountry {
                
                if !p.serverIP.isEmpty{
                    let rusult  = Country.setting.geoIPRule(ipString: p.serverIP)
                    
                    p.countryFlag = rusult.emoji
                    p.isoCode = rusult.isoCode
                    title += p.countryFlag
                }else {
                    hostToIP(proxy: p)
                }
                
                
            }
            if p.proxyName.isEmpty {
                title += p.serverAddress + ":" + p.serverPort
                
            }else {
                title += p.proxyName + "(" + p.serverAddress + ":" + p.serverPort + ")"
            }
            let em = NSMenuItem(title: title, action: #selector(KwaziiAppDelegate.selectServer(_:)), keyEquivalent: "")
            em.tag = index
            if ProxyGroupSettings.share.selectIndex == index {
                em.state = NSControl.StateValue(rawValue: 1)
                
            }else {
                em.state = NSControl.StateValue(rawValue: 0)
            }
            index += 1
            menu.addItem(em)
        }
        menu.addItem(NSMenuItem.separator())
       // menu.addItem(withTitle: "Open Server Preferences ...", action: #selector(AppDelegate.openProxySConfig(_:)), keyEquivalent: "c")
    }
    @objc func selectServer(_ sender:NSMenuItem){
        let index = sender.tag
        print("-----\(sender.tag)")
        ProxyGroupSettings.share.selectIndex = index
        
    }
    func hostToIP(proxy:SFProxy)  {
        dnsqueue.async(execute:{ [weak self ] in
            guard let strong = self else {return}
            
            guard let hostInfo = gethostbyname2((proxy.serverAddress as NSString).utf8String, AF_INET)else {
                return
            }
            
            
            
            
            let len = hostInfo.pointee.h_length
            let aa = hostInfo.pointee.h_addr_list[0]
            var ip = ""
            
            for i in 0 ..< len {
                let x = (aa! + Int(i)).pointee
                if i == (len - 1) {
                    ip += "\(strong.toUint(signed: x))"
                    break
                }
                ip += "\(strong.toUint(signed: x))."
                
            }
            proxy.serverIP = ip
            DispatchQueue.main.async(execute: {
                self!.updateServersMenu(false)
            })
            
        })
        
        
        //return ip
    }
    func toUint(signed: Int8) -> UInt8 {
        
        let unsigned = signed >= 0 ?
            UInt8(signed) :
            UInt8(signed  - Int8.min) + UInt8(Int8.max) + 1
        
        return unsigned
    }
    let dnsqueue:DispatchQueue = DispatchQueue(label:"com.abigt.dns")
    @IBAction func openRule(_ sender:Any){
        let url = fm.containerURL(forSecurityApplicationGroupIdentifier: groupIdentifier)!.appendingPathComponent("abigt.conf")
        
        NSWorkspace.shared.open(url)
    }
    @IBAction func openCheckUpdate(_ sender:Any){
        if updateWindows  == nil {
            updateWindows = UpdateWindowController(windowNibName: NSNib.Name(rawValue: "SUUpdateSettingsWindowController"))
        }
        updateWindows.showWindow(self)
        NSApp.activate(ignoringOtherApps: true)
        updateWindows.window?.makeKeyAndOrderFront(self)
    }
    var updater: SUUpdater!
    @IBAction func checkUpdate(_ sender:Any){
        if updater == nil {
            updater = SUUpdater()
        }
        updater.checkForUpdates(nil)
    }
}

