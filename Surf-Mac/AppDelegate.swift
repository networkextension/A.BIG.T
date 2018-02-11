//
//  AppDelegate.swift
//  Surf-Mac
//
//  Created by abigt on 15/12/22.
//  Copyright © 2015年 abigt. All rights reserved.
//

import Cocoa
import AxLogger
import NetworkExtension
import CoreImage
import SFSocket
import Fabric
import Crashlytics
import Xcon
import XRuler

fileprivate extension NSTouchBar.CustomizationIdentifier {
    
    static let touchBar = NSTouchBar.CustomizationIdentifier("com.ToolbarSample.touchBar")
}

fileprivate extension NSTouchBarItem.Identifier {
    
    static let popover = NSTouchBarItem.Identifier("com.ToolbarSample.TouchBarItem.popover")
    static let fontStyle = NSTouchBarItem.Identifier("com.ToolbarSample.TouchBarItem.fontStyle")
    static let popoverSlider = NSTouchBarItem.Identifier("com.ToolbarSample.popoverBar.slider")
}

@NSApplicationMain
//

class AppDelegate: NSResponder, NSApplicationDelegate,NSMenuDelegate ,NSTouchBarDelegate,BarcodeScanDelegate{
    weak var serversMenuItem: NSMenuItem?
    var  logUrl:URL = {
        
        
        let url = fm.containerURL(forSecurityApplicationGroupIdentifier: groupIdentifier)!
        return url.appendingPathComponent("Log")
    }()
    let dnsqueue:DispatchQueue = DispatchQueue(label:"com.abigt.dns")
    @IBOutlet weak var statusView: StatusView!
    var targetManager : NEVPNManager?
    var managers = [NEVPNManager]()
    var configWindow:PreferencesWindowController?
    var advancedWindos:AdvancedWindowController?
    var aboutWindow:AboutWindowController?
    var requestWindow:RequestsWindowController?
    var qrWindow:QrWindowController?
    var currentConfiguration: String?
    var barItem: NSStatusItem!
    var connectionButton:NSButton?
    var configurations: [String: (String, Bool)] = [:]
    var qr = QrController()
    
    func initMenuBar() {
        let icon = NSImage(named: NSImage.Name(rawValue: "GrayDot"))
        icon?.isTemplate = true
        barItem = NSStatusBar.system.statusItem(withLength: -1)
        barItem.view = self.statusView
        barItem.menu = NSMenu()
        barItem.menu!.delegate = self
    }
    @objc func qrScan(_ sender:AnyObject) {
        
        qr.delegate = self
         _  = qr.startReading()
    }
    func addProxy(_ sender:AnyObject){
        
    }
    func alertMsg(_ msg:String){
        let alert = NSAlert.init()
        alert.addButton(withTitle: "OK")
        //action.target = self
        //action.action = #selector(addProxy(_:))
      
        alert.messageText = msg
        
        alert.alertStyle = .warning
        
        let x = alert.runModal()
        print(x)
    }
    func barcodeScanDidScan(controller: QrController, configString:String) {
        print("qr string \(configString)")
       
        let alert = NSAlert.init()
        alert.addButton(withTitle: "Add")
        //action.target = self
        //action.action = #selector(addProxy(_:))
        alert.addButton(withTitle: "Cancle")
        alert.messageText = configString
        
        alert.alertStyle = .warning
        
        let x = alert.runModal()
        print(x)
        
        if !configString.isEmpty && x == NSApplication.ModalResponse.alertFirstButtonReturn{
            let proxy = SFProxy.createProxyWithURL(configString)
            if let p = proxy.proxy {
                _ = ProxyGroupSettings.share.addProxy(p)
            }else {
                alertMessage(message: proxy.message)
            }
            
        }
    }
    func barcodeScanCancelScan(controller: QrController){
        alertMessage(message: "Don't Found QrCode,Please Open QrCode Image and Retry!")
    }
    @IBAction  func pushMenu(_ sender:AnyObject){
        barItem.popUpMenu(barItem.menu!)
    }

