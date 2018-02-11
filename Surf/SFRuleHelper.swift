//
//  SFRuleHelper.swift
//  Surf
//
//  Created by 孔祥波 on 16/5/4.
//  Copyright © 2016年 abigt. All rights reserved.
//

import Foundation


import Foundation
//import SQLite





class SFRuleHelper{
    static let shared = SFRuleHelper()
    var db:Connection?
    func testimport(){
        let p = Bundle.main.path(forResource:"rules_public.conf", ofType: nil)
        open("rule8.db", readonly: false)
        if let path = p {
            let content = try!  NSString.init(contentsOfFile: path, encoding: NSUTF8StringEncoding)
            let x = content.components(separatedBy: "\n")
            for item in x {
                let r  = SFRuler()
                if item.hasPrefix("DOMAIN-KEYWORD"){
                    //print("Keyword rule")
                    r.type = .DOMAINKEYWORD
                    let x2 = item.components(separatedBy: ",")
                    r.name = x2[1].trimmingCharacters(in: .whitespacesAndNewlines)
                    r.proxyName = x2[2].trimmingCharacters(in: .whitespacesAndNewlines)

                }else if item.hasPrefix("DOMAIN-SUFFIX") || item.hasPrefix("DOMAIN"){
                    //print(" DOMAIN Keyword rule")
                    let x2 = item.components(separatedBy: ",")
                    r.name = x2[1].trimmingCharacters(in: .whitespacesAndNewlines)

                    r.proxyName = x2[2].trimmingCharacters(in: .whitespacesAndNewlines)

                    r.type = .DOMAINSUFFIX
                }else if item.hasPrefix("GEOIP"){
                    //print("GEOIP Keyword rule")
                    r.type = .GEOIP
                    let x2 = item.components(separatedBy: ",")
                    r.name = x2[1].trimmingCharacters(in: .whitespacesAndNewlines)

                    r.proxyName = x2[2].trimmingCharacters(in: .whitespacesAndNewlines)

                }else if item.hasPrefix("IP-CIDR"){
                    //print(" IP-CIDR Keyword rule")
                    r.type = .IPCIDR
                    let x2 = item.components(separatedBy: ",")
                    r.name = x2[1].trimmingCharacters(in: .whitespacesAndNewlines)

                    r.proxyName = x2[2].trimmingCharacters(in: .whitespacesAndNewlines)

                }else if item.hasPrefix("FINAL"){
                    //print("Final Keyword rule")
                    r.type = .FINAL
                    let x2 = item.components(separatedBy: ",")
                    r.name = FINAL//x2[1].stringByTrimmingCharactersInSet(
                        //NSCharacterSet.whitespaceAndNewlineCharacterSet())

                    r.proxyName = x2[1].trimmingCharacters(in: .whitespacesAndNewlines)
                    
                }
                
                if !r.name.isEmpty && !r.proxyName.isEmpty{
                    print("RULE: " + r.name + " \(r.type.description) " + r.proxyName)
                    saveRuler(r)
                }
            }
        }
    }
    func open(path:String,readonly:Bool){
        
        //        if let d = db {
        //            //db.
        //        }
//        let t = NSDate().timeIntervalSince1970
//        var fn:String
//        if path.isEmpty {
//            fn = String.init(format:"%.0f.sqlite", t)
//        }else {
//            fn = path
//        }
        
        //let url0 = applicationDocumentsDirectory.appendingPathComponent(fn)
        let url = groupContainerURL().appendingPathComponent(path)
//        do{
//            try fm.copyItemAtURL(url0, toURL: url)
//        }catch let e as NSError{
//            print(e)
//        }
        
        if let p = url.path {
            do {
                db = try Connection(p,readonly: readonly)
                
                //initDatabase(db!)
            }catch let e as NSError{
                logStream.write("open db error \(e.description)")
                
            }
        }
        
    }
    
