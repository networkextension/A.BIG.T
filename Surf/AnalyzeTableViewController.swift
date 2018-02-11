//
//  AnalyzeTableViewController.swift
//  Surf
//
//  Created by abigt on 16/2/14.
//  Copyright © 2016年 abigt. All rights reserved.
//

import UIKit
import NetworkExtension
import SwiftyJSON
import SFSocket
import CoreTelephony
import Fabric
import SystemKitiOS
import IoniconsSwift
import XRuler
extension SFVPNStatistics{
    func status() ->NSAttributedString {
        let txt = "\u{f35a}\t\(self.runing)" + " Memory: " + self.memoryString()
        let s = NSMutableAttributedString(string:txt)
        let f = UIFont.init(name: "Ionicons", size: 20)!
        s.addAttributes([NSAttributedStringKey.font:f], range: NSMakeRange(0, 1))
        return s
    }
    func speed() ->NSAttributedString{
        let text = "Speed: \(self.lastTraffice.report())"
        let s = NSMutableAttributedString(string:text)
        let f = UIFont.init(name: "Ionicons", size: 20)!
        s.addAttributes([NSAttributedStringKey.font:f], range: NSMakeRange(0, 1))
        return s

        
    }
    func maxspeed() ->NSAttributedString{
         let text = "Max Speed: \(self.maxTraffice.report())"
        let s = NSMutableAttributedString(string:text)
        let f = UIFont.init(name: "Ionicons", size: 20)!
        s.addAttributes([NSAttributedStringKey.font:f], range: NSMakeRange(0, 1))
        return s

    }
    func cell() ->NSAttributedString{
        let text = "Total: \(self.totalTraffice.reportTraffic())"
        let s = NSMutableAttributedString(string:text)
        let f = UIFont.init(name: "Ionicons", size: 20)!
        s.addAttributes([NSAttributedStringKey.font:f], range: NSMakeRange(0, 1))
        return s

    }
    func wifi() ->NSAttributedString{
        let text = "\u{f25c} \(self.wifiTraffice.reportTraffic())"
        let s = NSMutableAttributedString(string:text)
        let f = UIFont.init(name: "Ionicons", size: 20)!
        s.addAttributes([NSAttributedStringKey.font:f], range: NSMakeRange(0, 1))
        return s

        
        //let text = "DIRECT: \(self.directTraffice.reportTraffic())"
    }
    func direct() ->NSAttributedString{
        let text = "PROXY: \(self.proxyTraffice.reportTraffic())"
        let s = NSMutableAttributedString(string:text)
        let f = UIFont.init(name: "Ionicons", size: 20)!
        s.addAttributes([NSAttributedStringKey.font:f], range: NSMakeRange(0, 1))
        return s

    }
    func proxy() ->NSAttributedString{
       
        let text = "CELL: \(self.cellTraffice.reportTraffic())"
        let s = NSMutableAttributedString(string:text)
        let f = UIFont.init(name: "Ionicons", size: 20)!
        s.addAttributes([NSAttributedStringKey.font:f], range: NSMakeRange(0, 1))
        return s

    }
}
class StatusCell: UITableViewCell {
    @IBOutlet weak var catLabel:UILabel!
    @IBOutlet weak var upLabel:UILabel!
    @IBOutlet weak var upInfoLabel:UILabel!
    @IBOutlet weak var downLabel:UILabel!
    @IBOutlet weak var downInfoLabel:UILabel!
    func updateUI() {
        if ProxyGroupSettings.share.wwdcStyle {
            catLabel.textColor = UIColor.white
            downLabel.textColor = UIColor.white
            downInfoLabel.textColor = UIColor.white
            upLabel.textColor = UIColor.white
            upInfoLabel.textColor = UIColor.white
        }else {
            catLabel.textColor = UIColor.black
            downLabel.textColor = UIColor.black
            downInfoLabel.textColor = UIColor.black
            upLabel.textColor = UIColor.black
            upInfoLabel.textColor = UIColor.black
        }
    }
}
class AnalyzeTableViewController: SFTableViewController {

