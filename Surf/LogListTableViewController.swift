//
//  LogListTableViewController.swift
//  Surf
//
//  Created by abigt on 15/12/7.
//  Copyright © 2015年 abigt. All rights reserved.
//

import UIKit
import SFSocket

import XRuler
struct SFFILE {
    var name:String
    var date:NSDate
    var size:Int64
    init(n:String,d:NSDate,size:Int64){
        name = n
        date = d
        self.size = size
    }
    var desc:String{
        //print(size)
        if size >= 1024 && size < 1024*1024 {
            return "size: \(size/1024) KB"
        }else if size >= 1024*1024 {
            return "size: \(size/(1024*1024)) MB"
        }else {
            return "size: \(size) byte"
        }
        
    }
}
open class SFVPNStatisticsApp {
    //public static let shared = SFVPNStatistics()
    public var startDate =  Date.init(timeIntervalSince1970: 0)
    public var sessionStartTime = Date()
    public var reportTime =  Date.init(timeIntervalSince1970: 0)
    public var startTimes = 0
    public var show:Bool = false
    public var totalTraffice:SFTraffic = SFTraffic()
    public var currentTraffice:SFTraffic = SFTraffic()
    public var lastTraffice:SFTraffic = SFTraffic()
    public var maxTraffice:SFTraffic = SFTraffic()
    
    public var wifiTraffice:SFTraffic = SFTraffic()
    public var cellTraffice:SFTraffic = SFTraffic()
    
    public var directTraffice:SFTraffic = SFTraffic()
    public var proxyTraffice:SFTraffic = SFTraffic()
    public var memoryUsed:UInt64 = 0
    public var finishedCount:Int = 0
    public var workingCount:Int = 0
    public var runing:String {
        get {
            //let now = Date()
            let second = Int(reportTime.timeIntervalSince(sessionStartTime))
            return secondToString(second: second)
        }
    }
    public func updateMax() {
        if lastTraffice.tx > maxTraffice.tx{
            maxTraffice.tx = lastTraffice.tx
        }
        if lastTraffice.rx > maxTraffice.rx {
            maxTraffice.rx = lastTraffice.rx
        }
    }
    public func secondToString(second:Int) ->String {
        
        let sec = second % 60
        let min = second % (60*60) / 60
        let hour = second / (60*60)
        
        return String.init(format: "%02d:%02d:%02d", hour,min,sec)
        
        
    }
    public func map(j:JSON) {
        startDate = Date.init(timeIntervalSince1970: j["start"].doubleValue) as Date
        sessionStartTime = Date.init(timeIntervalSince1970: j["sessionStartTime"].doubleValue)
        reportTime = NSDate.init(timeIntervalSince1970: j["report_date"].doubleValue) as Date
        totalTraffice.mapObject(j: j["total"])
        lastTraffice.mapObject(j: j["last"])
        maxTraffice.mapObject(j: j["max"])
        
        cellTraffice.mapObject(j:j["cell"])
        wifiTraffice.mapObject(j: j["wifi"])
        directTraffice.mapObject(j: j["direct"])
        proxyTraffice.mapObject(j: j["proxy"])
//        if let c  = j["memory"].uInt64 {
//            memoryUsed = c
//        }
//        if let tcp = j["finishedCount"].int {
//            finishedCount = tcp
//        }
//        if let tcp = j["workingCount"].int {
//            workingCount = tcp
//        }
    }
    func resport() ->Data{
        //reportTime = Date()
        //memoryUsed = reportMemoryUsed()//reportCurrentMemory()
        
        var status:[String:AnyObject] = [:]
        status["start"] =  NSNumber.init(value: startDate.timeIntervalSince1970)
        status["sessionStartTime"] =  NSNumber.init(value: sessionStartTime.timeIntervalSince1970)
        status["report_date"] =  NSNumber.init(value: reportTime.timeIntervalSince1970)
        //status["runing"] = NSNumber.init(double:runing)
        status["total"] = totalTraffice.resp() as AnyObject?
        status["last"] = lastTraffice.resp() as AnyObject?
        status["max"] = maxTraffice.resp() as AnyObject?
        status["memory"] = NSNumber.init(value: memoryUsed) //memoryUsed)
        
        //let count = SFTCPConnectionManager.manager.connections.count
        status["finishedCount"] = NSNumber.init(value: finishedCount) //
        //status["workingCount"] = NSNumber.init(value: count) //
        
        status["cell"] = cellTraffice.resp() as AnyObject?
        status["wifi"] = wifiTraffice.resp() as AnyObject?
        status["direct"] = directTraffice.resp() as AnyObject?
        status["proxy"] = proxyTraffice.resp() as AnyObject?
        
        let j = JSON(status)
        
        
        
        
        //print("recentRequestData \(j)")
        var data:Data
        do {
            try data = j.rawData()
        }catch let error  {
            //AxLogger.log("ruleResultData error \(error.localizedDescription)")
            //let x = error.localizedDescription
            //let err = "report error"
            data =  error.localizedDescription.data(using: .utf8)!// NSData()
        }
        return data
    }
    public func memoryString() ->String {
        let f = Float(memoryUsed)
        if memoryUsed < 1024 {
            return "\(memoryUsed) Bytes"
        }else if memoryUsed >=  1024 &&  memoryUsed <  1024*1024 {
            
            return  String(format: "%.2f KB", f/1024.0)
        }
        return String(format: "%.2f MB", f/1024.0/1024.0)
        
    }
}
class LogListTableViewController: SFTableViewController {
    
