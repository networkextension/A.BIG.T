//
//  SFConfigManager.swift
//  Surf
//
//  Created by 孔祥波 on 8/20/16.
//  Copyright © 2016 abigt. All rights reserved.
//
//这个类给主app 使用
import Foundation
import SFSocket
import XRuler
class SFConfigManager {
    static let manager:SFConfigManager = SFConfigManager()
    func loadSettings() {
        //加载磁盘上的配置
    }
    init(){
        copyConfig()
    }
    var configs:[SFConfig] = []
    
    var selectConfig:SFConfig? {
        get {
            let c =  ProxyGroupSettings.share.config
            for cc in configs {
                if cc.configName + configExt == c {
                    return cc
                }
            }
            return nil
            
        }
        set {
            
            ProxyGroupSettings.share.config = newValue!.configName + configExt
            writeToGroup(newValue!.configName)
            
            try! ProxyGroupSettings.share.save()

        }
    }
    var icloudSyncEnabled:Bool = false
    var storageURL:URL{
        if icloudSyncEnabled {
            return applicationDocumentsDirectory
        }else {
            return applicationDocumentsDirectory
        }
    }
    func copyConfig(){
        let firstOpen = UserDefaults.standard.bool(forKey: "firstOpen")
        if firstOpen == false {
            let c = ["surf.conf","Default.conf"]//逗比极客精简版.json","逗比极客全能版.json","abclite普通版.json","abclite去广告版.json","surf_main.json"
            for f in c {
                if let p = Bundle.main.path(forResource: f, ofType: nil){
                    //let u = groupContainerURL.appendingPathComponent(f)
                    let u2 = applicationDocumentsDirectory.appendingPathComponent(f)
                    do {
                        //  try fm.copyItemAtPath(p, toPath: u.path!)
                        try fm.copyItem(atPath: p, toPath: u2.path)
                    }catch let e as NSError {
                        print("copy config file error \(e)")
                    }
                    
                }
            }
            
            do {
                let surf = "surf"
                let p = Bundle.main.path(forResource:surf + ".conf", ofType: nil)
                let u2 = groupContainerURL().appendingPathComponent("surf.conf")
                //  try fm.copyItemAtPath(p, toPath: u.path!)
                try fm.copyItem(atPath: p!, toPath: u2.path)
            }catch let e as NSError {
                print("copy config file error \(e)")
            }
            
            ProxyGroupSettings.share.config = "surf.conf"
            UserDefaults.standard.set(true, forKey: "firstOpen")
            UserDefaults.standard.synchronize()
        }else {
            
        }
    }
    
    func loadConfigs() {
      
        if configs.count > 0 {
            configs.removeAll() //防止多次进入
        }
        let settings = ProxyGroupSettings.share
        print(settings.proxys)
        //加载配置
        let u = storageURL
        
        do {
            let fns = try fm.contentsOfDirectory(atPath: u.path)
            for f in fns {
                if f.hasSuffix(".conf") {
                    let dest = u.appendingPathComponent(f)
                    let c = SFConfig.init(path:dest.path , loadRule: true)
                    configs.append(c)
                    
                    if f == ProxyGroupSettings.share.config {
                        selectConfig = c
                    }
                }
            }
            
        } catch let e as NSError {
            print(e.localizedDescription)
        }
    }
    
    
    func reloadConfig(_ name:String){
        //
        //重新加载配置，刷新Proxy 信息
        
        let fn = name + configExt
        let u = storageURL.appendingPathComponent(fn)
        let config = SFConfig.init(path:u.path , loadRule: true)
        
        var found = false
        var idx = 0
        for i in 0 ..< configs.count{
            let c = configs[i]
            if  c.configName   == name {
                found = true
                idx = i
                break
                
            }
        }
        if found {
            //let fn = c.configName + configExt
            //removeConfigFile(fn)
            configs.remove(at: idx)
            configs.insert(config, at: idx)
        }else {
            configs.append(config)
        }
        if let s = selectConfig {
            if s.configName == name {
                selectConfig = config
            }
        }
        //print("\(ProxyGroupSettings.share.config):\(f)")
        //if f == ProxyGroupSettings.share.config {
        //    selectConfig = c
        //}
    }
    func addConfig(_ config:SFConfig) {
        configs.append(config)
    }
    var configCount:Int {
        return configs.count
    }
    func configAtInde(_ index:Int) ->SFConfig {
        return configs[index]
    }
    func delConfig(_ config:SFConfig) {
        for i in 0 ..< configs.count{
            let c = configs[i]
            if  c == config {
                let fn = c.configName + configExt
                removeConfigFile(fn)
                configs.remove(at: i)
            }
        }
    }
    func delConfigAtIndex(_ index:Int) {
        if index < configs.count {
            let c = configs[index]
            let fn = c.configName + configExt
            removeConfigFile(fn)
            configs.remove(at: index)
        }
    }
    func removeConfigFile(_ fn:String){
        let u = storageURL.appendingPathComponent(fn)
        do {
            
            try fm.removeItem(at: u)
        }catch let e as NSError {
            print("error :\(e.localizedDescription)")
        }
    }
    func writeConfig(_ config:SFConfig) {
        //将某个config 写入文件
    }
    func urlForConfig(_ config:SFConfig) ->URL {
        let fn = config.configName + configExt
        let u = storageURL.appendingPathComponent(fn)
        return u
    }
    
    func writeToGroup(_ configName:String) {
        
        let fn = configName + configExt
        do {
            let p = storageURL.appendingPathComponent(fn)
            let u2 = groupContainerURL().appendingPathComponent(fn)
            
            
            //  try fm.copyItemAtPath(p, toPath: u.path!)
            if fm.fileExists(atPath: u2.path) {
                try fm.removeItem(atPath: u2.path)
            }
            
            try fm.copyItem(atPath: p.path, toPath: u2.path)
            
        }catch let e as NSError {
            print("copy config file error \(e)")
        }
    }
    func selectedIndex() ->Int{
        //缺省0
        var r = 0
        
        let fn = ProxyGroupSettings.share.config
        if !fn.isEmpty {
            for x in configs {
                let fnx = x.configName + configExt
                if  fnx == fn {
                    break
                }
                r += 1
            }
        }
        
        
       
        
        return r
    }
    func addRule(_ r:SFRuler) ->Bool{
        //从rule test result 添加
        var result = false
        if let s = selectConfig{
            if r.type == .ipcidr {
                s.ipcidrRulers.append(r)
                result = true
            }else if r.type == .domainsuffix {
                
                s.sufixRulers.append(r)
                result =  true
            }else {
                
            }
            
            if result {
                writeConfig(s)
            }
        }
        
        return result
    }
}
