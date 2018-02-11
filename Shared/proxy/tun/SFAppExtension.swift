//
//  SFAppExtension.swift
//  Surf
//
//  Created by 孔祥波 on 8/2/16.
//  Copyright © 2016 abigt. All rights reserved.
//

import Foundation
#if os(iOS)
import UIKit
    
#else
import Cocoa
    
#endif
import SFSocket
import XProxy
import XRuler
//这个extension for main app的
extension SFRequestInfo {
    func detailString() ->NSAttributedString {
        
        
        var t:String = ""// self.dataDesc(sTime)
        var agent:String
        
        
        if self.mode == .TCP{
            agent = "RAW"
        }else {
            
            agent = "\(SFAppIden.shared.appDesc(agent: self.app))"
            if let resp = respHeader {
                t = "Status: " + String(resp.sCode)
            }
        }
        
        var  modeString:String = " " + self.mode.description + " "
        if self.mode == .HTTP {
            if let req = reqHeader {
                modeString = " " + req.method.rawValue + " "
            }else {
                modeString = " " + self.mode.description + " "
            }
            
            
            
            
        }
        let rule =  self.rule
        
        //        var color:UIColor = UIColor.blackColor()
        //        if rule.policy == .Reject {
        //            color = UIColor.redColor()
        //        }else if rule.policy == .Proxy {
        //            color = UIColor.greenColor()
        //        }
        let p = rule.policyString()
        var x:String
        if t.isEmpty {
            x = modeString + "  " + agent + " \(rule.policyString()) " + self.status.description + " remote " + self.remoteIPaddress
        }else {
            x = modeString + "  " + agent + " " + "\(t)  \(rule.policyString()) " + self.status.description + " remote " + self.remoteIPaddress
        }
        
        let s = NSMutableAttributedString(string:x )
        var r = (x as NSString).range(of: p)
        //let range = NSMakeRange(r?.startIndex, )
        
       
        #if os (iOS)
            var color:UIColor = UIColor.orange
            if rule.policy == .Reject {
                color = UIColor.red
            }else if rule.policy == .Proxy {
                color = UIColor.green
            }
            
            let ra = (x as NSString).range(of: agent)
            s.addAttributes([NSAttributedStringKey.backgroundColor:UIColor.red,NSAttributedStringKey.foregroundColor:UIColor.white], range: ra)
            
            s.addAttributes([NSAttributedStringKey.foregroundColor:color], range: r)
            
            r = (x as NSString).range(of: modeString)
            
            s.addAttributes([NSAttributedStringKey.foregroundColor:UIColor.white,NSAttributedStringKey.backgroundColor:UIColor.blue], range: r)
            if !t.isEmpty{
                let scode =  UIColor.init(red: 0.36, green: 0.65, blue: 0.76, alpha: 1.0)
                let srange = (x as NSString).range(of: t)
                s.addAttributes([NSAttributedStringKey.foregroundColor:scode], range: srange)
            }
            
        #else
            var color:NSColor = NSColor.orange
            if rule.policy == .Reject {
                color = NSColor.red
            }else if rule.policy == .Proxy {
                color = NSColor.green
            }
            
            
            s.addAttributes([NSAttributedStringKey.foregroundColor:color], range: r)
            
            r = (x as NSString).range(of: modeString)
            
            s.addAttributes([NSAttributedStringKey.foregroundColor:NSColor.white,NSAttributedStringKey.backgroundColor:NSColor.blue], range: r)
            #endif
        return s
        
        
        
    }
}
extension SFConfig{
    func writeConfig(name:String,copy:Bool, force:Bool,shareiTunes:Bool) -> SFConfigWriteError {
        // copy ,true to groupdir,false save to iTunes share or stand save
        //
        if configName.isEmpty {
            return .noName
        }
        let storageURL = SFConfigManager.manager.storageURL
        if name != configName {
            //copy or changed configName
            if !copy {
                //delete old
                let temp = storageURL.appendingPathComponent(configName + configExt)
                do {
                    try fm.removeItem(at: temp)
                }catch let e as NSError{
                    print("error :\(e.localizedDescription)")
                }
            }else {
                //copy
                
            }
        }else {
            //相等就是直接写
        }
        //guard let doc = applicationDocumentsDirectory else  {return .Other}
        var  destURL:URL
        
        if copy {
            destURL = storageURL.appendingPathComponent (name + configExt)
        }else {
            if name.isEmpty {
                //stand save
                destURL = storageURL.appendingPathComponent (configName + configExt)
            }else {
                if name == configName {
                    destURL  = storageURL.appendingPathComponent (configName + configExt)
                }else {
                    
                    destURL  = storageURL.appendingPathComponent (name + configExt)
                    if configName != "surf" {
                        let temp   = storageURL.appendingPathComponent (configName + configExt)
                        do {
                            try fm.removeItem(atPath: temp.path)
                        } catch let e as NSError {
                            print(e)
                        }
                    }
                    
                    
                }
                
            }
        }
        //configName = name
        
        let data = genData()
        
        
        if force {
            if fm.fileExists(atPath: destURL.path){
                try! fm.removeItem(at: destURL)
            }
            try! data.write(to: destURL, atomically: true,encoding:String.Encoding.utf8)
            //这里写也没什么太大问题
            let groupURL  = groupContainerURL().appendingPathComponent (name + configExt)
            
            if fm.fileExists(atPath: groupURL.path) {
                try! fm.removeItem(at: groupURL)
            }
            try! fm.copyItem(at: destURL, to:groupURL )
        }else {
            if fm.fileExists(atPath: destURL.path){
                return .exist
            }else {
                try! data.write(to: destURL, atomically: true,encoding:String.Encoding.utf8)
            }
        }
        
        if shareiTunes {
            destURL  = applicationDocumentsDirectory.appendingPathComponent (name + configExt)
            try! data.write(to: destURL, atomically: true,encoding:String.Encoding.utf8)
            //                do{
            //                    try
            //                }catch _{
            //
            //                }
            
        }
        
        
        return .success
    }
}
