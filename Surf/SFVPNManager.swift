//
//  SFVPNManager.swift
//  Surf
//
//  Created by abigt on 16/2/5.
//  Copyright © 2016年 abigt. All rights reserved.
//

import Foundation
import NetworkExtension
import SFSocket
import XRuler
extension NEVPNStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        case .disconnected: return "Disconnected"
        case .invalid: return "Invalid"
        case .connected: return "Connected"
        case .connecting: return "Connecting"
        case .disconnecting: return "Disconnecting"
        case .reasserting: return "Reconnecting"
        }
    }
    public var titleForButton:String {
        switch self{
        case .disconnected:
            
            return "Connect"
        case .invalid:
            return "Invalid"
        case .connected:
            return "Disconnect"
        case .connecting:
            return "Connecting"
        case .disconnecting:
            return "Disconnecting"
        case .reasserting:
            return "Reasserting"
        }
    }
}


class SFNETunnelProviderManager:NETunnelProviderManager {
    //var pluginType:String = "com.yarshure.Surf"
    class func loadOrCreateDefaultWithCompletionHandler(_ completionHandler: ((NETunnelProviderManager?, Error?) -> Void)?) {
        self.loadAllFromPreferences { (managers, error) -> Void in
            if let error = error {
                print("Error: Could not load managers:  \(error.localizedDescription)")
                if let completionHandler = completionHandler {
                    completionHandler(nil, error)
                }
                return
            }
            let bId = Bundle.main.infoDictionary!["CFBundleIdentifier"] as! String
            if let managers = managers {
                if managers.indices ~= 0 {
                    if let completionHandler = completionHandler {
                        var m:NETunnelProviderManager?
                        for mm in managers {
                            let _ = mm.protocolConfiguration as! NETunnelProviderProtocol
                            
                            
                        }
                        
                        
                        if m == nil {
                            m = managers[0]
                        }
                        print("manager \(managers.count) \(String(describing: m?.protocolConfiguration))")
                        completionHandler(m, nil)

                        
                        
                    }
                    return
                }
            }
            
            let config = NETunnelProviderProtocol()
            config.providerConfiguration = ["App": bId,"PluginType":"com.yarshure.Surf"]
            #if os(iOS)
                
            config.providerBundleIdentifier = "com.yarshure.Surf4.PacketTunnel"
                #else
                config.providerBundleIdentifier = "com.yarshure.Surf.mac.extension"
                #endif
                config.serverAddress = "240.84.1.24"
            
            let manager = SFNETunnelProviderManager()
            manager.protocolConfiguration = config
            if bId == "com.yarshure.Surf" {
                manager.localizedDescription = "Surfing"
            }else {
                manager.localizedDescription = "Surfing Today"
            }
            
            //manager.setPluginType("com.yarshure.Surf")
           // manager.
//            manager.onDemandEnabled = true
//            manager.onDemandRules = [NEOnDemandRule]()
//            
//            let newRule = NEOnDemandRuleEvaluateConnection()
//            
//            //newRule.DNSSearchDomainMatch = domains
//            var rules = [NEEvaluateConnectionRule]()
//            let r = NEEvaluateConnectionRule.init(matchDomains: domains, andAction: .ConnectIfNeeded)
//            
//            rules.append(r)
//            newRule.connectionRules? = rules
//            newRule.interfaceTypeMatch = .Any
//            manager.onDemandRules?.append(newRule)
            
            manager.saveToPreferences(completionHandler: { (error) -> Void in
                if let completionHandler = completionHandler {
                    
                    completionHandler(manager, error)
                }
            })
        }
    }
}


class SFVPNManager {
    static let shared:SFVPNManager =  SFVPNManager()
    var manager:NETunnelProviderManager?
    var proVersion:String = ""
    var config:String = ""
    var loading:Bool = false
    var session:String = ""
    var vpnmanager:NEVPNManager = NEVPNManager.shared()
    func loadVPNManager(_ completionHandler: @escaping (Error?) -> Void){
        vpnmanager.loadFromPreferences { (error) -> Void in
            completionHandler(error)
        }
    }
    
