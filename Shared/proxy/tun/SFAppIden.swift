//
//  SFAppIden.swift
//  Surf
//
//  Created by abigt on 16/2/15.
//  Copyright © 2016年 abigt. All rights reserved.
//

import Foundation

class SFAppIden {
    static let shared:SFAppIden = SFAppIden()
    var agents:[String:String] = [:]
    init() {
         let url = applicationDocumentsDirectory.appendingPathComponent(agentsFile)
        var info:NSDictionary
        if fm.fileExists(atPath:url.path) {
            info = NSDictionary.init(contentsOf: url)!
            
        }else {
            let u = Bundle.main.path(forResource:agentsFile, ofType: nil)//applicationDocumentsDirectory.appendingPathComponent(agentsFile)
            if fm.fileExists(atPath:u!) {
                info = NSDictionary.init(contentsOfFile: u!)!
                
            }else {
                info = NSDictionary()
            }
        }
        
        for (key,value) in info {
            agents[key as! String] = value as? String
        }
    }
    func appDesc(agent:String) ->String{
        //chrome "Mozilla/5.0 (iPhone; CPU iPhone OS 9_2_1 like Mac OS X) AppleWebKit/601.1 (KHTML, like Gecko) CriOS/48.0.2564.104 Mobile/13D15 Safari/601.1.46"
        //Dictionary
        for (k,v) in agents {
            if agent.range(of: k) != nil {
                return v
            }
        }
        
        var list = agent.components(separatedBy: "/")
        var result:String
        if list.count > 1 {
            if let a = list.first {
                result = a.removingPercentEncoding!
            }else {
                result = agent.removingPercentEncoding!
            }
            
        }else {
            list = agent.components(separatedBy: " ")
            if list.count > 0 {
                if let a = list.first {
                    result = a.removingPercentEncoding!
                }else {
                     result = agent.removingPercentEncoding!
                }
                
            }else {
                result = agent.removingPercentEncoding!
            }
            
        }
        agents[agent] = result
        save()
        return result
    }
    func save(){
        let info = NSMutableDictionary()
        for (k,v) in agents {
            info.setObject(v, forKey: k as NSCopying)
        }
        let p = applicationDocumentsDirectory.appendingPathComponent(agentsFile) 
        info.write(to: p, atomically: true)
    }
}