    var report:SFVPNStatistics = SFVPNStatistics.shared
    //var last:SFInterfaceTraffic = SFInterfaceTraffic()
    let df = DateFormatter()
    var charts:[Double] = []
    let info = CTTelephonyNetworkInfo()
    var lastreportDate = Date()
    @IBOutlet weak var chartsView:ChartsView!
    var reportTimer:Timer?
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.navigationController?.tabBarItem.image = Ionicons.statsBars.image(30)
        self.navigationController?.tabBarItem.title =  "Analyze".localized
        self.title = "Analyze".localized
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        df.dateFormat = "yyyy/MM/dd HH:mm:ss"
        self.title = "Analyze".localized
        
        //self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "Refresh", style: .plain, target: self, action: #selector(requestReportXPC(_:)))
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) ->CGFloat{
        
        return 48
    }
    func startTimer()  {
        if let m = SFVPNManager.shared.manager, m.isEnabled{
            if reportTimer == nil  {
                reportTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(AnalyzeTableViewController.requestReportXPC(_:)), userInfo: nil, repeats: true)
                return
            }else {
                if let t = reportTimer,  !(t.isValid) {
                    reportTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(AnalyzeTableViewController.requestReportXPC(_:)), userInfo: nil, repeats: true)
                }
            }
            
        }else {
            if reportTimer == nil  {
                reportTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(AnalyzeTableViewController.requestReport(_:)), userInfo: nil, repeats: true)
                return
            }else {
                if let t = reportTimer,  !(t.isValid) {
                    reportTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(AnalyzeTableViewController.requestReport(_:)), userInfo: nil, repeats: true)
                }
            }
            
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        startTimer()
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reportTimer?.invalidate()
    }
    @objc func  requestReport(_ timer:Timer){
       let now  =  getInterfaceTraffic()
       if now.TunSent != 0 && now.TunReceived != 0 {
            //report.lastTraffice.tx = now.TunSent -
        report.lastTraffice.tx = UInt(now.TunSent) - report.totalTraffice.tx
        report.lastTraffice.rx = UInt(now.TunReceived) - report.totalTraffice.rx
        charts.append(Double(report.lastTraffice.tx/1024))
        report.updateMax()
        report.totalTraffice.tx = UInt(now.TunSent)
        report.totalTraffice.rx = UInt(now.TunReceived)
            
        
        }
        tableView.reloadData()
    }
    @objc func requestReportXPC(_ timer:Timer)  {
        //print("000")
        //let d0 = Date()
        //mylog("---- status:")
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
                tableView.reloadData()
            }
        
    }
 
//    func flowProcess(data:Data){
//
//        let obj = try! JSON.init(data: data)
//        if obj.error == nil {
//            //alertMessageAction("message dont init",complete: nil)
//            report.netflow.mapObject(j: obj["netflow"])
//            chartsView.updateFlow(report.netflow)
//        }
//
//    }
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
                chartsView.updateFlow(report.netflow)
                chartsView.isHidden = false
            }else {
                chartsView.isHidden = true
            }
            
            
            tableView.reloadData()
            //tableView.reloadSections(, with: .automatic)
            
        }
        
    }
    deinit {
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //showStat
    //showResult
    //showRecent
    //showLog
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        
//    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    
    
        tableView.deselectRow(at: indexPath, animated: true)
        var iden:String
        var show:Bool = false
        switch indexPath.section {
        case 1:
            if indexPath.row == 0 {
                iden = "showRecent"
            }else {
                iden = "showResult"
            }
//        case 1:
//            iden = "showStat"
       case 0:
            iden = "showRouter"
            show = true
        default:
            show = true
            iden = "showLog"
        }
        show = true
        
        
        
//        if let manager = SFVPNManager.shared.manager where manager.connection.status == .Connected {
//            show = true
//        }
        self.performSegue(withIdentifier: iden,sender:indexPath)
        
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
         return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        
        case 1:
            return 2
        case 0:
            if let manager = SFVPNManager.shared.manager, manager.connection.status == .connected{
                
                if let _ = info.subscriberCellularProvider {
                    return 8
                }
                return 7
            }else {
                return 0
            }
//            if showStart(){
//            
//                return 4+4 //tra
//            }else {
//                return 0
//            }
        case 2:
            return 1
        default:
            break
        }
        return 0
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        
//        Recent Requests
//        Rule Test Results
//        Statistics
//        Logs
        var cell:UITableViewCell?
        switch indexPath.section {
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath )

            if indexPath.row == 0 {
               cell?.textLabel?.text  = "Recent Requests".localized
            }else {
                cell?.textLabel?.text = "Rule Test Results".localized
            }
            cell?.textLabel?.font = UIFont.systemFont(ofSize: 17.0)
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "StatusCell", for: indexPath ) as! StatusCell
            configCell(cell: cell,indexPath: indexPath)
           
            return cell