    func reloadManagers() {
        SFVPNManager.shared.loadManager {[weak self] (m, error) in
            if let m = m {
                SFVPNManager.shared.xpc()
                if let ss = self {
                    ss.observeStatus()
                    if m.connection.status == .invalid {
                        SFNETunnelProviderManager.loadOrCreateDefaultWithCompletionHandler({ (m, e) in
                             ss.showStatus(m!.connection.status)
                            SFVPNManager.shared.manager = m
                        })
                    }else {
                        ss.showStatus(m.connection.status)
                    }
                    
                    
                    //ss.actionButton.isEnabled = true
                }
            }
            
            
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
    
    func readImage(name:String) ->NSImage?{
        
        guard let p = Bundle.main.path(forResource:name, ofType: "png")else {
            return nil
        }
        return NSImage(contentsOfFile: p)
        
    }
    @IBAction func addVPN(_ sender: AnyObject) {
        _ = SFVPNManager.shared.loadManager { [weak self](manager, error) in
            
            if let _ = self, let _ = manager {
                //strong.test(manager)
            }
            
        }
        
    }
    
    func showStatus(_ status:NEVPNStatus){
        
        switch status{
        case .disconnected:
            statusView.iconView.image =  NSImage(named:NSImage.Name(rawValue: "NSStatusPartiallyAvailable"))
            if let item = barItem.menu!.items.first{
                item.title = "Connect"
            }
            if let btn = connectionButton {
                btn.title = "Connect"
            }
        case .invalid:
            statusView.iconView.image = NSImage(named: NSImage.Name(rawValue: "NSStatusUnavailable"))
            SSLog("Invalid")
            if let item = barItem.menu!.items.first{
                item.title = "Invalid"
            }
            if let btn = connectionButton {
                btn.title = "Invalid"
            }
        case .connected:
            statusView.iconView.image = NSImage(named:NSImage.Name(rawValue: "NSStatusAvailable"))
            SSLog("Connected")
            if let item = barItem.menu!.items.first{
                item.title = "Disconnect"
            }
            if let btn = connectionButton {
                btn.title = "Disconnect"
            }
        case .connecting:
            statusView.iconView.image = NSImage(named:NSImage.Name(rawValue: "NSStatusAvailable"))
            SSLog("Connecting")
            if let item = barItem.menu!.items.first{
                item.title = "Connecting"
            }
            if let btn = connectionButton {
                btn.title = "Connecting"
            }
        case .disconnecting:
            statusView.iconView.image = NSImage(named:NSImage.Name(rawValue: "NSStatusAvailable"))
            
            if let item = barItem.menu!.items.first{
                item.title = "Disconnecting"
            }
            if let btn = connectionButton {
                btn.title = "Disconnecting"
            }
        case .reasserting:
            statusView.iconView.image = NSImage.init(named:NSImage.Name(rawValue: "NSStatusPartiallyAvailable"))
            
            if let item = barItem.menu!.items.first{
                item.title = "Reasserting"
            }
            if let btn = connectionButton {
                btn.title = "Reasserting"
            }
        }
        
        
    }
    @objc func startConfiguration(_ sender: NSMenuItem) {
    }
    func disconnect(_ sender: AnyObject? = nil) {
        
    }
    func buildMenuItemForManager(_ name: String, valid: Bool) -> NSMenuItem {
        let item = NSMenuItem(title: name, action: #selector(AppDelegate.startConfiguration(_:)), keyEquivalent: "")
        
        if name == currentConfiguration {
            item.state = NSControl.StateValue.on
        }
        
        if !valid {
            item.action = nil
        }
        
        return item
    }
    @objc func openProxySConfig(_ sender: AnyObject) {
        configWindow = PreferencesWindowController(windowNibName: NSNib.Name(rawValue: "PreferencesWindowController"))
        // preferencesWinCtrl = ctrl
        
        //let config = NSStoryboard.init(name: "Config", bundle: nil)
        //configWindow =  config.instantiateController(withIdentifier: "main") as? NSWindowController as! PreferencesWindowController?
        
        configWindow?.showWindow(self)
        NSApp.activate(ignoringOtherApps: true)
        configWindow?.window?.makeKeyAndOrderFront(self)
    }
    @objc  func openTelegram(_ sender :AnyObject){
        let url = URL.init(string: "https://telegram.me/abigtug")
        
        NSWorkspace.shared.open(url!)
    }
    @objc func openConfigDir(_ sender: AnyObject) {
        let url = fm.containerURL(forSecurityApplicationGroupIdentifier: groupIdentifier)!.appendingPathComponent("abigt.conf")
        
        NSWorkspace.shared.open(url)
        //NSWorkspace.shared().open(logUrl as URL)
    }
    @objc func openLogDir(_ sender: AnyObject) {
        
        
        if let m = SFVPNManager.shared.manager {
            
            let me = SFVPNXPSCommand.HELLO.rawValue + "|Hello Provider"
            if let session = m.connection as? NETunnelProviderSession,
                let message = me.data(using: .utf8), m.connection.status != .invalid
            {
                do {
                    try session.sendProviderMessage(message) { [unowned self] response in
                        if let response = response  {
                            if let responseString = String.init(data:response , encoding: .utf8){
                                let list = responseString.components(separatedBy: ":")
                                let session:String = list.last!
                                self.openSession(session: session)
                                
                            }
                            
                            //self.registerStatus()
                        } else {
                            self.openSession(session: "")
                        }
                    }
                } catch {
                    openSession(session: "")
                }
            }
        }else {
            openSession(session: "")
        }
        
        
        
    }
    func openSession(session:String){
        let url = fm.containerURL(forSecurityApplicationGroupIdentifier: groupIdentifier)!.appendingPathComponent("Log/" + session)
        if fm.fileExists(atPath: url.path) {
            NSWorkspace.shared.openFile(url.path, withApplication: "Terminal")
        }else {
            let url = fm.containerURL(forSecurityApplicationGroupIdentifier: groupIdentifier)!
            NSWorkspace.shared.open(url)
        }
        
    }
    @objc func openRequest(_ sender:AnyObject) {
        if requestWindow == nil {
            requestWindow = RequestsWindowController(windowNibName: NSNib.Name(rawValue: "RequestsWindowController"))
        }
        
        requestWindow?.showWindow(self)
        NSApp.activate(ignoringOtherApps: true)
        requestWindow?.window?.makeKeyAndOrderFront(self)
    }
    func setProxyClicked(_ sender: AnyObject) {
    }
    func copyCommand(_ sender: AnyObject) {
    }
    func allowClientsFromLanClicked(_ sender: AnyObject){
        //        let image:CGImage = CGDisplayCreateImage(CGDirectDisplayID.init(0))!
        //        let ciImage:CIImage = CIImage(cgImage: image)
        //        var message:String = ""
        //        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        //
        //        let features = detector!.features(in: ciImage)
        //
        //        if features.count > 0{
        //
        //            for feature in features as! [CIQRCodeFeature]{
        //                message += feature.messageString!
        //            }
        //            print(message)
        //
        //
        //        }else{
        //
        //        }
        
    }
    @objc func advancedOpen(_ sender: AnyObject){
        if advancedWindos == nil {
            advancedWindos = AdvancedWindowController(windowNibName: NSNib.Name(rawValue: "AdvancedWindowController"))
        }
        
        advancedWindos?.showWindow(self)
        NSApp.activate(ignoringOtherApps: true)
        advancedWindos?.window?.makeKeyAndOrderFront(self)
    }
    @objc func showQrWindow(_ sender: AnyObject){
        
        if ProxyGroupSettings.share.proxys.isEmpty {
            alertMessage(message: "Please Add Proxy Server")
            return
        }
        if qrWindow == nil {
            qrWindow = QrWindowController(windowNibName: NSNib.Name(rawValue: "QRCodeWindow"))
        }
        let idx = ProxyGroupSettings.share.selectIndex
        qrWindow?.proxy = ProxyGroupSettings.share.proxys[idx]
        qrWindow?.showWindow(self)
        NSApp.activate(ignoringOtherApps: true)
        qrWindow?.window?.makeKeyAndOrderFront(self)
    }
     @objc func autostartClicked(_ sender: AnyObject){
        
    }
    
    @objc func terminate(_ sender: AnyObject){
        
    }
    @objc func showAbout(_ sender: AnyObject){
        
        NSApp.orderFrontStandardAboutPanel([:])
        
    }
    func test (){
        let task = Process()
        
        // Set the task parameters
        task.launchPath = "/usr/sbin/lsof"
        task.arguments = ["-n",  "-i","tcp@127.0.0.1:6152"]
        
        // Create a Pipe and make the task
        // put all the output there
        let pipe = Pipe()
        task.standardOutput = pipe
        
        // Launch the task
        task.launch()
        
        // Get the data
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        
        print(output!)
    }
    @objc func openHelp(_ sender: AnyObject){
        //thanks.txt
        //test()
        //pid cant get
        let url = Bundle.main.url(forResource: "thanks", withExtension: "txt")
        
        NSWorkspace.shared.open(url!)
    }
    func showLogfile(_ sender: AnyObject){
        
    }
    @objc func update(_ sender: AnyObject){
        let url = URL.init(string: "https://gist.github.com/networkextension/069590ba0e95e2fc322f8d10c4212731")
        NSWorkspace.shared.open(url!)
    }
    func menuNeedsUpdate(_ menu: NSMenu) {
        menu.removeAllItems()
        
        for name in configurations.keys.sorted() {
            let item = buildMenuItemForManager(name, valid: configurations[name]!.1)
            menu.addItem(item)
        }
        
        menu.addItem(NSMenuItem.separator())
        if let m = SFVPNManager.shared.manager {
            let title = m.connection.status.titleForButton
            menu.addItem(withTitle:title, action: #selector(AppDelegate.connectVPN(_:)), keyEquivalent: "d")
        }else {
            menu.addItem(withTitle:"Connect", action: #selector(AppDelegate.connectVPN(_:)), keyEquivalent: "d")
        }
        
        menu.addItem(withTitle: "Request", action: #selector(AppDelegate.openRequest(_:)), keyEquivalent: "r")
        menu.addItem(withTitle: "Open Log Path", action: #selector(AppDelegate.openLogDir(_:)), keyEquivalent: "o")
        
        menu.addItem(NSMenuItem.separator())
        
        let item  = NSMenuItem(title: "Servers", action: #selector(AppDelegate.advancedOpen(_:)), keyEquivalent: "")
        menu.addItem(item)
        serversMenuItem = item
        if item.submenu == nil {
            item.submenu = NSMenu()
            updateServersMenu(false)
        }
        
        
        
        menu.addItem(NSMenuItem(title: "Advanced Preferences ...", action: #selector(AppDelegate.advancedOpen(_:)), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        //
        menu.addItem(withTitle: "Generate Qr Code", action: #selector(AppDelegate.showQrWindow(_:)), keyEquivalent: "g")
        menu.addItem(withTitle: "Scan Qr Code From Screen", action: #selector(AppDelegate.qrScan(_:)), keyEquivalent: "g")

        menu.addItem(withTitle: "Manual", action: #selector(AppDelegate.update(_:)), keyEquivalent: "u")
        menu.addItem(withTitle: "Show Rule Config", action: #selector(AppDelegate.openConfigDir(_:)), keyEquivalent: "")
        menu.addItem(withTitle: "Telegram Group", action: #selector(AppDelegate.openTelegram(_:)), keyEquivalent: "")
        menu.addItem(withTitle: "Acknowledge", action: #selector(AppDelegate.openHelp(_:)), keyEquivalent: "")
        menu.addItem(withTitle: "About", action: #selector(AppDelegate.showAbout(_:)), keyEquivalent: "")
        menu.addItem(NSMenuItem.separator())
        menu.addItem(withTitle: "Quit Surfing", action: #selector(AppDelegate.terminate(_:)), keyEquivalent: "q")
    }
    @IBAction func selectServer(_ sender: NSMenuItem) {
        let index = sender.tag
        
        changeProxy(index: index)
       
    }
    
    func changeProxy(index:Int) {
        ProxyGroupSettings.share.selectIndex = index
        try! ProxyGroupSettings.share.save()
        let  me = SFVPNXPSCommand.CHANGEPROXY.rawValue + "|\(index)"
        //m.connection.status == .connected
        if let m = SFVPNManager.shared.manager ,  m.connection.status == .connected {
            if let session = m.connection as? NETunnelProviderSession,
                let message = me.data(using: .utf8)
            {
                do {
                    try session.sendProviderMessage(message) { [weak self] response in
                        if let r = String.init(data: response!, encoding: .utf8)  , r == proxyChangedOK{
                            //print(proxyChangedOK)
                            //self!.alertMessageAction(r,complete: nil)
                            
                        } else {
                            self!.alertMessage(message:"Failed to Change Proxy")
                        }
                    }
                } catch let e as NSError{
                    alertMessage(message:"Failed to Change Proxy,reason \(e.description)")
                }
                
            }
        }
        
    }
    func updateServersMenu(_ update:Bool) {
        guard let serversMenuItem = serversMenuItem else {return}
        guard let menu = serversMenuItem.submenu else {return}
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
            let em = NSMenuItem(title: title, action: #selector(AppDelegate.selectServer(_:)), keyEquivalent: "")
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
        menu.addItem(withTitle: "Open Server Preferences ...", action: #selector(AppDelegate.openProxySConfig(_:)), keyEquivalent: "c")
    }
    func copyConfig(){
        
        let firstOpen = UserDefaults.standard.bool(forKey: "firstOpen")
        if firstOpen == false {
            let c = "abigt.conf"//逗比极客精简版.json","逗比极客全能版.json","abclite普通版.json","abclite去广告版.json","surf_main.json"
            
            if let p = Bundle.main.path(forResource:c, ofType: nil){
                //let u = groupContainerURL.appendingPathComponent(f)
                let u2 = groupContainerURL().appendingPathComponent(c)
                do {
                    //  try fm.copyItemAtPath(p, toPath: u.path!)
                    try fm.copyItem(atPath: p, toPath: u2.path)
                }catch let e as NSError {
                    
                    alertMessage(message: "copy config file error \(e)")
                }
                
                
            }else {
                alertMessage(message: "abigt.conf don't Find")
                
            }
            
            ProxyGroupSettings.share.config = "abigt" + configExt
            try! ProxyGroupSettings.share.save()
            UserDefaults.standard.set(true, forKey: "firstOpen")
            UserDefaults.standard.synchronize()
        }else {
            //alertMessage(message: "!firstOpen")
        }
    }
    
    func alertMessage(message:String){
        let alert = NSAlert.init()
        alert.addButton(withTitle: "OK")
        alert.messageText = message
        alert.alertStyle = .warning
        alert.runModal()
    }
    //    fileprivate extension NSTouchBarCustomizationIdentifier {
    //
    //        static
    //    }
    //
    //    fileprivate extension NSTouchBarItemIdentifier {
    //
    //
    //        static
    //        static
    //    }'
    // MARK: - NSTouchBar
    override func value(forUndefinedKey key: String) -> Any? {
        print("forUndefinedKey " + key)
        return nil
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        Fabric.with([Crashlytics.self])
        XRuler.groupIdentifier = "745WQDK4L7.com.abigt.Surf"
        UserDefaults.standard.set(true, forKey: "NSApplicationCrashOnExceptions")
        copyConfig()
        // testTouchBar()
        icloudPrepare()
        //NSApp.setActivationPolicy(.accessory)
        let baseURL = groupContainerURL().appendingPathComponent("Library/Application Support")
        if !fm.fileExists(atPath: baseURL.path){
            do {
                try fm.createDirectory(at: baseURL, withIntermediateDirectories:false , attributes: [:])
            }catch let e {
                print(e.localizedDescription)
            }
        }
        
        initMenuBar()
        reloadManagers()
        //        AxLogger.openLogging(baseURL, date:Date(),debug: true)
        //        AxLogger.log("test", level: .Info)
        installNoti()
        updateServersMenu(false)
        loadConfig()
        //showScan()
    }
    
    func showScan(){
        let queue = DispatchQueue.init(label: ".", qos: .background, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
        //let queue = DispatchQueue(label: "com.abigt.socket")// DISPATCH_QUEUE_CONCURRENT)
        for p in ProxyGroupSettings.share.proxys {
            
            queue.async(execute: {
                
                let start = Date()
                
                
                // Look up the host...
                let socketfd: Int32 = socket(Int32(AF_INET), SOCK_STREAM, Int32(IPPROTO_TCP))
                let remoteHostName = p.serverAddress
                //let port = Intp.serverPort
                guard let remoteHost = gethostbyname2((remoteHostName as NSString).utf8String, AF_INET)else {
                    return
                }
                //remoteHostEnt?.pointee.h_addr_list
                //let remoteHost: UnsafeMutablePointer<hostent> = gethostbyname(remoteHostName)
                
                
                let d = Date()
                
                
                
                p.dnsValue = d.timeIntervalSince(start)
                var remoteAddr = sockaddr_in()
                remoteAddr.sin_family = sa_family_t(AF_INET)
                bcopy(remoteHost.pointee.h_addr_list[0], &remoteAddr.sin_addr.s_addr, Int(remoteHost.pointee.h_length))
                if let port = UInt16(p.serverPort) {
                    remoteAddr.sin_port = port.bigEndian
                    
                }else {
                    _  = p.serverPort
                    print("\(p.serverPort) error")
                    close(socketfd)
                    p.tcpValue = -1
                    return
                }
                
                
                
                // Now, do the connection...
                let rc = withUnsafePointer(to: &remoteAddr) {
                    // Temporarily bind the memory at &addr to a single instance of type sockaddr.
                    $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                        connect(socketfd, $0, socklen_t(MemoryLayout<sockaddr_in>.stride))
                    }
                }
                
                
                if rc < 0 {
                    print("\(p.serverAddress):\(p.serverPort) socket connect failed")
                    //throw BlueSocketError(code: BlueSocket.SOCKET_ERR_CONNECT_FAILED, reason: self.lastError())
                    p.tcpValue = -1
                }else {
                    let end = Date()
                    p.tcpValue = end.timeIntervalSince(d )
                    close(socketfd)
                }
                
                DispatchQueue.main.async(execute: { [weak  self] in
                    if let StrongSelft = self {
                        StrongSelft.updateServersMenu(false)
                        try! ProxyGroupSettings.share.save()
                    }
                    
                    
                })
                
            })
        }
    }
    func toUint(signed: Int8) -> UInt8 {
        
        let unsigned = signed >= 0 ?
            UInt8(signed) :
            UInt8(signed  - Int8.min) + UInt8(Int8.max) + 1
        
        return unsigned
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
    func installNoti(){
        let notifyCenter = NotificationCenter.default
        notifyCenter.addObserver(forName: NSNotification.Name(rawValue: NOTIFY_SERVER_PROFILES_CHANGED), object: nil, queue: nil
            , using: {
                (note) in
                let _ = ProxyGroupSettings.share
                //self.showScan()
                self.updateServersMenu(true)
                //SyncSSLocal()
        }
        )
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    func loadConfig(){
        var url = fm.containerURL(forSecurityApplicationGroupIdentifier: groupIdentifier)!
        url.appendPathComponent("abigt.conf")
        let config = SFConfig.init(path: url.path, loadRule: true)
        print(config.configName)
    }
    
}

extension AppDelegate {
    @available(OSX 10.12.2, *)
    override func makeTouchBar() -> NSTouchBar? {
        
        let touchBar = NSTouchBar()
        touchBar.delegate = self
        touchBar.customizationIdentifier = .touchBar
        touchBar.defaultItemIdentifiers = [.fontStyle, .popover, .otherItemsProxy]
        touchBar.customizationAllowedItemIdentifiers = [.fontStyle, .popover,.otherItemsProxy]
        
        return touchBar
    }
    //
    //    @IBOutlet weak  var mytouchBar: NSTouchBar?
    //
    @available(OSX 10.12.2, *)
    
    func changeFontSizeBySlider(_ sender:NSSlider) {
        
    }
    @objc func changeFontStyleBySegment(_ sender:NSSegmentedControl){
        let index = sender.selectedSegment
        changeProxy(index: index)
        
    }
    //
    @available(OSX 10.12.2, *)
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        switch identifier {
            
        case NSTouchBarItem.Identifier.popover:
            
            //            let popoverItem = NSPopoverTouchBarItem(identifier: identifier)
            //            popoverItem.customizationLabel = "Font Size"
            //            popoverItem.collapsedRepresentationLabel = "Font Size"
            //
            //            let secondaryTouchBar = NSTouchBar()
            //            secondaryTouchBar.delegate = self
            //            secondaryTouchBar.defaultItemIdentifiers = [.popoverSlider];
            //
            //            // We can setup a different NSTouchBar instance for popoverTouchBar and pressAndHoldTouchBar property
            //            // Here we just use the same instance.
            //            //
            //            popoverItem.pressAndHoldTouchBar = secondaryTouchBar
            //            popoverItem.popoverTouchBar = secondaryTouchBar
            //
            //            return popoverItem
            let item = NSCustomTouchBarItem(identifier:identifier)
            let button = NSButton.init(title: "Connect", target: self, action: #selector(connectVPN))
            self.connectionButton = button
            item.view = button
            
            return item
            
        case NSTouchBarItem.Identifier.fontStyle:
            
            var labels:[String] = []
            
            var count = 7
            if ProxyGroupSettings.share.proxys.count <= count {
                count = ProxyGroupSettings.share.proxys.count
            }
            for idx in 0 ..< count {
                let p = ProxyGroupSettings.share.proxys[idx]
                var title = ""
                if ProxyGroupSettings.share.showCountry {
                    
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
                    title += p.serverAddress
                    
                }else {
                    title += p.proxyName
                }
                labels.append(title)
            }
            let fontStyleItem = NSCustomTouchBarItem(identifier: identifier)
            fontStyleItem.customizationLabel = "Font Style"
            
            let fontStyleSegment = NSSegmentedControl(labels: labels, trackingMode: .selectOne, target: self, action: #selector(changeFontStyleBySegment))
            if ProxyGroupSettings.share.selectIndex < count {
                fontStyleSegment.selectedSegment = ProxyGroupSettings.share.selectIndex
            }
            
            fontStyleItem.view = fontStyleSegment
            
            return fontStyleItem;
           
        case NSTouchBarItem.Identifier.popoverSlider:
            
            //            let sliderItem = NSSliderTouchBarItem(identifier: identifier)
            //            sliderItem.label = "Size"
            //            sliderItem.customizationLabel = "Font Size"
            //
            //            let slider = sliderItem.slider
            //            slider.minValue = 6.0
            //            slider.maxValue = 100.0
            //            slider.target = self
            //            slider.action = #selector(changeFontSizeBySlider)
            //
            //            // Set the font size for the slider item to the same value as the stepper.
            //            slider.integerValue = 18
            //
            //            slider.bind(NSValueBinding, to: self, withKeyPath: "currentFontSize", options: nil)
            //
            //            return sliderItem
            return nil
        default:
            //            let item = NSSliderTouchBarItem(identifier:identifier)
            //            item.label = "Connect"
            //            item.target = self
            //            item.action = #selector(connectVPN)
            return nil
        }
        
    }
    
    //    func testTouchBar() {
    //
    //        if ((NSClassFromString("NSTouchBar")) != nil) {
    //            let popoverSlider = NSTouchBarItemIdentifier("com.ToolbarSample.popoverBar.slider")
    //            let popover = NSTouchBarItemIdentifier("com.ToolbarSample.TouchBarItem.popover")
    //            if self.touchBar == nil {
    //                self.touchBar = makeTouchBar()
    //            }
    //            guard let touchBar = touchBar else {return}
    //            let fontSizeTouchBarItem = touchBar.item(forIdentifier: popover) as! NSPopoverTouchBarItem
    //            let sliderTouchBar = fontSizeTouchBarItem.popoverTouchBar
    //            let sliderTouchBarItem = sliderTouchBar.item(forIdentifier: popoverSlider) as! NSSliderTouchBarItem
    //            let slider = sliderTouchBarItem.slider
    //
    //            // Make the font size slider a bit narrowed, about 250 pixels.
    //            let views = ["slider" : slider]
    //            let theConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:[slider(250)]", options: NSLayoutFormatOptions(), metrics: nil, views:views)
    //            NSLayoutConstraint.activate(theConstraints)
    //
    //            // Set the font size for the slider item to the same value as the stepper.
    //            slider.integerValue = 10
    //        }
    //
    //    }
}
extension AppDelegate {
    func icloudPrepare(){
        
        let fm = FileManager.default
        if  let  currentiCloudToken = fm.ubiquityIdentityToken{
            let  newTokenData:NSData = NSKeyedArchiver.archivedData(withRootObject: currentiCloudToken) as NSData
            print("token \(newTokenData)")
            UserDefaults.standard.set(newTokenData, forKey: "com.abigt.surf.UbiquityIdentityToken")
            let iCloudToken = NSKeyedArchiver.archivedData(withRootObject: currentiCloudToken)
            //setObject: newTokenData
            //forKey: @"com.apple.MyAppName.UbiquityIdentityToken"];
        }else {
            UserDefaults.standard
                .removeObject(forKey: "com.abigt.surf.UbiquityIdentityToken")
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSUbiquityIdentityDidChange, object: nil, queue: OperationQueue.main) { (noti:Notification) in
            print("NSUbiquityIdentityDidChangeNotification")
        }
        let iCloudEnable = UserDefaults.standard.bool(forKey: "iCloudEnable")
        if ProxyGroupSettings.share.iCloudSyncEnabled(){
            sync()
        }
    }
    
    func sync() {
       
        
        DispatchQueue.global().async(execute: { [weak self] in
            guard let countainer = FileManager.default.url(forUbiquityContainerIdentifier: nil) else {
                DispatchQueue.main.async(execute: {
                    self?.alertMsg("Error Enable iCloud sysnc")
                })
                return
            }
            print("countainer:url \(String(describing: countainer))")
            
            let  documentsDirectory = countainer.appendingPathComponent("Documents");
            if !FileManager.default.fileExists(atPath: documentsDirectory.path){
                try! FileManager.default.createDirectory(atPath: documentsDirectory.path, withIntermediateDirectories: false, attributes: nil)
            }
            do {
                try self!.moverToiCloud(url: documentsDirectory)
            }catch let  e  {
                DispatchQueue.main.async(execute: {
                    self?.alertMsg("icloud sync:\(e.localizedDescription)")
                })
                
            }
            
            
        })
        
    }
    func moverToiCloud(url:URL)  throws{
        let u = applicationDocumentsDirectory
        do {
            let fs = try fm.contentsOfDirectory(atPath: (u.path))
            for fp in fs {
                if fp.hasSuffix(configExt) {
                    
                    let dest = url.appendingPathComponent(fp)
                    let src = u.appendingPathComponent(fp)
                    
                    if FileManager.default.fileExists(atPath: dest.path) {
                        
                    }else {
                        try fm.copyItem(at: src, to: dest)
                        print("copy \(dest.path)")
                    }
                    
                }
                
            }
            let sp  = groupContainerURL().appendingPathComponent(kProxyGroupFile)
            let dp = url.appendingPathComponent("ProxyGroup.json")
            if FileManager.default.fileExists(atPath: dp.path) {
                try fm.removeItem(at: dp)
            }
            try fm.copyItem(at: sp, to: dp)
            
        }catch let e as NSError{
            throw e
            
        }
        
        
    }
}