    func initDatabase(db:Connection) {
        let bId = Bundle.main.infoDictionary!["CFBundleIdentifier"] as! String
        if bId == "com.yarshure.Surf"  {
//            let rules = Table("rules")
//            

//            let name = Expression<String>("name")//domain or IP/mask
//            
//            let type = Expression<Int64>("type")
//            let policy = Expression<Int64>("policy")
//            
//            let proxyName = Expression<String>("proxyName")
            
            do {
                try db.run(rules.create { t in
                    t.column(id, primaryKey: .Autoincrement)
                    t.column(name,unique: true)//,
                    t.column(type)
                    t.column(policy)
                    t.column(proxyName)
                    })
            }catch let e as NSError {
                print(e.description)
            }
            
        }else {
            debugLog("don't need init db")
        }
    }
    func saveRuler(ruler:SFRuler)  {
        if ruler.name.isEmpty {
            return
        }
        if let d = db {
            do  {
                let rules = Table("rules")
                
                //let id = Expression<Int64>("id")
//                let name = Expression<String>("name")//domain or IP/mask
//                
//                let type = Expression<Int64>("type")
//                let policy = Expression<Int64>("policy")
//                let proxyName = Expression<String>("proxyName")
                
                
                try d.run(
                    rules.insert(
                    name <- ruler.name,
                    type <- ruler.typeId,
                    policy <- ruler.policyId,
                    proxyName <- ruler.proxyName
                       
                    )
                    //"INSERT OR REPLACE INTO rules (name, type, policy) " +
                    //"VALUES (?, ?, ?)", ruler.name, ruler.typeId, ruler.policyId
                )
            } catch let _ as NSError {
                AxLogger.log("insert error ")
            }
            
        }else {
            //logStream.write("open db error \(e.description)")
            AxLogger.log("insert error no db")
        }
    }
    func openForApp(){
        var fns:[String] = []
        //if db == nil {
        let p = groupContainerURL().path
        let files = try! FileManager.default.contentsOfDirectoryAtPath(p!)
        
        for file in files {
            if file.containsString(".sqlite") {
                //                    let url = groupContainerURL.appendingPathComponent(file)
                //                    fns.append(url.path!)
                fns.append(file)
            }
            //                let url = groupContainerURL.appendingPathComponent("Log/"+file)
            //                let att = try! fm.attributesOfItemAtPath(url.path!)
            //                let d  = att["NSFileCreationDate"] as! NSDate
            //                let size = att["NSFileSize"]! as! NSNumber
            //                let fn = SFFILE.init(n: file, d: d,size:size.longLongValue)
            //                self!.fileList.append(fn)
            //                self!.fileList.sortInPlace({ $0.date.compare($1.date) == NSComparisonResult.OrderedDescending })
        }
        
        //}
        let x = fns.removeLast()
        if !x.isEmpty {
            open(x,readonly: true)
        }
        for fx in fns  {
            let url = groupContainerURL().appendingPathComponent(fx)
            let destURL = applicationDocumentsDirectory.appendingPathComponent(fx)
            do {
                try fm.moveItemAtURL(url, toURL: destURL)
            }catch let e as NSError {
                print(e.description)
            }
        }
        
    }
    func  query(t:Int64,nameFilter:String) -> [SFRuler] {
        var result:[SFRuler] = []
        
       
        
        var dbx:Connection!
        if let db = db {
            dbx = db
        }else {
            return result
        }
        do {
            //requests.order([start.asc])
            //rules.filter(type == 1)
            var query:AnySequence<Row>  //= try dbx.prepare(rules.filter(type == t))
            if nameFilter.isEmpty {
               query = try dbx.prepare(rules.filter(type == t))
            }else {
                query = try dbx.prepare(rules.filter(type == t).filter( name == nameFilter))
            }
            for row in query {
                let req = SFRuler()
                req.name =  row[name]
                //print(row[url])
                //print(row[url])
                if let t = SFRulerType(rawValue:Int(row[type])) {
                    req.type = t
                }
                
                req.pWith(row[policy])
                req.proxyName = row[proxyName]
                AxLogger.log("###### host:\(req.name) ip:\(req.proxyName) \(req.type.description) \(nameFilter)")
                result.append(req)
               
            }
        }catch let e as NSError{
            print(e)
        }
        
        return result
    }
    
    func  query(domainName:String) -> [SFRuler] {
        var result:[SFRuler] = []
        
//        let rules = Table("rules")
//        let name = Expression<String>("name")//domain or IP/mask
//        
//        let type = Expression<Int64>("type")
//        let policy = Expression<Int64>("policy")
        
        
        var dbx:Connection!
        if let db = db {
            dbx = db
        }else {
            return result
        }
        do {
            //requests.order([start.asc])
            //rules.filter(type == 1)
            let query = try dbx.prepare(rules.filter(type == 2).filter( name == domainName))
            for row in query {
                let req = SFRuler()
                req.name =  row[name]
                //print(row[url])
                //print(row[url])
                if let t = SFRulerType(rawValue:Int(row[type])) {
                    req.type = t
                }
               
                req.pWith(row[policy])
                print("###### \(req.name) \(req.proxyName) \(req.type.description)")
                result.append(req)
                
            }
        }catch let e as NSError{
            print(e)
        }
        
        return result
    }

}
