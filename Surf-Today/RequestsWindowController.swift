//
//  RequestsWindowController.swift
//  Surf
//
//  Created by 孔祥波 on 24/11/2016.
//  Copyright © 2016 abigt. All rights reserved.
//

import Cocoa
import SwiftyJSON
import NetworkExtension
import SFSocket
import XProxy
class RequestsWindowController: NSWindowController,NSTableViewDelegate,NSTableViewDataSource{
    public var results:[SFRequestInfo] = []
    public var dbURL:URL?
    @IBOutlet public  weak var tableView:NSTableView!
    //var vc:RequestsVC!
    override func windowDidLoad() {
        super.windowDidLoad()
        //dbURL = RequestHelper.shared.openForApp()
        //recent()
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(RequestsWindowController.refreshRequest(_:)), userInfo: nil, repeats: true)
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
//        let st = NSStoryboard.init(name: NSStoryboard.Name(rawValue: "RequestBasic"), bundle: nil)
//        let vc = st.instantiateInitialController() as! RequestsVC
//        self.window?.contentView = vc.view
    }
    @objc func refreshRequest(_ t:Timer){
       
        // Send a simple IPC message to the provider, handle the response.
        //AxLogger.log("send Hello Provider")
        var rpc = false
        if let m = SFVPNManager.shared.manager  {
            let date = NSDate()
            let  me = SFVPNXPSCommand.RECNETREQ.rawValue + "|\(date)"
            if let session = m.connection as? NETunnelProviderSession,
                let message = me.data(using: .utf8), m.connection.status == .connected
            {
                do {
                    rpc = true
                    try session.sendProviderMessage(message) {[weak self] response in
                        guard let s = self else {return}
                        if response != nil {
                            //let responseString = NSString(data: response!, encoding: NSUTF8StringEncoding)
                            //mylog("Received response from the provider: \(responseString)")
                            s.processData(data: response!)
                            //self.registerStatus()
                        } else {
                            //s.alertMessageAction("Got a nil response from the provider",complete: nil)
                        }
                    }
                } catch {
                    //alertMessageAction("Failed to send a message to the provider",complete: nil)
                }
            }
        }
       
    }
    public func processData(data:Data)  {
        let oldresults = results
        results.removeAll()
        
        let obj = try! JSON.init(data: data)
        if obj.error == nil {
            
            let count = obj["count"]
            
            if count.intValue != 0 {
                
                let result = obj["data"]
                if result.type == .array {
                    for item in result {
                        
                        let json = item.1
                        let r = SFRequestInfo.init(rID: 0)
                        r.map(json)
                        let rr = oldresults.filter({ info -> Bool in
                            if info.reqID == r.reqID && info.subID == r.subID {
                                return true
                            }
                            return false
                        })
                        
                        if rr.isEmpty {
                            results.append(r)
                            r.speedtraffice = r.traffice
                        }else {
                            let old = rr.first!
                            if r.traffice.rx > old.traffice.rx {
                                //sub id reset
                                r.speedtraffice.rx = r.traffice.rx - old.traffice.rx
                            }
                            
                            if r.traffice.tx > old.traffice.tx{
                                //?
                                r.speedtraffice.tx = r.traffice.tx - old.traffice.tx
                            }
                            
                            
                            results.append(r)
                        }
                        
                    }
                }
                if results.count > 0 {
                    results.sort(by: { $0.reqID < $1.reqID })
                    
                }
                
            }
            
            
        }
        
        tableView.reloadData()
        
    }
    public func numberOfRows(in tableView: NSTableView) -> Int {
        return results.count
    }
    public func tableView(_ tableView: NSTableView
        , objectValueFor tableColumn: NSTableColumn?
        , row: Int) -> Any? {
        let result = results[row]
        if (tableColumn?.identifier)!.rawValue == "Icon" {
            switch result.rule.policy{
            case .Direct:
                return  NSImage(named:NSImage.Name(rawValue: "NSStatusPartiallyAvailable"))
            case .Proxy:
                return NSImage(named:NSImage.Name(rawValue: "NSStatusAvailable"))
            case .Reject:
                return NSImage(named:NSImage.Name(rawValue: "NSStatusUnavailable"))
            default:
                break
            }
        }
        return nil
    }
    public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let iden = tableColumn!.identifier.rawValue
        let result = results[row]
        
        let cell:NSTableCellView = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
        if iden == "Index" {
            cell.textField?.stringValue = "\(result.reqID)  \(result.subID)"
            
            
        }else if iden == "App" {
            
            cell.textField?.attributedStringValue = result.detailString()
        }else if iden == "Url" {
            if result.mode == .HTTP {
                if let u = URL(string: result.url){
                    if let h = u.host {
                        cell.textField?.stringValue = h
                    }else {
                        cell.textField?.stringValue = u.description
                    }
                    
                }else {
                    if let req = result.reqHeader{
                        cell.textField?.stringValue = req.Host
                    }
                }
                
            }else {
                cell.textField?.stringValue = result.url
            }
            
        }else if iden == "Rule" {
            
        }else if iden == "Date" {
            
            cell.textField?.stringValue = result.dataDesc(result.sTime)
        }else if iden == "Status" {
            
            let n = Date()
            let a =  result.activeTime
            let idle = n.timeIntervalSince(a)
            if  idle > 1 {
                cell.textField?.stringValue = "idle \(Int(idle))"
            }else {
                cell.textField?.stringValue = result.status.description
            }
            
        }else if iden == "Policy" {
            let rule = result.rule
            cell.textField?.stringValue = rule.policy.description + " (" + rule.type.description + ":" + rule.name + ")"
            //(\(rule.type.description):\(rule.name)  ProxyName:\(rule.proxyName))"
            //cell.textField?.stringValue = "Demo"//result.status.description
        }else if iden == "Up" {
            let tx = result.speedtraffice.tx
            cell.textField?.stringValue = self.toString(x: tx,label:"",speed: true)
        }else if iden == "Down" {
            let rx = result.speedtraffice.rx
            cell.textField?.stringValue = self.toString(x: rx,label:"",speed: true)
            
        }else if iden == "Method" {
            if result.mode == .TCP{
                cell.textField?.stringValue = "TCP"
            }else {
                if let req = result.reqHeader {
                    if req.method == .CONNECT {
                        cell.textField?.stringValue = "HTTPS"
                    }else {
                        cell.textField?.stringValue = req.method.rawValue
                    }
                    
                }
            }
            
        }else if iden == "Icon" {
            switch result.rule.policy{
            case .Direct:
                cell.imageView?.objectValue = NSImage(named:NSImage.Name(rawValue: "NSStatusPartiallyAvailable"))
            case .Proxy:
                cell.imageView?.objectValue = NSImage(named:NSImage.Name(rawValue: "NSStatusAvailable"))
            case .Reject:
                cell.imageView?.objectValue = NSImage(named:NSImage.Name(rawValue: "NSStatusUnavailable"))
            default:
                break
            }
        }else if iden == "DNS" {
            
            if !result.rule.ipAddress.isEmpty {
                cell.textField?.stringValue = result.rule.ipAddress
            }else {
                if !result.remoteIPaddress.isEmpty{
                    let x = result.remoteIPaddress.components(separatedBy: " ")
                    if x.count > 1 {
                        cell.textField?.stringValue = x.last!
                    }else {
                        cell.textField?.stringValue = x.first!
                    }
                    
                }else {
                    if !result.rule.name.isEmpty {
                        cell.textField?.stringValue = result.rule.name
                    }else {
                        let x = "NONE"
                        let s = NSMutableAttributedString(string:x )
                        let r = NSMakeRange(0, 4);
                        s.addAttributes([NSAttributedStringKey.foregroundColor:NSColor.red,NSAttributedStringKey.backgroundColor:NSColor.white], range: r)
                        cell.textField?.attributedStringValue = s
                    }
                    
                }
                
            }
            
            
        }
        if row % 2 == 0 {
            cell.backgroundStyle = .dark
        }else {
            cell.backgroundStyle = .light
        }
        return cell
    }
    public func toString(x:UInt,label:String,speed:Bool) ->String {
        
        var s = "/s"
        if !speed {
            s = ""
        }
        
        if x < 1024{
            return label + " \(x)  B" + s
        }else if x >= 1024 && x < 1024*1024 {
            return label +  String(format: "%0.2f KB", Float(x)/1024.0)  + s
        }else if x >= 1024*1024 && x < 1024*1024*1024 {
            
            return label +  String(format: "%0.2f MB", Float(x)/1024/1024)  + s
        }else {
            
            return label +  String(format: "%0.2f GB", Float(x)/1024/1024/1024)  + s
        }
        
    }
   
}
