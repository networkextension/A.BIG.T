//
//  DataShare.swift
//  Surf
//
//  Created by abigt on 15/12/4.
//  Copyright © 2015年 abigt. All rights reserved.
//

import Foundation
class  DataShare:NSObject{
    static  func save(sock:Socks) ->Bool{
        let path = DataShare.configPath()
        let r = NSKeyedArchiver.archiveRootObject(sock, toFile: path )
        if r {
            print("saved")
            return true
        }else {
            print("n")
            return false
        }
    }
    static  func configPath() ->String{
        
        let urlContain = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.yarshure.Surf")
        let url = urlContain!.appendingPathComponent(".config")
         let u = url.path 
        return u

    }
    static  func readConfig() ->Socks{
        let path = DataShare.configPath()
        let x = NSKeyedUnarchiver.unarchiveObject(withFile: path)
        if let list = x  {
            return list as! Socks
        }
        return Socks()
    }
}