    func saveVPNManger(_ completionHandler: ((Error?) -> Void)?) {
        if vpnmanager.isEnabled == false{
            vpnmanager.isEnabled = true
            vpnmanager.saveToPreferences(completionHandler: { (error) in
                completionHandler!(error)
            })
            
        } else {
            completionHandler!(nil)
        }
    }
    func startStopVPNConnect() throws {
        let c = vpnmanager.connection
        if c.status == .disconnected || c.status == .invalid {
            if c.status == .disconnected {
      
              do {
                let conf = ProxyGroupSettings.share.config
                   try c.startVPNTunnel(options: [kConfig:conf as NSObject,kPro:proVersion as NSObject])
                }catch let e as NSError {
                    throw e
                }
                
            }else {
                c.stopVPNTunnel()
            }
        }
    }
    func loadManager(_ completionHandler: ((NETunnelProviderManager?, Error?) -> Void)?) {
        
        if let m = manager {
            if let handler = completionHandler{
                handler(m, nil)
            }
            
            //self.xpc()
        }else {
            loading = true
            SFNETunnelProviderManager.loadOrCreateDefaultWithCompletionHandler { [weak self] (manager, error) -> Void in
                if let m = manager {
                    self!.manager = manager
                    if let handler = completionHandler{
                        if m.onDemandRules == nil {
                            //self!.addOnDemandRule([])
                        }
                        self!.loading = false
                        handler(m, error)
                    }
                }
                
                
                //            self!.registerStatus()
                //            self!.xpc()
                //            if self!.manager.enabled == false {
                //                self!.enabledToggled(false)
                //            }
                //            self!.tableView.reloadData()
                //            mylog("\(self!.manager.protocolConfiguration)")
            }
        }
    }
    func xpc(){
        // Send a simple IPC message to the provider, handle the response.
        //AxLogger.log("send Hello Provider")
        if let m = manager {
            let me = SFVPNXPSCommand.HELLO.rawValue + "|Hello Provider"
            if let session = m.connection as? NETunnelProviderSession,
                 let message = me.data(using: .utf8), m.connection.status != .invalid
            {
                do {
                    try session.sendProviderMessage(message) { response in
                        if let response = response  {
                            if let responseString = String.init(data:response , encoding: .utf8){
                                let list = responseString.components(separatedBy: ":")
                                self.session = list.last!
                                print("Received response from the provider: \(responseString)")
                            }
                            
                            //self.registerStatus()
                        } else {
                            print("Got a nil response from the provider")
                        }
                    }
                } catch {
                    print("Failed to send a message to the provider")
                }
            }
        }else {
            print("message dont init")
        }
        
    }
    /// De-register for configuration change notifications.
    /// Handle the user toggling the "enabled" switch.
    func test(_ domains:[String],enable:Bool,wifiEnable:Bool){
        var onDemandRules  = [NEOnDemandRule]()
        let newRule = NEOnDemandRuleEvaluateConnection()
        var connectionRules:[NEEvaluateConnectionRule] = []
        //print(newRule.connectionRules)
        //newRule.DNSSearchDomainMatch = domains
        
        let  r:NEEvaluateConnectionRule = NEEvaluateConnectionRule.init(matchDomains: domains, andAction: .connectIfNeeded)
        
        if wifiEnable {
            newRule.interfaceTypeMatch = .any
        }else {
            #if os(iOS)
                newRule.interfaceTypeMatch = .cellular
                #else
                newRule.interfaceTypeMatch = .any
                #endif
           
            
        }
        connectionRules.append(r)
        newRule.connectionRules = connectionRules
        newRule.interfaceTypeMatch = .any
        
        
        
        onDemandRules.append(newRule)
        print(onDemandRules)
    }
    func test2(_ domains:[String],enable:Bool,wifiEnable:Bool)   {
    
        var onDemandRules  = [NEOnDemandRule]()
        
        
        let newRule = NEOnDemandRuleConnect()
        
        newRule.dnsSearchDomainMatch = domains
        
        if wifiEnable {
            newRule.interfaceTypeMatch = .any
        }else {
            #if os(iOS)
                newRule.interfaceTypeMatch = .cellular
            #else
                newRule.interfaceTypeMatch = .any
            #endif
            //newRule.interfaceTypeMatch = .Cellular
        }
        
        onDemandRules.append(newRule)
        print(onDemandRules)
        
        
    }
    func addOnDemandRule(_ domains:[String],wifiEnable:Bool,enable:Bool,completion: ((Error?) -> Void)?){
        if let m = manager {
            
            var onDemandRules  = [NEOnDemandRule]()
            let newRule = NEOnDemandRuleEvaluateConnection()
            var connectionRules:[NEEvaluateConnectionRule] = []
            //print(newRule.connectionRules)
            //newRule.DNSSearchDomainMatch = domains
            
            let  r:NEEvaluateConnectionRule = NEEvaluateConnectionRule.init(matchDomains: domains, andAction: .connectIfNeeded)
            
            if wifiEnable {
                newRule.interfaceTypeMatch = .any
            }else {
                #if os(iOS)
                    newRule.interfaceTypeMatch = .cellular
                #else
                    newRule.interfaceTypeMatch = .any
                #endif
                //newRule.interfaceTypeMatch = .Cellular
            }
            if connectionRules.count > 0 {
                connectionRules.removeAll()
            }
            connectionRules.append(r)
            newRule.connectionRules = connectionRules
            
            
            
            
            onDemandRules.append(newRule)
            print(onDemandRules)
            
            
            m.onDemandRules = onDemandRules
            m.isOnDemandEnabled = enable
            //fixme
            m.saveToPreferences(completionHandler: { (error) -> Void in
                if let completion = completion {
                     completion(error)
                }
            })
           
            
        }
        
    }
    func enabledToggled(_ start:Bool) {
        if let m = manager {
            m.isEnabled = true
            let bId = Bundle.main.infoDictionary!["CFBundleIdentifier"] as! String
            if bId == "com.yarshure.Surf" {
                m.localizedDescription = "Surfing"
            }else {
                m.localizedDescription = "Surfing Today"
            }
            m.saveToPreferences {  error in
                guard error == nil else {
                    //self.enabledSwitch.on = self.targetManager.enabled
                    //self.startStopToggle.enabled = self.enabledSwitch.on
                    print("show update status")
                    
                    return
                }
                
                
                m.loadFromPreferences { error in
                    //self.enabledSwitch.on = self.targetManager.enabled
                    //self.startStopToggle.enabled = self.enabledSwitch.on
                    print("loadFromPreferencesWithCompletionHandler \(String(describing: error?.localizedDescription))")
                   // self!.tableView.reloadData()
                    if start {
                        do {
                            _ = try self.startStopToggled(self.config)
                        }catch let error {
                            print(error)
                        }
                        
                    }
                    
                }
                
            }
        }
    
    }
    /// Handle the user toggling the "VPN" switch.
    func startStopToggled(_ config:String) throws ->Bool{
        if let m = manager {
            self.config = config
            if self.config.isEmpty{
                self.config = ProxyGroupSettings.share.config
            }
            if m.connection.status == .disconnected || m.connection.status == .invalid {
                do {
                    
                    if  m.isEnabled {
                         let u = groupContainerURL()
                         let path = u.path
                            print("starting!!! path:\(u)")
                            try m.connection.startVPNTunnel(options: [kConfig:config as NSString,kPro:proVersion as NSObject,kPath:path as NSString])
                            
                        
                       
                        
                        
                    }else {
                        enabledToggled(true)
                    }
                }
                catch let error  {
                    throw error
                    //mylog("Failed to start the VPN: \(error)")
                }
            }
            else {
                print("stoping!!!")
                m.connection.stopVPNTunnel()
            }
        }else {
            
            return false
        }
        return true
    }
}
