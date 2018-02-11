//
//  ProxyGroupViewController.swift
//  Surf
//
//  Created by 孔祥波 on 16/4/1.
//  Copyright © 2016年 abigt. All rights reserved.
//

import UIKit
import Darwin
import SFSocket
import NetworkExtension
import Alamofire
import SwiftyStoreKit
import Fabric
import Xcon
import XRuler
import IoniconsSwift
func version() ->Int{
    return 10
}
import SafariServices
import ObjectMapper
 extension String {
    public func to(index:Int) ->String{
        return String(self[..<self.index(self.startIndex, offsetBy:index)])
        
    }
//    public func to(index:String.Index) ->String{
//        return String(self[..<index])
//        
//    }
    func from(index:Int) ->String{
        return String(self[self.index(self.startIndex, offsetBy:index)...])
        
    }
//    public func from(index:String.Index) ->String{
//        return String(self[index...])
//        
//    }
     func validateIpAddr2() ->SOCKS5HostType{
        var sin = sockaddr_in()
        var sin6 = sockaddr_in6()
        
        if self.withCString({ cstring in inet_pton(AF_INET6, cstring, &sin6.sin6_addr) }) == 1 {
            // IPv6 peer.
            return .IPV6
        }
        else if self.withCString({ cstring in inet_pton(AF_INET, cstring, &sin.sin_addr) }) == 1 {
            // IPv4 peer.
            return .IPV4
        }
        
        return .DOMAIN
        
    }
}
class abigtCloud:CommonModel{
    var proxys:[SFProxy] = []
    public override func mapping(map: Map) {
        proxys <- map["proxys"]
    }
}
class ProxyGroupViewController: SFTableViewController,BarcodeScanDelegate,AddEditProxyDelegate
    //UIImagePickerControllerDelegate,UINavigationControllerDelegate
{
    
    let dnsqueue:DispatchQueue = DispatchQueue(label:"com.yarshure.dns")
    let coreFuncs = ["Aid","start"]
    let coreFuncsTitles = ["Connect"]
    var titleView:TitleView?
    var lastStartStopDate = Date()
    let funcs = ["Ping","Config On demand Rule"]//,"Manual Add Proxy","Scan QrCode Add Proxy"]
    var showServerIP = false
    
    var registedNoti:Bool = false
    var widgetProfile:Bool = false
    var d30found = false
    @IBOutlet weak var buyRecordLabel:UILabel!
    @IBOutlet var debugButton:UIButton!

    override func beginRequest(with context: NSExtensionContext) {
        
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) ->CGFloat{
        return 48
    }
    @IBAction func  showConfigEdit(_ sender:AnyObject){
        self.performSegue(withIdentifier: "showConfigEdit", sender: sender)
    }
    func testInapp(){
        let vc = UIStoryboard.init(name: "buy", bundle: nil).instantiateInitialViewController()!
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    @objc func downloadProxy(){
        let url = "https://swiftai.us/proxys.json"
        Alamofire.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil)
            .responseJSON { (JSON) in
                self.tableView.refreshControl?.endRefreshing()
                switch JSON.result{
                case .success(let resp):
                    
                    
                    
                    if  let m  = Mapper<abigtCloud>().map(JSONObject:resp) {
                        for p in m.proxys {
                            var found = false
                            for pp in ProxyGroupSettings.share.proxys {
                                //print(pp.editEnable)
                                //print("\(p.proxyName) \(pp.proxyName)")
                                if  pp.editEnable == false && p.proxyName == pp.proxyName {
                                    pp.serverAddress = p.serverAddress
                                    pp.serverPort = p.serverPort
                                    pp.serverIP = ""
                                    pp.password = p.password
                                    pp.method = p.method
                                    pp.tlsEnable = p.tlsEnable
                                    pp.editEnable = false
                                    found = true
                                }
                            }
                            if !found{
                                _ = ProxyGroupSettings.share.addProxy(p)
                            }
                            
                        }
                    }
                    do {
                        try ProxyGroupSettings.share.save()
                    }catch let e {
                        print(e.localizedDescription)
                    }
                    self.tableView.reloadData()
                  
                    
                case .failure(let x):
                    
                    self.alertMessageAction("Update A.BIG.T Cloud error,please try again".localized + " " + x.localizedDescription)
                    
                }
                
                
        }
    }
    
    func purchase(_ product:RegisteredPurchase,quantity:Int) {
        
        NetworkActivityIndicatorManager.networkOperationStarted()
        SwiftyStoreKit.purchaseProduct(appBundleId + "." + product.rawValue,quantity:quantity, atomically: false) { result in
            NetworkActivityIndicatorManager.networkOperationFinished()
            
            if case .success(let purchase) = result {
                // Deliver content from server, then:
                if purchase.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
                NetworkActivityIndicatorManager.networkOperationStarted()
                self.verifyReceipt { appresult in
                    NetworkActivityIndicatorManager.networkOperationFinished()
                    //self.showAlert(self.alertForVerifyReceipt(result))
                    switch appresult {
                    case .success(let receipt):
                        print(receipt)
                        if  let r = Mapper<SFStoreReceiptResult>().map(JSON: receipt), let re = r.receipt{
                            do {
                                try ProxyGroupSettings.share.saveReceipt(re)
                            }catch let e {
                                print("\(e.localizedDescription)")
                            }
                            for rr in re.in_app {
                                if rr.product_id == self.appBundleId + "." + product.rawValue {
                                    //buy veryfy
                                    self.downloadProxy()
                                }
                            }
                        }
                        
                    case .error(let error):
                        print(error)
                    }
                }
                
            }
            if let alert = self.alertForPurchaseResult(result) {
                self.showAlert(alert)
            }
        }
    }
    func addSafari(){
       let tap =  UITapGestureRecognizer.init(target: self, action: #selector(openSafari(_:)))
       tap.numberOfTapsRequired = 1
       tap.numberOfTouchesRequired = 2
        self.view.addGestureRecognizer(tap)
    }
    @objc func openSafari(_ sender:UITapGestureRecognizer){
        let u = "https://twitter.com"
        let sf =  SFSafariViewController.init(url:URL.init(string: u)!)
        sf.delegate = self
        self.present(sf, animated: true) { 
            
        }
    }
    func updateLeftButton(){
        var image:UIImage
        if self.isEditing {
           image =  Ionicons.checkmark.image(18, color: .white)
        }else {
           image =  UIImage(named: "1180-align-justify-toolbar")!
        }
        let item = UIBarButtonItem.init(image: image, style: .plain, target: self, action: #selector(ProxyGroupViewController.reOrderProxy(_:)))
        navigationItem.leftBarButtonItem = item
    }
    override func viewDidLoad() {//"Export to iCloud Driver","Import from iCloud Driver"
        super.viewDidLoad()
        addSafari()
        self.tableView.refreshControl = UIRefreshControl()
        self.tableView.refreshControl?.backgroundColor = UIColor.gray
        self.tableView.refreshControl?.tintColor = UIColor.white
        self.tableView.separatorInset = UIEdgeInsetsMake(0,50, 0, 0);
        self.tableView.refreshControl?.addTarget(self, action: #selector(self.downloadProxy)
            , for: UIControlEvents.valueChanged)
        //self.testInapp()
        if let p = ProxyGroupSettings.share.receipt {
            print(p)
        }
        if self.verifyReceipt(.Pro) {
            print("Run as Pro" )
        }

        //#if DEBUG
        //    #else
        //    debugButton.hidden = true
        //    #endif
        self.title = "Switch".localized
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "ProxyIndexChanged"), object: nil, queue: OperationQueue.main) { noti in
            self.tableView.reloadData()
        }
        self.updateLeftButton()
        titleView = TitleView.init(frame: CGRect.init(x: 0, y: 0, width: 240, height: 60));
        //titleView?.backgroundColor = UIColor.cyanColor()
        navigationItem.titleView = titleView
        let edit = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(ProxyGroupViewController.addProxy(_:)))
        
        
         navigationItem.rightBarButtonItem = edit
        
        self.tableView.allowsMultipleSelectionDuringEditing = false
    
        profileStatus()

    
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "applicationDidBecomeActive"), object: nil, queue: OperationQueue.main) { [weak self] (noti) in
            if let s = self {
                s.tableView.reloadData()
            }
            
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "shouldSaveConfNotification"), object: nil, queue: OperationQueue.main) { [weak self](noti) in
            if let userinfo = noti.userInfo , let url = userinfo["url"]{
                if let s = self {
                    s.updateWithURL(url: url as! NSURL)
                }
            }
        }

        
    }
    
    func updateWithURL(url:NSURL) {
        if let p = url.path, let fileName = p.components(separatedBy:"/").last{
             let urldoc = applicationDocumentsDirectory.appendingPathComponent(fileName)
             let urlgroup = groupContainerURL().appendingPathComponent(fileName)
            try! fm.copyItem(at: url as URL, to: urldoc)
            try! fm.copyItem(at:url as URL, to: urlgroup)
            SFConfigManager.manager.loadConfigs()
            ProxyGroupSettings.share.config = fileName
            try! ProxyGroupSettings.share.save()
            updateTitleView(config: fileName)
        }
        
    }
    @objc func reOrderProxy(_ sender:AnyObject){
        if ProxyGroupSettings.share.proxys.count == 0 {
            alertMessageAction("Please add Proxy".localized, complete: nil)
            
        }else {
            let edit = !self.isEditing
            self.setEditing(edit, animated: true)
            updateLeftButton()
        }
        
    }

    func updateTitleView(config:String){
        
        if let config = SFConfigManager.manager.selectConfig{
           
            self.titleView?.subLabel.text = config.description()
            self.titleView?.titleLabel.text =   config.configName
        }else {
            self.titleView?.subLabel.text = "Config not Found,Please Add"
            alertMessageAction("Config  not Found,Please Add", complete: nil)
        }
        
        
        

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        try! ProxyGroupSettings.share.loadProxyFromFile()
        let  config = ProxyGroupSettings.share.config
        updateTitleView(config: config)
       showScanXXX()
        
        if let re =  ProxyGroupSettings.share.receipt {
            for item in re.in_app {
                if item.product_id == "com.yarshure.Surf.30D"{
                    let now = Date().timeIntervalSince1970
                    let x = Double(item.original_purchase_date_ms)!/1000 + 30 * 24*3600
                    let df = DateFormatter()
                    df.dateFormat = "yyyy/MM/dd HH:mm:ss"
                    df.timeZone = NSTimeZone.system
                    if  now < x  {
                        let buy_date = Date.init(timeIntervalSince1970:TimeInterval(Int64(item.original_purchase_date_ms)!/1000))
                        self.buyRecordLabel.text = "Expire Data: \(df.string(from: buy_date))"
                        self.buyRecordLabel.isHidden = false
                        d30found = true
                        
                        break
                    }
                }
            }
        }

        if d30found == false {
            //store version
            if (Int(appBuild())! % 2) == 0 {
                var indexs:[Int] = []
                var index:Int = ProxyGroupSettings.share.proxys.count - 1
                let temp = ProxyGroupSettings.share.proxys.reversed()
                for p in  temp{
                    if p.editEnable == false {
                        indexs.append(index)
                    }
                    index -= 1
                }
                if !indexs.isEmpty{
                    //ProxyGroupSettings.share.proxys.rem
                    for idx in indexs {
                       ProxyGroupSettings.share.proxys.remove(at: idx)
                        
                    }
                    do {
                       try ProxyGroupSettings.share.save()
                    }catch let e {
                        print("delete proxy error:\(e.localizedDescription)")
                    }
                    
                }
            }

            self.buyRecordLabel.isHidden = true
        }
        
        ProxyGroupSettings.share.editing = true
        tableView.reloadData()

    }
    func profileStatus() {
        NETunnelProviderManager.loadAllFromPreferences() { [weak self ](managers, error) -> Void in
            if let managers = managers {
                if managers.count > 0 {
                    
                    if let m  = managers.first {
                        SFVPNManager.shared.manager = m
                        self!.registerStatus()
                        self!.tableView.reloadData()
                        SFVPNManager.shared.xpc()
                    }
                    NSLog("profile status #### \(managers)")
                    //self!.refresh()
                }
                
            }
            
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
    
        if indexPath.section == 0 {
            return false
        }else {
            return true
        }
        
    }
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let s = IndexPath.init(row: sourceIndexPath.row, section: sourceIndexPath.section-1)
        let d = IndexPath.init(row: destinationIndexPath.row, section: destinationIndexPath.section-1)
         //有个status section pass
        ProxyGroupSettings.share.changeIndex(s, destPath: d)
    
    }
    func showProxyGroup(_ send:AnyObject) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "proxgroup"){
            self.present(vc, animated: true) {
                
            }
        }
        
    }

    func showScan(){
        let queue = DispatchQueue.init(label: ".", qos: .background, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
        //let queue = DispatchQueue(label: "com.yarshure.socket")// DISPATCH_QUEUE_CONCURRENT)
       
        for p in ProxyGroupSettings.share.proxys {
            if p.kcptun {
                continue
            }
            queue.async(execute: { 
            
                let start = Date()
                

                // Look up the host...
                let socketfd: Int32 = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP)
                let remoteHostName = p.serverAddress
                //let port = Intp.serverPort
                
                guard let remoteHost = gethostbyname2(remoteHostName, AF_INET)else {
                    return
                }
                               
                    
                    let d = Date()
                    
 
                    
                    p.dnsValue = d.timeIntervalSince(start)
                    var remoteAddr = sockaddr_in()
                    remoteAddr.sin_family = sa_family_t(AF_INET)
                    bcopy(remoteHost.pointee.h_addr_list[0], &remoteAddr.sin_addr.s_addr, Int(remoteHost.pointee.h_length))
                    if let port = UInt16(p.serverPort) {
                         remoteAddr.sin_port = port.bigEndian
                        
                    }else {
                        _  = p.serverPort
                        print("\(p.serverPort) error")
                        close(socketfd)
                        p.tcpValue = -1
                        return
                    }
                   
                    
                    
                    // Now, do the connection...
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
                        p.tcpValue = end.timeIntervalSince(d )
                        close(socketfd)
                    }
                
                DispatchQueue.main.async(execute: { [weak  self] in
                    if let StrongSelft = self {
                        StrongSelft.tableView.reloadData()
                    }
                    //保存IP/ping value
                    try! ProxyGroupSettings.share.save()
                    
                })
               
            })
        }
    }

    func showScanXXX(){
        let queue = DispatchQueue.init(label: "test.http", qos: .background, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
        //let queue = DispatchQueue(label: "com.yarshure.socket")// DISPATCH_QUEUE_CONCURRENT)
        queue.async(execute: {
            
           
            
            
            // Look up the host...
            let socketfd: Int32 = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP)
            let remoteHostName = "127.0.0.1"
            //let port = Intp.serverPort
            
            guard let remoteHost = gethostbyname2(remoteHostName, AF_INET)else {
                return
            }
            
            
           
            
            
            
           
            var remoteAddr = sockaddr_in()
            remoteAddr.sin_family = sa_family_t(AF_INET)
            bcopy(remoteHost.pointee.h_addr_list[0], &remoteAddr.sin_addr.s_addr, Int(remoteHost.pointee.h_length))
          
            let p:UInt16 = 10081
            
            remoteAddr.sin_port = p.bigEndian
            
            // Now, do the connection...
            let rc = withUnsafePointer(to: &remoteAddr) {
                // Temporarily bind the memory at &addr to a single instance of type sockaddr.
                $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                    connect(socketfd, $0, socklen_t(MemoryLayout<sockaddr_in>.stride))
                }
            }
            
            
            if rc < 0 {
                let str = String.init(cString: strerror(errno))
                print("socket connect failed " + str )
               
            }else {
               
                close(socketfd)
            }
            
        })
   
        
        
    }
    func addAction(_ sender:UIButton) {
        self.performSegue(withIdentifier: "addProxy", sender: sender)
    }
    
    @IBAction func editAction(_ sender:UIBarButtonItem){
        let edit = self.isEditing
        if edit {
            navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .edit, target: self, action: #selector(ProxyGroupViewController.editAction(_:)))
            do {
                try ProxyGroupSettings.share.save()
                //freshProxy()
            }catch let e as NSError{
                print("\(e)")
            }

        }else {
            navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .done, target: self, action: #selector(ProxyGroupViewController.editAction(_:)))
        }
        ProxyGroupSettings.share.editing = !isEditing
        self.setEditing(!edit, animated: true)
        tableView.reloadData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if ProxyGroupSettings.share.proxyChain {
            return 3
        }
        return 2
    }
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 1 {
            var count = 0
            count =  ProxyGroupSettings.share.proxys.count
            if count == 0{
                return 1
            }else {
                return count
            }

        } else if section == 2 {
            let x = ProxyGroupSettings.share.chainProxys.count
            print("proxy chain \(x)")
            return x
        }else {
            
            return 1
        }
        
    }
    
    func hostToIP(proxy:SFProxy)  {
        dnsqueue.async(execute:{ [weak self ] in
            //update from gethostbyname to gethostbyname2 API
            guard let hostInfo = gethostbyname2((proxy.serverAddress as NSString).utf8String, AF_INET)else {
                return
            }
            
            
            
            let len = hostInfo.pointee.h_length
            let aa = hostInfo.pointee.h_addr_list[0]
            var ip = ""
            
            for i in 0 ..< len {
                let x = (aa! + Int(i)).pointee
                if i == (len - 1) {
                    ip += "\(toUint(signed: x))"
                    break
                }
                ip += "\(toUint(signed: x))."
                
            }
            proxy.serverIP = ip
            DispatchQueue.main.async(execute: {
                self!.tableView.reloadData()
            })

        })
        
        
        //return ip
    }
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
   
        if indexPath.section != 0 {
            if ProxyGroupSettings.share.proxys.count != 0  {
                self.performSegue(withIdentifier: "showProxy", sender: tableView.cellForRow(at: indexPath))
            }
        }
        
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var iden = ""
        
        if indexPath.section == 1  || indexPath.section == 2{
            iden = "proxy-group"
            
            let cell = tableView.dequeueReusableCell(withIdentifier: iden, for: indexPath) as! ProxyCell
            cell.updateUI()
            
            cell.accessoryType = .detailButton
            var count = 0
            let group = ProxyGroupSettings.share
            count = group.proxys.count
            if indexPath.row < count {
                var proxy:SFProxy

                if indexPath.section == 1 {
                    proxy = group.proxys[indexPath.row]
                    
                    if indexPath.row == ProxyGroupSettings.share.selectIndex{
                        //cell.starImageView.hidden = false
                        cell.countryLabel.text = "\u{f383}"
                    } else {
                        //cell.starImageView.hidden = true
                        //cell.countryLabel.hidden = false
                        
                        cell.countryLabel.text = ""
                    }
                }else {
                    if  indexPath.row == ProxyGroupSettings.share.proxyChainIndex{
                        //cell.starImageView.hidden = false
                        cell.countryLabel.text = "\u{f383}"
                    } else {
                        //cell.starImageView.hidden = true
                        //cell.countryLabel.hidden = false
                        
                        cell.countryLabel.text = ""
                    }
                    proxy = SFProxy.createProxyWithLine(line: "", pname: "xx")!
                    // proxy = group.chainProxys[indexPath.row]
                }
                
                    cell.enableSwitch.isHidden = true
                    //cell.countryLabel.backgroundColor = UIColor.white
                
                //}
                
                if proxy.editEnable == false {
                    cell.accessoryType = .none
                }
                cell.enableSwitch.isOn = proxy.enable
                cell.valueChanged = { (s:UISwitch) -> Void in
                    proxy.enable = s.isOn
                }
                
                let host = proxy.serverAddress
                
                let type = host.validateIpAddr2()
                if  type == .DOMAIN {
                    if proxy.serverIP.isEmpty {
                        self.hostToIP(proxy: proxy)
                    }else {
                        
                        //print(host)
                    }
                }else if type == .IPV4 {
                    proxy.serverIP = host
                    
                }
                if !proxy.serverIP.isEmpty {
                    
                    
                    if proxy.isoCode.isEmpty  {
                        let rusult  = Country.setting.geoIPRule(ipString: proxy.serverIP)
                        
                        proxy.countryFlag = rusult.emoji
                        proxy.isoCode = rusult.isoCode
                        print("\(proxy.countryFlag):\(rusult.isoCode)")
                        do {
                            try ProxyGroupSettings.share.save()
                        }catch let e as NSError {
                            print("ProxyGroupSettings save error:\(e)")
                        }
                    }
                    
                }
                
                if showServerIP {
                    var info:String = proxy.serverAddress + ":" + proxy.serverPort
                    if !proxy.isoCode.isEmpty{
                        if proxy.editEnable {
                            if group.showCountry {
                                info = proxy.serverAddress + ":" + proxy.serverPort
                            }else {
                                info = proxy.isoCode + " " + proxy.serverAddress + ":" + proxy.serverPort
                            }
                        }else {
                            info  = proxy.countryFlag  + " " + proxy.proxyName
                        }
                        
                        
                    }
                    cell.proxyLabel.text  = info
                    
                    //cell.enableSwitch.hidden = false
                    cell.enableSwitch.isOn = proxy.enable
                    if cell.valueChanged == nil {
                        cell.valueChanged = {  (s:UISwitch) -> Void in
                            //self!.proxy.proxyName = textfield.text!
                            proxy.enable = s.isOn
                            try! ProxyGroupSettings.share.save()
                        }
                        
                    }
                    
                }else {
                    if group.showCountry {
                        cell.proxyLabel.text = proxy.countryFlag  + " " + proxy.proxyName
                    }else {
                        cell.proxyLabel.text = proxy.proxyName
                    }
                    
                    
                    
                    
                }
                

                
                
                
                if proxy.tcpValue != 0 {
                    var ts = ""
                    if proxy.tcpValue > 0.0 {
                        ts =  String(format: " TCP Ping: %.0f ms", proxy.tcpValue*1000)
                        cell.subLabel.textColor = UIColor.lightGray
                    }else {
                        
                        if proxy.kcptun {
                            cell.subLabel.textColor = UIColor.lightGray
                        }else {
                            ts = " TCP Ping: Error"
                            cell.subLabel.textColor = UIColor.red
                        }
                        
                    }
                    
                    cell.subLabel.text = proxy.typeDesc() + ts
                }else {
                    cell.subLabel.text =  proxy.typeDesc()
                }
            }else {
                cell.countryLabel.text = ""
                cell.proxyLabel.text = "No Proxy Found".localized
                cell.subLabel.text = "Please Manual/QrCode Add Proxy".localized
                cell.enableSwitch.isHidden = true
                cell.starImageView.isHidden = true
            }
            if let m = SFVPNManager.shared.manager{
                if m.connection.status == .invalid {
                    //cell.enableSwitch.isOn = showStart()
                }
            }else {
                //cell.enableSwitch.isOn = showStart()
            }
            // Configure the cell...
            
            return cell
        }else if indexPath.section == 0{

            iden = "commonSwitch"//"mainFunc"
            let cell = tableView.dequeueReusableCell(withIdentifier: iden, for: indexPath) as! SampleSwitchCell
            cell.updateUI()
            
           
            
            if cell.valueChanged == nil {
                cell.valueChanged = { [unowned self] (s:UISwitch) -> Void in
                    
                    self.startStopToggled()
                }
                
            }
            
            //cell.label?.text = "Status"
            
            updateStatus(cell: cell)
            
            return cell
        }else {
            
                iden = "common"
                let cell = tableView.dequeueReusableCell(withIdentifier: iden, for: indexPath) as! SampleCell
                cell.updateUI()

                return cell
            
        }
        
    }
 
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
    
        if indexPath.section != 0{
            if ProxyGroupSettings.share.proxys.count == 0 {
                return .none
            }else {
                return .delete
            }
            
        }
        return .none
        
    }