    var filePath:String = ""
    var fileList:[SFFILE] = []
    var showSession:Bool = false
    var reportInfo:SFVPNStatisticsApp?
    override func viewDidLoad() {
        super.viewDidLoad()
        if filePath.isEmpty {
            self.title = "Sessions"
        }else {
            self.title = "Session Detail"
            showSession = true
        }
        
        findFiles()
        navigationItem.rightBarButtonItem = editButtonItem
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    @IBAction func deleteAll(_ sender:AnyObject) {
        
        if let m = SFVPNManager.shared.manager , m.connection.status == .connected {
            for file in fileList.dropFirst() {
                let url = groupContainerURL().appendingPathComponent("Log/"+file.name)
                do {
                    try fm.removeItem(at: url)
                }catch let error as NSError {
                    alertMessageAction("delete \(url.path) failure: \(error.description)",complete: nil)
                    return
                }
                
            }
        }else {
            for file in fileList {
                let url = groupContainerURL().appendingPathComponent("Log/"+file.name)
                do {
                    try fm.removeItem(at: url)
                }catch let error as NSError {
                    alertMessageAction("delete \(url.path) failure: \(error.description)",complete: nil)
                    return
                }
                
            }
        }
        
        findFiles()
    }
    func findFiles(){
        let q = DispatchQueue(label:"com.yarshure.sortlog")
        q.async(execute:  { [weak self] () -> Void in
            
            self!.fileList.removeAll()
            //let urlContain = FileManager.default.containerURLForSecurityApplicationGroupIdentifier("group.com.yarshure.Surf")
            let url = groupContainerURL().appendingPathComponent("Log/" + self!.filePath)
            
            let dir = url.path //NSHomeDirectory().NS.stringByAppendingPathComponent("Documents/applog")
            if FileManager.default.fileExists(atPath:dir) {
                let files = try! FileManager.default.contentsOfDirectory(atPath: dir)
                var tmpArray:[SFFILE] = []
                for file in files {
                    let url = url.appendingPathComponent(file)
                    let att = try! fm.attributesOfItem(atPath: url.path)
                    let d  = att[ FileAttributeKey.init("NSFileCreationDate")] as! NSDate
                    let size = att[FileAttributeKey.init("NSFileSize")]! as! NSNumber
                    let fn = SFFILE.init(n: file, d: d,size:size.int64Value)
                    
                    tmpArray.append(fn)
                    
                }
                tmpArray.sort(by: { $0.date.compare($1.date as Date) == ComparisonResult.orderedDescending })
                DispatchQueue.main.async(execute: {
                    if  let strongSelf = self {
                        strongSelf.fileList.append(contentsOf: tmpArray)
                        if strongSelf.showSession {
                            strongSelf.loadReport()
                        }else {
                            strongSelf.tableView.reloadData()
                        }
                        
                    }
                })
                
                
                
                
            }else {
                
            }
        })
        
        
        //fileList = try!  FileManager.default.contentsOfDirectoryAtURL(url, includingPropertiesForKeys keys: [String]?, options mask: NSDirectoryEnumerationOptions) throws -> [NSURL]
        
    }
    func loadReport(){
        let url = groupContainerURL().appendingPathComponent("Log/" + self.filePath + "/db.zip")
        let urlJson = groupContainerURL().appendingPathComponent("Log/" + self.filePath + "/session.json")
        if FileManager.default.fileExists(atPath: urlJson.path){
             reportInfo = SFVPNStatisticsApp()//.init(name: self.filePath)
            do {
                let data = try  Data.init(contentsOf: urlJson)
                let obj = try! JSON.init(data: data)
                reportInfo!.map(j: obj)
                tableView.reloadData()
                return
            }catch let e {
                 alertMessageAction("\(e.localizedDescription)", complete: nil)
            }
            
        }
        if FileManager.default.fileExists(atPath: url.path){
            let  _ = RequestHelper.shared.openForApp(self.filePath)
            let resultsFin = RequestHelper.shared.query()
            reportInfo = SFVPNStatisticsApp()//.init(name: self.filePath)
            for req in resultsFin {
                reportInfo?.totalTraffice.addRx(x:Int(req.traffice.rx) )
                reportInfo?.totalTraffice.addTx(x:Int(req.traffice.tx) )
                if req.interfaceCell == 1 {
                    reportInfo?.cellTraffice.addRx(x: Int(req.traffice.rx))
                    reportInfo?.cellTraffice.addTx(x: Int(req.traffice.tx))
                }else {
                    reportInfo?.wifiTraffice.addRx(x: Int(req.traffice.rx))
                    reportInfo?.wifiTraffice.addTx(x: Int(req.traffice.tx))
                }
                
                if req.rule.policy == .Direct {
                    reportInfo?.directTraffice.addRx(x: Int(req.traffice.rx))
                    reportInfo?.directTraffice.addTx(x: Int(req.traffice.tx))
                }else {
                    reportInfo?.proxyTraffice.addRx(x: Int(req.traffice.rx))
                    reportInfo?.proxyTraffice.addTx(x: Int(req.traffice.tx))
                }
                if req.sTime.compare(reportInfo!.sessionStartTime)  == .orderedAscending{
                    reportInfo!.sessionStartTime = req.sTime
                }
                if req.eTime.compare(reportInfo!.reportTime) == .orderedDescending {
                    reportInfo!.reportTime = req.eTime
                }
            }
            
            let data = reportInfo!.resport()
            let url = groupContainerURL().appendingPathComponent("Log/" + self.filePath + "/session.json")
            do {
                try data.write(to:url )
            } catch let e {
                alertMessageAction("\(e.localizedDescription)", complete: nil)
            }
        }
        tableView.reloadData()
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if filePath.isEmpty {
            let dir = fileList[indexPath.row]
            print(dir)
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "filelist") as! LogListTableViewController
            vc.filePath = dir.name
            self.navigationController?.pushViewController(vc, animated: true)
            
        }else {
            let cell = tableView.cellForRow(at: indexPath)
            if indexPath.row > fileList.count {
                self.performSegue(withIdentifier: "showFile", sender: cell)
            }else {
                let f = fileList[indexPath.row]
                if f.name == "db.zip" {
                    self.performSegue(withIdentifier: "showDB", sender: cell)
                }else {
                    self.performSegue(withIdentifier: "showFile", sender: cell)
                }

            }
            
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        // #warning Incomplete implementation, return the number of sections
        if filePath.isEmpty {
            if fileList.count == 0 {
                return 1
            }
            
            return 2
        }else {
            return 2
        }
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            if fileList.count == 0 {
                return 1
            }
            return fileList.count
        }else {
            if showSession {
                if let _ = reportInfo{
                     return 6
                }else {
                    return 0 
                }
               
            }else {
                return 1
            }
            
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "logidentifier", for: indexPath as IndexPath)
            if fileList.count == 0 {
                cell.textLabel?.text = "No log files"
                cell.detailTextLabel?.text = ""
            }else {
                // Configure the cell...
                //bug
                if indexPath.row < fileList.count {
                    let f = fileList[indexPath.row]
                    cell.textLabel?.text = f.name
                    if !filePath.isEmpty {
                        cell.detailTextLabel?.text = f.desc
                    }else {
                        cell.detailTextLabel?.text = ""
                    }
                    
                }
                
            }
            cell.updateStandUI()
            return cell
        }else {
            
            if showSession {
                let cell = tableView.dequeueReusableCell(withIdentifier: "StatusCell", for: indexPath as IndexPath) as! StatusCell
                
                guard let r = self.reportInfo else {
                    return cell
                }
                configCell(cell: cell,indexPath: indexPath, report: r)
                return cell
            }else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "deleteAll", for: indexPath as IndexPath)
                
