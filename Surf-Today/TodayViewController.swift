//
//  TodayViewController.swift
//  Surf-Today
//
//  Created by abigt on 2016/11/22.
//  Copyright © 2016年 abigt. All rights reserved.
//

import Cocoa
import NotificationCenter
import NetworkExtension
import DarwinCore
import SFSocket
import XRuler
class TodayViewController: NSViewController, NCWidgetProviding {
    
    @IBOutlet weak var iconView:NSImageView!
    @IBOutlet weak var titleField:NSTextField!
    @IBOutlet weak var timeField:NSTextField!
    @IBOutlet weak var connectButton:NSButton!
    var timer:Timer?
    override var nibName: NSNib.Name {
        return NSNib.Name.init("TodayViewController")
    }

    @IBAction func startStopToggled(_ sender:AnyObject) {
        
        do  {
            let selectConf = ProxyGroupSettings.share.config
            let result = try SFVPNManager.shared.startStopToggled(selectConf)
            if !result {
             
            }
            
        } catch let error {
            SFVPNManager.shared.xpc()
            
        }
        
    }
    public func secondToString(second:Int) ->String {
        
        let sec = second % 60
        let min = second % (60*60) / 60
        let hour = second / (60*60)
        
        return String.init(format: "%02d:%02d:%02d", hour,min,sec)
        
        
    }
    func reloadStatus(){
        //Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #, userInfo: <#T##Any?#>, repeats: <#T##Bool#>)
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(TodayViewController.trafficReport(_:)), userInfo: nil, repeats: true)
        
    }
    public func toString(x:UInt,label:String,speed:Bool) ->String {
        
        var s = "/s"
        if !speed {
            s = ""
        }
        
        if x < 1024{
            return label + " \(x)  B" + s
        }else if x >= 1024 && x < 1024*1024 {
            return label +  String(format: "%d KB", Int(Float(x)/1024.0))  + s
        }else if x >= 1024*1024 && x < 1024*1024*1024 {
            //return label + "\(x/1024/1024) MB" + s
            return label +  String(format: "%.2f MB", Float(x)/1024/1024)  + s
        }else {
            //return label + "\(x/1024/1024/1024) GB" + s
            return label +  String(format: "%.2f GB", Float(x)/1024/1024/1024)  + s
        }
        
    }
    @objc func trafficReport(_ t:Timer) {
            updateTime()
    }
    func updateTime(){
        if let m =  SFVPNManager.shared.manager, m.connection.status == .connected {
            let start = m.connection.connectedDate!
            let now = Date()
            let count = DataCounters("240.7.1.9")
            let down = toString(x: count!.tunReceived, label: "RX:", speed: false)
            let up = toString(x: count!.tunSent, label: "TX:", speed: false)
            timeField.stringValue = secondToString(second: Int(now.timeIntervalSince(start))) + " " + down + " "  + up
            
        }
    }
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Update your data and prepare for a snapshot. Call completion handler when you are done
        // with NoData if nothing has changed or NewData if there is new data since the last
        // time we called you
        completionHandler(.noData)
    }

    override func viewDidLoad(){
        super.viewDidLoad()
        loadManager()
        reloadStatus()
    }
    
    
    func loadManager() {
        //print("loadManager")
        let vpnmanager = SFVPNManager.shared
        if !vpnmanager.loading {
            vpnmanager.loadManager() {
                [weak self] (manager, error) -> Void in
                if let m = manager {
                    self!.showStatus(m.connection)
                    self!.registerStatus()
                    vpnmanager.xpc()
                }
            }
        }else {
            print("vpnmanager loading")
        }
        
    }
    func showStatus(_ connection:NEVPNConnection){
        let  status:NEVPNStatus = connection.status
        switch status{
        case .disconnected:
            iconView.image =  NSImage.init(named:NSImage.Name(rawValue: "NSStatusPartiallyAvailable"))
            titleField.stringValue = "Disconnected"
            connectButton.title = "Connect"
            timeField.isHidden = true
        case .invalid:
            iconView.image = NSImage.init(named: NSImage.Name(rawValue: "NSStatusUnavailable"))
            
            titleField.stringValue = "Disconnected"
            timeField.isHidden = true
        case .connected:
            iconView.image = NSImage.init(named:NSImage.Name(rawValue: "NSStatusAvailable"))
            timeField.isHidden = false
            titleField.stringValue = "Connected"
            connectButton.title = "Disconnect"
            
        case .connecting:
            iconView.image = NSImage.init(named:NSImage.Name(rawValue: "NSStatusAvailable"))
            timeField.isHidden = true
            titleField.stringValue = "Connecting"
        case .disconnecting:
            iconView.image = NSImage.init(named:NSImage.Name(rawValue: "NSStatusAvailable"))
            
            timeField.isHidden = true
            titleField.stringValue = "NSStatusAvailable"
        case .reasserting:
            iconView.image = NSImage.init(named:NSImage.Name(rawValue: "RedDot"))
            
            timeField.isHidden = true
           titleField.stringValue = "NSStatusPartiallyAvailable"
            
        }
        
        
    }
    func registerStatus(){
        if let m = SFVPNManager.shared.manager {
            // Register to be notified of changes in the status.
            NotificationCenter.default.addObserver(forName: NSNotification.Name.NEVPNStatusDidChange, object: m.connection, queue: OperationQueue.main, using: { [weak self] notification  in
                
                if let o = notification.object {
                    if let c = o as? NEVPNConnection{
                        //self!.autoRedail = false
                        print(c)
                        //try! SFVPNManager.shared.startStopToggled("")
                        if let strong = self {
                            strong.showStatus(c)
                        }
                    }
                    
                }
                
                
            })
        }else {
            
        }
        
    }
}