//    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
//        if indexPath.section == 0{
//            return nil
//        }
//        return indexPath
//        
//    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 || indexPath.section == 2{

            if indexPath.section == 1 {
                if ProxyGroupSettings.share.selectIndex == indexPath.row {
                    showScan()
                    showServerIP = !showServerIP
                }else {
                    ProxyGroupSettings.share.selectIndex = indexPath.row
                    let p = ProxyGroupSettings.share.proxys[indexPath.row]
                    p.enable = true
                    try! ProxyGroupSettings.share.save()
                    if let m = SFVPNManager.shared.manager {
                        if m.connection.status == .connected {
                            
                            
                            changeProxy(index: indexPath.row)
                        }
                    }
                    
                }
            }else {
                if ProxyGroupSettings.share.proxyChainIndex == indexPath.row {
                    showScan()
                    showServerIP = !showServerIP
                }else {
                    ProxyGroupSettings.share.proxyChainIndex = indexPath.row
                    let p = ProxyGroupSettings.share.chainProxys[indexPath.row]
                    p.enable = true
                    try! ProxyGroupSettings.share.save()
      
                }
            }
            
            
            tableView.reloadData()
        
        }else {
            //utilityFunc(indexPath.row)
            //self.performSegue(withIdentifier:"showOndemand", sender: nil)
            showScan()
        }
    }
    func changeProxy(index:Int) {
        let  me = SFVPNXPSCommand.CHANGEPROXY.rawValue + "|\(index)"
        if let m = SFVPNManager.shared.manager , m.connection.status == .connected {
            if let session = m.connection as? NETunnelProviderSession,
                let message = me.data(using: .utf8)
                {
                    do {
                        try session.sendProviderMessage(message) { [weak self] response in
                            if let r = String.init(data: response!, encoding: .utf8)  , r == proxyChangedOK{
                                
                                self!.alertMessageAction(r)

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
    func coreFuncs(Index:Int){
        switch Index {
        case 1:
            //let iden = "showOndemand"
            //            self.performSegue(withIdentifier:iden, sender: tableView.cellForRowAtIndexPath(indexPath))
            showScan()
        case 0:
            if let _ = SFVPNManager.shared.manager{
                startStopToggled()
            }else {
                SFVPNManager.shared.loadManager({ [unowned self](manager, error) in
                    if let e = error {
                        self.alertMessageAction("Load Profile Error:".localized + " \(e.localizedDescription)", complete: nil)
                    }else {
                        if manager!.connection.status == .invalid {
                            print("SFVPNManager connection status  == .invalid")
                            SFNETunnelProviderManager.loadOrCreateDefaultWithCompletionHandler({ (m, e) in
                                if let e = e {
                                    print("load error:" + e.localizedDescription)
                                }
                                SFVPNManager.shared.manager = m
                                self.registerStatus()
                                self.startStopToggled()
                            })
                        }else {
                            self.registerStatus()
                            self.startStopToggled()
                        }

                    }
                    
                })
            }
        default:
            break
        }
    }
    func utilityFunc(Index:Int) {
        
        switch Index {
        case 0:
            showScan()
        case 1:
            self.performSegue(withIdentifier: "showOndemand", sender: nil)
        case 2:
            self.performSegue(withIdentifier: "addProxy", sender: nil)
        case 3:
            self.performSegue(withIdentifier: "showBarCode", sender: nil)
        case 4: break
            //scanbarCodeFromPhotoLibrary()
        default:
            break
        }
       
    }
    @objc func addProxy(_ sender:AnyObject)  {
        self.performSegue(withIdentifier: "addProxy", sender: nil)
    }
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    
        // Return false if you do not want the specified item to be editable.
        if indexPath.section == 0 {
            return false
        }
        return true
    }
 
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch section {
        case 0:
            return nil
        case 1:
            return ""//"Proxy Server".localized
        case 2:
            return "Chain Proxy".localized
        default:
            return nil
        }
    }

   
    func addProxyConfig(_ controller: AddEditProxyController, proxy:SFProxy){
        _ = ProxyGroupSettings.share.addProxy(proxy)
        try! ProxyGroupSettings.share.save()
        tableView.reloadData()
        
    }
    func editProxyConfig(_ controller: AddEditProxyController, proxy:SFProxy){
        
         ProxyGroupSettings.share.updateProxy(proxy)
        try! ProxyGroupSettings.share.save()
        tableView.reloadData()
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            // Delete the row from the data source
            
            
            if ProxyGroupSettings.share.proxys.count == 0 {
                return
            }else {
                if indexPath.section == 1{
                    ProxyGroupSettings.share.removeProxy(indexPath.row)
                    if ProxyGroupSettings.share.proxys.count != 0{
                        tableView.deleteRows(at: [indexPath], with: .fade)
                    }else {
                        tableView.reloadData()
                    }
                }else {
                    ProxyGroupSettings.share.removeProxy(indexPath.row,chain:true)
                    //FIXME: maybe crash
                    if ProxyGroupSettings.share.chainProxys.count != 0{
                        tableView.deleteRows(at: [indexPath], with: .fade)
                    }else {
                        tableView.reloadData()
                    }
                }
                
                

            }
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
 

   
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showBarCode"{
            guard let barCodeController = segue.destination as? BarcodeScanViewController  else{return}
            //barCodeController.useCamera = self.useCamera
            barCodeController.delegate = self
            //barCodeController.navigationItem.title = "Add Proxy"
            
        }else if segue.identifier == "showProxy" {
            guard let c = segue.destination as? AddEditProxyController else {return}
            guard let indexPath = self.tableView.indexPath(for: sender as! UITableViewCell) else {return }
            if indexPath.section == 1 {
                if indexPath.row < ProxyGroupSettings.share.proxys.count{
                    c.proxy = ProxyGroupSettings.share.proxys[indexPath.row]
                    
                }
                
            }else {
                //FIXME: maybe crash 
                 if indexPath.row < ProxyGroupSettings.share.chainProxys.count{
                    c.proxy = ProxyGroupSettings.share.chainProxys[indexPath.row]
               }
            }
            
            c.delegate = self
        }else if segue.identifier == "addProxy" {
            guard let c = segue.destination as? AddEditProxyController else {return}

            c.delegate = self
        }else if segue.identifier == "showConfigEdit" {
            guard let c = segue.destination as? ConfigEditViewController else {return}
            
            guard let config = SFConfigManager.manager.selectConfig else {return}
            c.url = SFConfigManager.manager.urlForConfig(config)
        }
        
    }
 

    func updateStatus(cell:SampleSwitchCell?){
        
        var status = "Disconnect".localized
        var stat = false
        if let m = SFVPNManager.shared.manager, m.isEnabled {
            mylog("status:\(m.connection.status)")
            

                switch m.connection.status{
                case .disconnected:
                   
                    status = "Disconnect".localized
                    stat = false
                    
                case .invalid:
                    
                    status  = "Please Try Again".localized
                    stat = false
                case .connected:
                 
                    status = "Connected".localized
                  
                    stat = true
                case .connecting:
                    
                    status = "Connecting".localized
                    stat = true
                case .disconnecting:
                    
                    status = "Disconnecting".localized
                    stat = false
                case .reasserting:
                    status = "Reasserting".localized
                    stat = false
                   
                    
                }
                
            
        }else {
           
//            stat = showStart()
//            if stat {
//                status = "Connected"
//            }else {
//                status = "Disconnect"
//            }
            
        }
        if let cell  = cell  {
            cell.statuslabel?.text = status
            cell.sfSwitch?.isOn = stat
        }
        
    }
    


    internal func barcodeScanDidScan(controller: BarcodeScanViewController, configString:String){
        
        if self.presentedViewController == controller {
            self.dismiss(animated: true, completion: { () -> Void in
                
            })
            
        }
        
        convertConfigString(configString: configString)
        
        
    }
    internal func barcodeScanCancelScan(controller: BarcodeScanViewController){
        if self.presentedViewController == controller {
            self.dismiss(animated: true, completion: { () -> Void in
                
            })
            
        }
        
    }
    func convertConfigString(configString: String){
        // http://base64str
        //"aes-256-cfb:fb4b532cb4180c9037c5b64bb3c09f7e@108.61.126.194:14860"
        //mayflower://xx:xx@108.61.126.194:14860
        
        if let u = NSURL.init(string: configString){
            guard let proxy:SFProxy = SFProxy.create(name: "", type: .SS, address: "", port: "", passwd: "", method: "", tls: false) else {
                return
            }
           
            guard let scheme = u.scheme else {return}
            
            
            let t = scheme.uppercased()
            if t == "HTTP" {
                proxy.type = .HTTP
            }else if t == "HTTPS" {
                proxy.type = .HTTPS
                proxy.tlsEnable = true
            }else if t == "SOCKS5" {
                proxy.type = .SOCKS5
            }else if t == "SS" {
                proxy.type = .SS
            }else {
                alertMessageAction("\(scheme) Invilad", complete: nil)
                return
            }
            let result = u.host!
            
            if let query  = u.query {
                let x = query.components(separatedBy: "&")
                for xy in x {
                    let x2 = xy.components(separatedBy: "=")
                    if x2.count == 2 {
                        if x2.first! == "remark" {
                            proxy.proxyName = x2.last!.removingPercentEncoding!
                        }
                        //print(x.first! + "### " + x.last!.removingPercentEncoding!)
                    }
                }
            }
            if let data = Data.init(base64Encoded: result , options: .ignoreUnknownCharacters) {
                if let resultString = String.init(data: data, encoding: .utf8) {
                    let items = resultString.components(separatedBy: ":")
                    if items.count == 3 {
                        proxy.method = items[0]
                        proxy.serverPort = items[2]
                        let x = items[1].components(separatedBy:"@")
                        if x.count >= 2 {
                            _ = items[1]
                            proxy.serverAddress = x.last!
                            //let end = tempString.startIndex.advancedBy()
                            _ = proxy.serverAddress.count
//                            let r = Range<String.Index>(0 ..< (tempString.characters.count - ps - 1))
//                            
//                            
//                            let pass = tempString.substring(with: r) // substringWithRange(r)
//                            proxy.password = pass
                            _ = ProxyGroupSettings.share.addProxy(proxy)
                        }else {
                            alertMessageAction("\(resultString) Invilad,Format is http://base64(hostname)", complete: nil)
                        }
                    }else {
                        alertMessageAction("\(resultString) Invilad,Format is http://base64(hostname)", complete: nil)
                    }
                }else{
                    alertMessageAction("\(configString) Invilad,Format is http://base64(hostname)", complete: nil)
                }

            }else {
                alertMessageAction("\(configString) Invilad,Format is http://base64(hostname)", complete: nil)
            }
            
            
            
        }else {
            alertMessageAction("\(configString) Invilad,Format is http://base64(hostname)", complete: nil)
        }
        
        //freshProxy()
        tableView.reloadData()
        
        
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
            //mylog("vpnmanager loading")
        }
        
    }
    //VPN mangment
    // MARK: Interface
    
    
    
    /// Register for configuration change notifications.
    @objc func registerStatus(){
        if let m = SFVPNManager.shared.manager {
            // Register to be notified of changes in the status.
            if registedNoti {
                return
            }
            NotificationCenter.default.addObserver(forName: NSNotification.Name.NEVPNStatusDidChange, object: m.connection, queue: OperationQueue.main, using: { [weak self] notification  in
                //self?.vpnStatus = self!.targetManager.connection.status
                //            self.statusLabel.text =  self.targetManager.connection.status.description
                //            self.startStopToggle.on = (self.targetManager.connection.status != .Disconnected && self.targetManager.connection.status != .Disconnecting && self.targetManager.connection.status != .Invalid)
                
                self!.tableView.reloadData()
                self!.registedNoti = true
                //mylog("\(notification)")
                })
        }else {
            self.loadManager()
        }
        
    }
    func stopObservingStatus() {
        if let m = SFVPNManager.shared.manager {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NEVPNStatusDidChange, object: m.connection)
        }
        
    }
   
    @IBAction func startStopToggled() {
        if ProxyGroupSettings.share.saveDBIng  {
            alertMessageAction(NSLocalizedString("Save Config,Please wait...",comment:""), complete: nil)
            return
        }
        do  {
            let selectConf = ProxyGroupSettings.share.config
            let now = Date()
            let exp = Int(now.timeIntervalSince(lastStartStopDate))
            if let m = SFVPNManager.shared.manager, m.connection.status == .connected {
                
                Answers.logCustomEvent(withName: "Stop",
                                       customAttributes: [
                                        "Time Interval": exp,
                                        
                    ])
            }else {
                Answers.logCustomEvent(withName: "Start",
                                       customAttributes: [
                                        
                                        "Time Interval": exp,
                    ])

            }
            lastStartStopDate = now
            let result = try SFVPNManager.shared.startStopToggled(selectConf)
            
            
            if !result {
                Timer.scheduledTimer(timeInterval: 5.0, target: self
                    , selector: #selector(ProxyGroupViewController.registerStatus), userInfo: nil, repeats: false)
                SFVPNManager.shared.loadManager({[unowned self] (manager, error) in
                    if let error = error {
                        self.alertMessageAction("\(error.localizedDescription)",complete: nil)
                    }else {
                        self.startStopToggled()
                    }
                })
            }
            
        } catch let error as NSError{
            SFVPNManager.shared.xpc()
            alertMessageAction("\(error.localizedDescription)",complete: nil)
        }
        
    }
    
}

extension ProxyGroupViewController:SFSafariViewControllerDelegate{
    func safariViewController(_ controller: SFSafariViewController, activityItemsFor URL: URL, title: String?) -> [UIActivity] {
        return []
    }
}
