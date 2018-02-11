//
//  TodayViewController.swift
//  SurfToday
//
//  Created by 孔祥波 on 16/2/9.
//  Copyright © 2016年 abigt. All rights reserved.
//

import UIKit
import NotificationCenter
import NetworkExtension
import SwiftyJSON
import DarwinCore
import SFSocket
import Crashlytics
import Fabric
import Charts
import XRuler
import Xcon

class StatusConnectedCell:UITableViewCell {
    @IBOutlet weak var configLabel: UILabel!
    @IBOutlet weak var statusSwitch: UISwitch!
    @IBOutlet weak var speedContainView:UIView!
    @IBOutlet weak var downLabel: UILabel!
    @IBOutlet weak var upLabel: UILabel!
    
    @IBOutlet weak var downSpeedLabel: UILabel!
    @IBOutlet weak var upSpeedLabel: UILabel!
    
    
    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var wifiLabel: UILabel!
    
    @IBOutlet weak var cellInfoLabel: UILabel!
    @IBOutlet weak var wifiInfoLabel: UILabel!
}
class ProxyGroupCell:UITableViewCell {
    @IBOutlet weak var configLabel: UILabel!
    @IBOutlet weak var starView: UIImageView!
    
    
}
import Reachability
func version()  ->Int {
    return 10
}
class TodayViewController: SFTableViewController, NCWidgetProviding {
    