//        case 0:
//            let cell = tableView.dequeueReusableCell(withIdentifier: "chartCell", for: indexPath ) as! ChartsCell
//            
//
//            
//            return cell
        default:
            cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath )

            
            cell?.textLabel?.text  = "Sessions".localized
            
        }
        cell?.updateStandUI()
        
        return cell!
        // Configure the cell...
        
    }
 
    func configCell(cell:StatusCell, indexPath:IndexPath){
        //print("$$$$ \(report.lastTraffice.rx)")
        var flag = false
        if let manager = SFVPNManager.shared.manager, manager.connection.status == .connected{
            flag = true
        }else {
            //flag = showStart()
            
        }
        if !flag {
            
            return
        }
        let now = Date()
        var reportAnswers = true
        
        if now.timeIntervalSince(lastreportDate) > 5 {
            //reportAnswers = true
            lastreportDate = now
        }
       
        //
        
        let f = UIFont.init(name: "Ionicons", size: 20)!
        cell.downLabel.text = "\u{f35d}"
        cell.downLabel.font = f
        cell.upLabel.text = "\u{f366}"
        cell.upLabel.font = f
        
        cell.updateUI()
       
       
        if flag {
            
            
            func memoryUnit(_ value: Double) -> String {
                if value < 1.0 { return String(Int(value * 1000.0))    + "MB" }
                else           { return NSString(format:"%.2f", value) as String + "GB" }
            }
           
            switch indexPath.row {

            case 0:
                let memoryUsage = System.memoryUsage()
                cell.catLabel.text = "\u{f3b3}"
                cell.downInfoLabel.text = memoryUnit(memoryUsage.free) + " " + report.memoryString()
                cell.downLabel.isHidden = true
                cell.upLabel.isHidden = true
                cell.upInfoLabel.text = report.runing
                if reportAnswers {
                    Answers.logCustomEvent(withName: "Running",
                                           customAttributes: [
                                            "Memory": report.memoryUsed,
                                            "Second": Int(now.timeIntervalSince(report.sessionStartTime)),
                                            ])
                }
                return
            case 1:
               
                infoFor(cell: cell, icon:  "\u{f4af}", report: report.lastTraffice, speed: true)
            case 2:
                
               
                infoFor(cell: cell, icon:  "\u{f4b0}", report: report.maxTraffice, speed: true)
            case 3:
                
               
                infoFor(cell: cell, icon:  "\u{f37c}", report: report.totalTraffice, speed: false)
            case 4:
              
                infoFor(cell: cell, icon: "\u{f394}", report: report.directTraffice, speed: false)
            case 5:
              
                infoFor(cell: cell, icon:  "\u{f4a8}", report: report.proxyTraffice, speed: false)
            case 6:
         
            
            
                infoFor(cell: cell, icon:  "\u{f25c}", report: report.wifiTraffice, speed: false)
            case 7:
               
                infoFor(cell: cell, icon: "\u{f274}", report: report.cellTraffice, speed: false)
            default:
                break
            }
            //print("TCP Connection: \(report.connectionCount) memory:\(report.memoryUsed) ")
        }else {
            cell.textLabel?.text = "Session Not Start".localized
            cell.catLabel.isHidden = true
            cell.downLabel.isHidden = true
            cell.downInfoLabel.isHidden = true
            cell.upLabel.isHidden = true
            cell.upInfoLabel.isHidden = true
        }
        cell.downLabel.isHidden = false
        cell.upLabel.isHidden = false
    }
    
    
    
    func infoFor(cell:StatusCell,icon:String,report:SFTraffic,speed:Bool) {
        cell.upInfoLabel.text = report.toString(x: report.tx,label: "",speed: speed)
        cell.downInfoLabel.text = report.toString(x: report.rx,label: "",speed: speed)
        cell.catLabel.text = icon
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showRouter" {
            guard let vc = segue.destination as? LogFileViewController else {return}
            if let index = sender as? IndexPath {
                if index.section == 0 {
                    vc.showRouter = true
                }
            }
            
        }
    }
    

}
