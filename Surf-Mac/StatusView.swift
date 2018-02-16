//
//  StatusView.swift
//  Surf
//
//  Created by 孔祥波 on 21/11/2016.
//  Copyright © 2016 abigt. All rights reserved.
//

import Cocoa
import SFSocket
import XRuler
import NetworkExtension

class StatusView: NSView {
    var report:SFVPNStatistics = SFVPNStatistics.shared
    var reportTimer:Timer?
    @IBOutlet weak var iconView: NSImageView!
    @IBOutlet weak var upView: NSTextField!
    @IBOutlet weak var downView: NSTextField!
    @IBOutlet weak var upTrafficeView: NSTextField!
    @IBOutlet weak var downTrafficView: NSTextField!
    @IBOutlet weak var buttonView: NSButton!
    override func awakeFromNib() {
        let font = NSFont.init(name: "ionicons", size: 10)
        config()
        upView.font = font
        
        downView.font = font
        downView.stringValue = "\u{f35d}"
     
        upView.stringValue = "\u{f366}"
        
        

    }
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    func config(){
        if reportTimer == nil  {
            reportTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(StatusView.requestReportXPC(_:)), userInfo: nil, repeats: true)
            return
        }else {
            if let t = reportTimer,  !(t.isValid) {
                reportTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(StatusView.requestReportXPC(_:)), userInfo: nil, repeats: true)
            }
        }
        
    }
    @objc func  requestReport(_ timer:Timer){
        let now  =  getInterfaceTraffic()
        if now.TunSent != 0 && now.TunReceived != 0 {
            //report.lastTraffice.tx = now.TunSent -
            
            if now.TunSent > report.totalTraffice.tx {
                report.lastTraffice.tx = now.TunSent - report.totalTraffice.tx
                
                report.lastTraffice.rx = now.TunReceived - report.totalTraffice.rx
                report.updateMax()
            }
            
            
            
            report.totalTraffice.tx = now.TunSent
            report.totalTraffice.rx = now.TunReceived
            
            let t = report.lastTraffice
            
            
            upTrafficeView.stringValue = self.toString(x: t.tx,label: "",speed: true)
            downTrafficView.stringValue = self.toString(x: t.rx,label: "",speed: true)
        }else {
            upTrafficeView.stringValue = "0  B/s"
            downTrafficView.stringValue = "0  B/s"
        }
        //tableView.reloadData()
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
                return label +  String(format: "%d MB", Int(Float(x)/1024/1024))  + s
            }else {
                //return label + "\(x/1024/1024/1024) GB" + s
                return label +  String(format: "%d GB", Int(Float(x)/1024/1024/1024))  + s
            }
        
    }
   @objc func requestReportXPC(_ timer:Timer)  {
    if let m = SFVPNManager.shared.manager , m.connection.status == .connected {
        //print("\(m.protocolConfiguration)")
        let date = NSDate()
        let  me = SFVPNXPSCommand.STATUS.rawValue + "|\(date)"
        if let session = m.connection as? NETunnelProviderSession,
            let message = me.data(using: .utf8)
            
        {
            do {
                try session.sendProviderMessage(message) { [weak self] response in
                    // print("------\(Date()) %0.2f",Date().timeIntervalSince(d0))
                    if response != nil {
                        self!.processData(data: response!)
                        //print("------\(Date()) %0.2f",Date().timeIntervalSince(d0))
                    } else {
                        //self!.alertMessageAction("Got a nil response from the provider",complete: nil)
                    }
                }
            } catch {
                //alertMessageAction("Failed to Get result ",complete: nil)
            }
        }else {
            //alertMessageAction("Connection not Stated",complete: nil)
        }
    }else {
        //alertMessageAction("message dont init",complete: nil)
        //tableView.reloadData()
    }
    
    }
    func processData(data:Data)  {
        
        //results.removeAll()
        //print("111")
        //let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
        let obj = try! JSON.init(data: data)
        if obj.error == nil {
            
            //alertMessageAction("message dont init",complete: nil)
            report.map(j: obj)
            
            
            
            
            //bug here
            if let m = SFVPNManager.shared.manager, m.connection.status == .connected{
                //chartsView.updateFlow(report.netflow)
                //chartsView.isHidden = false
                if let last = report.netflow.totalFlows.last {
                    upTrafficeView.stringValue = self.toString(x: last.tx,label: "",speed: true)
                    downTrafficView.stringValue = self.toString(x: last.rx,label: "",speed: true)
                }
               
            }else {
                
            }
            //print(report.netflow.currentFlows)
            
           
            
        }
        
    }
}