    //@IBOutlet weak var tableView: UITableView!
    var appearDate:Date = Date()
    @IBOutlet var chartsView:ChartsView!
    var config:String = ""
    var proxyConfig:String = ""
    var sysVersion = 10 //sysVersion()
    var report:SFVPNStatistics = SFVPNStatistics.shared
    var proxyGroup:ProxyGroupSettings!
    var showServerHost = false
    var lastTraffic:STTraffic = DataCounters("240.7.1.9")
    var timer:Timer?
    let dnsqueue:DispatchQueue = DispatchQueue(label: "com.abigt.dns")
    var autoRedail = false
    let reachability = Reachability()!
    var charts:[Double] = []
    override init(style: UITableViewStyle) {
        super.init(style: style)
        prepareApp()
        self.proxyGroup =  ProxyGroupSettings.share
    }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        prepareApp()
        self.proxyGroup =  ProxyGroupSettings.share
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        prepareApp()
        self.proxyGroup =  ProxyGroupSettings.share
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 66.0
        }else {
            return 44.0
        }
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let ext = self.extensionContext {
            if ext.widgetActiveDisplayMode  == .expanded {
                return displayCount()
            }else {
                let count = displayCount()
                if count >= 2 {
                    return 2
                }else {
                    return 1
                }
            }
        }

        return 1
        
    }

    func displayCount() -> Int{
        if proxyGroup.proxys.count < proxyGroup.widgetProxyCount {
            return proxyGroup.proxys.count + 1
        }else {
            return proxyGroup.widgetProxyCount + 1
        }
    }
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        if indexPath.row == 0 {
            return nil
        }else {
            return indexPath
        }
        
        //        if indexPath.row == proxyGroup.proxys.count {
        //            return nil
        //        }
        
    }
    func running() ->Bool {
        if let m = SFVPNManager.shared.manager {
            if m.connection.status == .connected {
                return true
            }
        }
        return false
    }
    func startStopToggled() {
        
        do  {
            let selectConf = ProxyGroupSettings.share.config
            let result = try SFVPNManager.shared.startStopToggled(selectConf)
            if !result {
                Timer.scheduledTimer(timeInterval: 5.0, target: self
                    , selector: #selector(TodayViewController.registerStatus), userInfo: nil, repeats: false)
//                SFVPNManager.shared.loadManager({[unowned self] (manager, error) in
//                    if let error = error {
//                        print(error.localizedDescription)
//                    }else {
//                        print("start/stop action")
//                        if self.autoRedail {
//                            self.startStopToggled()
//                            self.autoRedail = false
//                        }
//                        
//                    }
//                })

            }
            
        } catch let error{
            //SFVPNManager.shared.xpc()
            print(error.localizedDescription)
        }
        
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath , animated: true)
        let pIndex = indexPath.row - 1
        if pIndex == -1 {
            return
        }
        if proxyGroup.selectIndex == pIndex {
            showServerHost = !showServerHost
        }else {
            proxyGroup.selectIndex = pIndex
            try! proxyGroup.save()
            if running() {
//                do {
//                    try SFVPNManager.shared.startStopToggled("")
//                } catch let e {
//                    print(e.localizedDescription)
//                }
                
                autoRedail = true
                startStopToggled()
                //changeProxy(index: pIndex)
            }
        }
        
        tableView.reloadData()
        
    }
    func changeProxy(index:Int) {
        let  me = SFVPNXPSCommand.CHANGEPROXY.rawValue + "|\(index)"
        if let m = SFVPNManager.shared.manager , m.connection.status == .connected {
            if let session = m.connection as? NETunnelProviderSession,
                let message = me.data(using: .utf8)
            {
                do {
                    try session.sendProviderMessage(message) { [weak self] response in
                        guard let response = response else {return}
                        if let r = String.init(data: response, encoding: .utf8)  , r == proxyChangedOK{
                            
                            self!.alertMessageAction(r,complete: nil)
                            
                        } else {
                            self!.alertMessageAction("Failed to Change Proxy",complete: nil)
                        }
                    }
                } catch let e as NSError{
                    alertMessageAction("Failed to Change Proxy,reason \(e.description)",complete: nil)
                }
                
            }
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //
        var color = UIColor.darkText
        if ProxyGroupSettings.share.wwdcStyle {
            color = UIColor.white
        }
        
        
        //        var count = 0
        //        if proxyGroup.proxys.count < proxyGroup.widgetProxyCount {
        //            count =  proxyGroup.proxys.count
        //        }else {
        //            count =  proxyGroup.widgetProxyCount
        //        }
        if indexPath.row == 0 {
            let cell =  tableView.dequeueReusableCell(withIdentifier: "main2") as! StatusConnectedCell
            
            var flag = false
            if let m = SFVPNManager.shared.manager, m.isEnabled{
                if m.connection.status == .connected {
                    flag = true
                }
            }
            //            if sysVersion < 10 {
            //                if let _ = tunname(){
            //                    flag = true
            //                }
            //            }
            cell.statusSwitch.isOn = flag
            if flag {
                print("connected ")
                cell.downLabel.text = "\u{f35d}"
                cell.downLabel.isHidden = false
                cell.upLabel.isHidden = false
                cell.downLabel.textColor = color//UIColor.whiteColor()
                cell.upLabel.text = "\u{f366}"
                cell.upLabel.textColor = color//UIColor.whiteColor()
                let t = report.lastTraffice
                cell.downSpeedLabel.text =  t.toString(x: t.rx,label: "",speed: true)
                cell.downSpeedLabel.textColor = color// UIColor.whiteColor()
                cell.upSpeedLabel.text =  t.toString(x: t.tx,label: "",speed: true)
                cell.upSpeedLabel.textColor = color //UIColor.whiteColor()
                cell.configLabel.textColor = color
                cell.cellLabel.textColor = color
                cell.cellInfoLabel.textColor = color
                cell.wifiLabel.textColor = color
                cell.wifiInfoLabel.textColor = color
                
                cell.cellLabel.isHidden = false
                cell.cellLabel.text = "\u{f274}"
                cell.cellInfoLabel.isHidden = false
                cell.wifiLabel.isHidden = false
                cell.wifiInfoLabel.isHidden = false
                cell.wifiLabel.text = "\u{f25c}"
                let x = report.cellTraffice.rx + report.cellTraffice.tx
                let y = report.wifiTraffice.rx + report.wifiTraffice.tx
                
                cell.cellInfoLabel.text = report.cellTraffice.toString(x:x,label: "",speed: false)
                cell.wifiInfoLabel.text = report.cellTraffice.toString(x:y,label: "",speed: false)
                cell.speedContainView.isHidden = false
                
                cell.configLabel.isHidden = true
                cell.downSpeedLabel.isHidden = false
                cell.upSpeedLabel.isHidden = false
                
                
                if reachability.isReachableViaWiFi {
                    cell.cellLabel.textColor = UIColor.gray
                }
                if reachability.isReachableViaWWAN {
                    cell.wifiLabel.textColor = UIColor.gray
                }
            }else {
                print("not connected ")
                cell.configLabel.isHidden = false
                cell.speedContainView.isHidden = false
                cell.statusSwitch.isHidden = false
                cell.downLabel.isHidden = true
                cell.upLabel.isHidden = true
                cell.downSpeedLabel.isHidden = true
                cell.upSpeedLabel.isHidden = true
                
                cell.cellLabel.isHidden = true
                cell.cellInfoLabel.isHidden = true
                cell.wifiLabel.isHidden = true
                cell.wifiInfoLabel.isHidden = true
                if ProxyGroupSettings.share.widgetProxyCount == 0 {
                    cell.configLabel.text = "Today Widget Disable"
                    
                }else {
                    
                    let s = ProxyGroupSettings.share.config
                    
                    if !s.isEmpty {
                        
                        config = s
                        cell.configLabel.text = config //+ " Disconnect "                        //configLabel.text = config
                    }else {
                        cell.configLabel.text = "add config use A.BIG.T"
                    }
                    
                }
                cell.configLabel.textColor = color
            }
            
            
            return cell
        }else {
            
            
            let cell =  tableView.dequeueReusableCell(withIdentifier: "proxy") as! ProxyGroupCell
            let pIndex = indexPath.row - 1
            let proxy = proxyGroup.proxys[pIndex]
            
            var configString:String
            var ts = ""
            if !proxy.kcptun {
                if proxy.tcpValue != 0 {
                    
                    if proxy.tcpValue > 0.0 {
                        ts =  String(format: " %.0fms", proxy.tcpValue*1000)
                        //cell.subLabel.textColor = UIColor.cyanColor()
                        //print("111")
                    }else {
                        print("222")
                        ts = " Ping: Error"
                        //cell.subLabel.textColor = UIColor.redColor()
                    }
                }else {
                    print("333")
                }
            }else {
                ts = " kcptun"
            }
           
            
            if showServerHost {
                configString =  proxy.showString() + " " + proxy.serverAddress + ":" + proxy.serverPort + ts
            }else {
                if proxyGroup.showCountry {
                    configString =  proxy.countryFlagFunc()  + ts
                }else {
                    configString =  proxy.showString()  + ts
                }
                
            }
            cell.configLabel.textColor = color
            cell.configLabel.text = configString
            
            if proxyGroup.selectIndex == pIndex {
                cell.starView.isHidden = false
            }else {
                cell.starView.isHidden = true
            }
            return cell
        }
        
    }
    
    func showTraffice() ->Bool {
        
        if NSObject.version() >= 10 {
            
            if let m = SFVPNManager.shared.manager  {
                if m.connection.status == .connected || m.connection.status == .connecting{
                    return true
                }
            }else {
                return false
            }
            
        }else {
            if let m = SFVPNManager.shared.manager  {
                //profile
                if m.connection.status == .connected || m.connection.status == .connecting{
                    return true
                }else {
                    return false
                }
                
            }else {
                return report.show
            }
        }
        
        return false
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        Fabric.with([Crashlytics.self])
        Fabric.with([Answers.self])

        try! reachability.startNotifier()
        

        
        if #available(iOSApplicationExtension 10.0, *) {
            self.extensionContext!.widgetLargestAvailableDisplayMode = .expanded
        } else {
            updateSize()
        }
        if ProxyGroupSettings.share.widgetProxyCount == 0 {
            removeTodayProfile()
            
        }else {
         
            profileStatus()
           
        }
        
    }
    
    
    func profileStatus() {
        NETunnelProviderManager.loadAllFromPreferences() { [weak self ](managers, error) -> Void in
            if let managers = managers {
                if managers.count > 0 {
                    
                    if let m  = managers.first {
                        SFVPNManager.shared.manager = m
                        if m.connection.status == .connected {
                            //self!.statusCell!.statusSwitch.on = true
                            
                            
                        }
                        self!.registerStatus()
                    }
                    
                    
                    self!.tableView.reloadData()
                }
                
            }
            
        }
        
    }
    @IBAction func addProifile() {
        //print("on")
        if let m = SFVPNManager.shared.manager {
            if m.connection.status == .connected {
                //self.statusCell!.statusSwitch.on = true
            }
            self.registerStatus()
        }else {
            loadManager()
        }
        tableView.reloadData()
    }
    func reloadStatus(){
        //Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #, userInfo: <#T##Any?#>, repeats: <#T##Bool#>)
        if NSObject.version() >= 10 {
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(TodayViewController.trafficReport(_:)), userInfo: nil, repeats: true)

        }else {
            
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(TodayViewController.trafficReport(_:)), userInfo: nil, repeats: true)
        }
    }
    func requestReportXPC()  {
        //print("000")
        if let m = SFVPNManager.shared.manager , m.connection.status == .connected {
            //print("\(m.protocolConfiguration)")
            let date = NSDate()
            
            let  me = SFVPNXPSCommand.FLOWS.rawValue + "|\(date)"
            if let session = m.connection as? NETunnelProviderSession,
                let message = me.data(using: .utf8)
                
            {
                do {
                    try session.sendProviderMessage(message) { [weak self] response in
                        if response != nil {
                            self!.processData(data: response!)
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
    @objc func trafficReport(_ t:Timer) {
        if let m = SFVPNManager.shared.manager, m.connection.status == .connected {
            //requestReportXPC()
        }
        
        guard let last = DataCounters("240.7.1.9") else {return}
        report.cellTraffice.tx = last.wwanSent
        report.cellTraffice.rx = last.wwanReceived
        
        report.wifiTraffice.tx = last.wiFiSent
        report.wifiTraffice.rx = last.wiFiReceived
        
        
        if reachability.isReachableViaWWAN {
            report.lastTraffice.tx = last.wwanSent - lastTraffic.wwanSent
            report.lastTraffice.rx = last.wwanReceived - lastTraffic.wwanReceived
        }else {
            report.lastTraffice.tx = last.wiFiSent - lastTraffic.wiFiSent
            report.lastTraffice.rx = last.wiFiReceived - lastTraffic.wiFiReceived
        }
       
        //NSLog("%ld,%ld", last.TunSent , lastTraffic.TunSent)

        
        
        
        
        charts.append(Double(report.lastTraffice.rx))
        print(charts)
        if charts.count > 60 {
            charts.remove(at: 0)
        }
        chartsView.update(charts)

        
        lastTraffic = last
        self.report.show = last.show
        tableView.reloadData()
        
    }

   

    func updateSize(){
        proxyGroup = ProxyGroupSettings.share
        try! proxyGroup.loadProxyFromFile()
        var  count = 1
        if proxyGroup.proxys.count < proxyGroup.widgetProxyCount {
            count += proxyGroup.proxys.count
        }else {
            count += proxyGroup.widgetProxyCount
        }
        self.preferredContentSize = CGSize.init(width: 0, height: 44*CGFloat(count))
    }
    @available(iOSApplicationExtension 10.0, *)
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        proxyGroup = ProxyGroupSettings.share
        try! proxyGroup.loadProxyFromFile()
        var  count = 1
        if proxyGroup.proxys.count < proxyGroup.widgetProxyCount {
            count += proxyGroup.proxys.count
        }else {
            count += proxyGroup.widgetProxyCount
        }
        NSLog("max hegith %.02f", maxSize.height)
        
        
        
        switch activeDisplayMode {
        case .expanded:
            //self.preferredContentSize = CGSize.init(width:maxSize.width,height:260)
            if proxyGroup.widgetFlow == false {
                self.preferredContentSize   = CGSize.init(width: 0, height: 44 * CGFloat(count) + 22 )
            }else {
                self.preferredContentSize   = CGSize.init(width: 0, height: 44 * CGFloat(count) + 22 + 150)
            }
            
        case .compact:
            //size = CGSize.init(width: 0, height: 44 * CGFloat(count))
            self.preferredContentSize = maxSize  //CGSize.init(width:  maxSize.width, height: 88.0)
            
        }

        self.tableView.reloadData()
    }
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
       
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        appearDate = Date()
        try! proxyGroup.loadProxyFromFile()
        if proxyGroup.widgetFlow  == false {
            chartsView.isHidden = true
            chartsView.frame.size.height = 0
        }else {
            chartsView.isHidden = false
            chartsView.frame.size.height = 150
        }
        if proxyGroup.proxys.count > 0 {
            //tcpScan()
        }
        reloadStatus()
        
        
        
        registerStatus()
        tableView.reloadData()
    }
    override func viewDidDisappear(_ animated: Bool) {
        
        super.viewDidDisappear(animated)
        if let t = timer {
            t.invalidate()
        }
        let now = Date()
        let ts = now.timeIntervalSince(appearDate)
        Answers.logCustomEvent(withName: "Today",
                               customAttributes: [
                                "Usage": ts,
                                
                                ])
        if let m = SFVPNManager.shared.manager {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NEVPNStatusDidChange, object: m.connection)
        }
        
    }
    
  
    func loadManager() {
        //print("loadManager")
        let vpnmanager = SFVPNManager.shared
        if !vpnmanager.loading {
            vpnmanager.loadManager() {
                [weak self] (manager, error) -> Void in
                if let _ = manager {
                    self!.tableView.reloadData()
                    self!.registerStatus()
                    vpnmanager.xpc()
                }
            }
        }else {
            print("vpnmanager loading")
        }
        
    }
    @objc func registerStatus(){
        if let m = SFVPNManager.shared.manager {
            // Register to be notified of changes in the status.
            NotificationCenter.default.addObserver(forName: NSNotification.Name.NEVPNStatusDidChange, object: m.connection, queue: OperationQueue.main, using: { [weak self] notification  in
               
                if let strong = self {
                    
                    if let o = notification.object {
                        if let c = o as? NEVPNConnection, c.status == .disconnected {
                            if strong.autoRedail {
                                strong.autoRedail = false
                                _ = try! SFVPNManager.shared.startStopToggled(ProxyGroupSettings.share.config)
                            }
                            
                        }
                    }
                    strong.tableView.reloadData()
                }
                
            })
        }else {
            
        }
        
    }
    
    func removeTodayProfile(){
        NETunnelProviderManager.loadAllFromPreferences() { (managers, error) -> Void in
            if let managers = managers {
                if managers.count > 0 {
                    
                    var temp:NETunnelProviderManager?
                    let identify = "Surfing Today"
                    for mm  in managers {
                        if mm.localizedDescription ==  identify {
                            temp = mm
                        }
                    }
                    //print(temp?.localizedDescription)
                    if let t = temp{
                        t.removeFromPreferences(completionHandler: { (error) in
                            if let e = error{
                                print(identify +  " reomve error \(e.localizedDescription)")
                            }else {
                                print(identify + "removed ")
                            }
                        })
                    }
                    
                    
                    
                    
                }
                
            }
            
        }
        
        
    }
    
    @IBAction func enable(_ sender: UISwitch) {
        if NSObject.version() >= 10 {
            
            if let m = SFVPNManager.shared.manager {
                let s = ProxyGroupSettings.share.config
                if s.isEmpty{
                    return
                }
                if m.isEnabled {
                    do {
                        _ = try SFVPNManager.shared.startStopToggled(s)
                    }catch let e as NSError {
                        print(e)
                    }
                    
                }else {
                    //27440171 today widget error
                    let url  = URL.init(string:"abigt://start" )
                    self.extensionContext!.open(url!, completionHandler: { (s) in
                        if s {
                            print("good")
                        }
                    })
                    //SFVPNManager.shared.enabledToggled(true)
                }
                
            }else {
                //statusCell!.configLabel.text  = config +  " please add profile"
                //print("manager invalid")
                loadManager()
                sender.isOn = false
            }
        }else {
            //9 只能用双profile
            if ProxyGroupSettings.share.widgetProxyCount != 0 {
                if let m = SFVPNManager.shared.manager {
                    let s = ProxyGroupSettings.share.config
                    if s.isEmpty{
                        return
                    }
                    if m.isEnabled {
                        print("profile enabled ")
                    }
                    do {
                        _ = try SFVPNManager.shared.startStopToggled(s)
                    }catch let e as NSError {
                        print(e)
                    }
                    
                }else {
                    //statusCell!.configLabel.text  = config +  " please add profile"
                    //print("manager invalid")
                    if sender.isOn {
                        loadManager()
                        sender.isOn = false
                    }else {
                        report.show = false
                        closeTun()
                        sender.isOn = false
                    }
                    
                }
                
            }else {
                
            }
            
        }
        
        // tableView.reloadData()
    }
    func closeTun(){
        let queue = DispatchQueue(label:"com.abigt.socket")//, DISPATCH_QUEUE_CONCURRENT
        
        queue.async( execute: {
            //let start = NSDate()
            
            
            // Look up the host...
            let socketfd: Int32 = socket(Int32(AF_INET), SOCK_STREAM, Int32(IPPROTO_TCP))
            let remoteHostName = "localhost"
            //let port = Intp.serverPort
            guard let remoteHost = gethostbyname2((remoteHostName as NSString).utf8String, AF_INET)else {
                return
            }
            // Copy the info into the socket address structure...
            
            var remoteAddr = sockaddr_in()
            remoteAddr.sin_family = sa_family_t(AF_INET)
            bcopy(remoteHost.pointee.h_addr_list[0], &remoteAddr.sin_addr.s_addr, Int(remoteHost.pointee.h_length))
            remoteAddr.sin_port = UInt16(3128).bigEndian
            
            // Now, do the connection...
            //https://swift.org/migration-guide/se-0107-migrate.html
            let rc = withUnsafePointer(to: &remoteAddr) {
                // Temporarily bind the memory at &addr to a single instance of type sockaddr.
                $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                    connect(socketfd, $0, socklen_t(MemoryLayout<sockaddr_in>.stride))
                }
            }
            
            
            if rc < 0 {
                
            }else {
                
            }
            
            let main = DispatchQueue.main
            main.async(execute: {
                [weak  self] in
                if let StrongSelft = self {
                    StrongSelft.tableView.reloadData()
                    //print("reload")
                }
                
            })
            
        })
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func requestReport()  {
        //print("000")
        if let m = SFVPNManager.shared.manager  {//where m.connection.status == .Connected
            //print("\(m.protocolConfiguration)")
            let date = NSDate()
            let  me = SFVPNXPSCommand.STATUS.rawValue + "|\(date)"
            if let session = m.connection as? NETunnelProviderSession,
                let message = me.data(using: String.Encoding.utf8), m.connection.status == .connected
            {
                do {
                    try session.sendProviderMessage(message) { [weak self] response in
                        if response != nil {
                            self!.processData(data: response! )
                        } else {
                            //self!.alertMessageAction("Got a nil response from the provider",complete: nil)
                        }
                    }
                } catch {
                    //alertMessageAction("Failed to Get result ",complete: nil)
                }
            }else {
                //alertMessageAction("Connection not Stated",complete: nil)
                //statusCell!.configLabel.text = config + "  " + m.connection.status.description
            }
        }else {
            //statusCell!.configLabel.text = config
            //alertMessageAction("message dont init",complete: nil)
        }
        
    }
    func processData(data:Data)  {
        //results.removeAll()
        //print("111")
        //let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
        let obj = try! JSON.init(data: data)
        if obj.error == nil {
            //alertMessageAction("message dont init",complete: nil)
            //report.map(j: obj)
            report.netflow.mapObject(j: obj["netflow"])
            chartsView.updateFlow(report.netflow)
            //statusCell!.configLabel.text = "\(report.lastTraffice.report()) mem:\(report.memoryString())"
            //tableView.reloadSections(NSIndexSet.init(index: 2), withRowAnimation: .Automatic)
        }else {
            //             if let m = SFVPNManager.shared.manager  {
            //                statusCell!.configLabel.text = config + "  " + m.connection.status.description
            //                statusCell!.statusSwitch.on = true
            //             }else {
            //                statusCell!.configLabel.text = "VPN Manager Error"
            //                statusCell!.statusSwitch.on = false
            //            }
            //
        }
        tableView.reloadData()
    }
    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets{
        return UIEdgeInsets.init(top: 5, left: 44, bottom: 0, right: 0)
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.tableView.contentSize = size
        self.tableView.reloadData()
    }
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
}

extension TodayViewController{
    func tcpScan(){
        let queue = DispatchQueue(label: "com.abigt.socket")//, DISPATCH_QUEUE_CONCURRENT)
        for p in ProxyGroupSettings.share.proxys {
            print(p.showString() + " now scan " )
            if p.kcptun {
                continue
            }
            queue.async( execute: {
                
                let start = Date()
                
                
                // Look up the host...
                let socketfd: Int32 = socket(Int32(AF_INET), SOCK_STREAM, Int32(IPPROTO_TCP))
                let remoteHostName = p.serverAddress
                //let port = Intp.serverPort
                guard let remoteHost = gethostbyname2((remoteHostName as NSString).utf8String, AF_INET)else {
                    return
                }
                let d = NSDate()
                p.dnsValue = d.timeIntervalSince(start)
                var remoteAddr = sockaddr_in()
                remoteAddr.sin_family = sa_family_t(AF_INET)
                bcopy(remoteHost.pointee.h_addr_list[0], &remoteAddr.sin_addr.s_addr, Int(remoteHost.pointee.h_length))
                remoteAddr.sin_port = UInt16(p.serverPort)!.bigEndian
                
                // Now, do the connection...
                //https://swift.org/migration-guide/se-0107-migrate.html
                let rc = withUnsafePointer(to: &remoteAddr) {
                    // Temporarily bind the memory at &addr to a single instance of type sockaddr.
                    $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                        connect(socketfd, $0, socklen_t(MemoryLayout<sockaddr_in>.stride))
                    }
                }
                
                
                if rc < 0 {
                    print("\(p.serverAddress):\(p.serverPort) socket connect failed")
                    //throw BlueSocketError(code: BlueSocket.SOCKET_ERR_CONNECT_FAILED, reason: self.lastError())
                    p.tcpValue = -1
                }else {
                    let end = Date()
                    p.tcpValue = end.timeIntervalSince(start)
                    close(socketfd)
                }
                
                
                DispatchQueue.main.async( execute: { [weak  self] in
                    if let StrongSelft = self {
                        StrongSelft.tableView.reloadData()
                        print("reload")
                    }
                })
            })
        }
    }
}