                return cell
            }
        }
        
    }
    func configCell(cell:StatusCell, indexPath:IndexPath,report:SFVPNStatisticsApp){
        let flag = true
        
        let f = UIFont.init(name: "Ionicons", size: 20)!
        cell.downLabel.text = "\u{f35d}"
        cell.downLabel.font = f
        cell.upLabel.text = "\u{f366}"
        cell.upLabel.font = f
   
        cell.updateUI()
        
        switch indexPath.row {
            
            
        case 0:
            cell.catLabel.text = "\u{f3b3}"
            cell.downInfoLabel.isHidden = true //report.memoryString()
            cell.downLabel.isHidden = true
            cell.upLabel.isHidden = true
            cell.upInfoLabel.text = report.runing
            return
            
            
            
        case 1:
            cell.catLabel.text = "\u{f37c}"
            //cell.textLabel?.text = "Total: \(report.totalTraffice.reportTraffic())"
            cell.upInfoLabel.text = report.totalTraffice.toString(x: report.totalTraffice.tx,label: "",speed: false)
            cell.downInfoLabel.text = report.totalTraffice.toString(x: report.totalTraffice.rx,label: "",speed: false)
        case 2:
            cell.upInfoLabel.text = report.directTraffice.toString(x: report.directTraffice.tx,label: "",speed: false)
            cell.downInfoLabel.text = report.directTraffice.toString(x: report.directTraffice.rx,label: "",speed: false)
            cell.catLabel.text = "\u{f394}"//cell.textLabel?.text = "DIRECT: \(report.directTraffice.reportTraffic())"
        case 3:
            //cell.textLabel?.text = "PROXY: \(report.proxyTraffice.reportTraffic())"
            cell.catLabel.text = "\u{f4a8}"
            cell.upInfoLabel.text = report.proxyTraffice.toString(x: report.proxyTraffice.tx,label: "",speed: false)
            cell.downInfoLabel.text = report.proxyTraffice.toString(x: report.proxyTraffice.rx,label: "",speed: false)
        case 4:
            //cell.textLabel?.attributedText = report.wifi()
            cell.upInfoLabel.text = report.wifiTraffice.toString(x: report.wifiTraffice.tx,label: "",speed: false)
            cell.downInfoLabel.text = report.wifiTraffice.toString(x: report.wifiTraffice.rx,label: "",speed: false)
            cell.catLabel.text = "\u{f25c}"
        case 5:
            //cell.textLabel?.text = "CELL: \(report.cellTraffice.reportTraffic())"
            cell.upInfoLabel.text = report.cellTraffice.toString(x: report.cellTraffice.tx,label: "",speed: false)
            cell.downInfoLabel.text = report.cellTraffice.toString(x: report.cellTraffice.rx,label: "",speed: false)
            cell.catLabel.text = "\u{f274}"
            
        default:
            break
        }
        /*
        if flag {
            
            
            //print("TCP Connection: \(report.connectionCount) memory:\(report.memoryUsed) ")
        }else {
            cell.textLabel?.text = "Session Not Start"
            cell.catLabel.isHidden = true
            cell.downLabel.isHidden = true
            cell.downInfoLabel.isHidden = true
            cell.upLabel.isHidden = true
            cell.upInfoLabel.isHidden = true
        }*/
        cell.downLabel.isHidden = false
        cell.upLabel.isHidden = false
    }
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        if indexPath.section == 0 && fileList.count == 0 {
            return nil
        }
        if indexPath.section == 1 {
            return nil
        }
        return indexPath
        
        
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        if indexPath.row == 0 {
            guard  let m = SFVPNManager.shared.manager else {return true}
            if m.connection.status == .connected  {
                return false
            }else {
                if fileList.count == 0 {
                    return false
                }
                return true
            }
            
        }
        return true
    }
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        
        if indexPath.item < fileList.count {
            return .delete
        }
        
        return .delete
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete{
            let f = fileList[indexPath.row]
            let url = groupContainerURL().appendingPathComponent("Log/" + self.filePath  + "/" + f.name)
            //saveProxys()
            do {
                try  fm.removeItem(at: url)
                fileList.remove(at: indexPath.row)
            } catch _ {
                
            }
            
            
            tableView.reloadData()
        }
        
    }

    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showFile"{
            
            guard let addEditController = segue.destination as? LogFileViewController else{return}
            let cell = sender as? UITableViewCell
            guard let indexPath = tableView.indexPath(for: cell!) else {return }
           
            
            let f = fileList[indexPath.row]
            addEditController.navigationItem.title = f.name
            
            let url = groupContainerURL().appendingPathComponent("Log/" + self.filePath + "/" +  f.name)
            
            addEditController.filePath = url
            // addEditController.delegate = self
        }else if segue.identifier == "showDB" {
             guard let vc = segue.destination as? HistoryViewController else{return}
            vc.session = self.filePath
        }
    }
    
    
}
