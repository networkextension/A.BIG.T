//
//  SFCountry.swift
//  Surf
//
//  Created by abigt on 16/3/14.
//  Copyright © 2016年 abigt. All rights reserved.
//

import Foundation

import MMDB
import AxLogger
class CData {
    var code = ""
    var emoji = ""
    init(c:String,e:String){
        code = c
        emoji = e
    }
}

//"code": "AD",
//"emoji": "🇦🇩",
//"unicode": "U+1F1E6 U+1F1E9",
//"name": "Andorra",
//"title": "flag for Andorra"

struct CountryCode:Codable {
    var code:String = ""
    var emoji:String = ""
    var unicode:String = ""
    var name:String = ""
    var title:String = ""
}
struct CountryCodeList:Codable {
    var list:[CountryCode] = []
}
class Country {
    var db:MMDB?
    //var data:JSON?
    var list:[String:CountryCode] = [:]
    static let setting:Country = {
        let c = Country()
        if let path = Bundle.main.path(forResource:"data.json", ofType: nil) {
            do {
                let d = try Data.init(contentsOf: URL.init(fileURLWithPath: path))
                let list = try JSONDecoder().decode(CountryCodeList.self, from: d)
                for i  in list.list {
                    
                    c.list[i.code] = i
                    
                }
            }catch let e {
                print(e)
            }
           

            
        }else {
            fatalError()
        }
        
        return c
    }()
    func createdb()->Bool{
        //return false
        //for main app
        #if os(iOS)
        let p = Bundle.main.bundlePath + "/Frameworks/MMDB.framework/"
            #else
            let p = Bundle.main.bundlePath + "/Contents/Frameworks/MMDB.framework/"
            #endif
        guard let b = Bundle.init(path: p) else {return false }
        guard  let path = b.path(forResource:"GeoLite2-Country.mmdb", ofType: nil)  else {return false}
        
        //
        
        
        guard let d = MMDB(path) else {
            AxLogger.log("failed to open Geo db",level: .Error)
            return false
        }
        db = d
        return true
        
    }

    func geoIPRule(ipString:String) -> (emoji:String,isoCode:String){
        var haveDB = true
        if db == nil {
            if !createdb(){
                haveDB = false
            }
        }
        if haveDB{
            if let country:MMDBCountry = db!.lookup(ipString){
                let isoCode = country.isoCode
                if let result = list[isoCode] {
                    return (result.emoji,isoCode)
                }
                return ("",isoCode)
            }else {
                return ("","")
            }
        }
        return ("","")
    }
}
