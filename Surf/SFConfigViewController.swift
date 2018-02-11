//
//  FirstViewController.swift
//  Surf
//
//  Created by abigt on 15/11/20.
//  Copyright © 2015年 abigt. All rights reserved.
//

import UIKit
import Alamofire
import NetworkExtension
import Darwin
import SFSocket
import XRuler
/// Make NEVPNStatus convertible to a string
func toUint(signed: Int8) -> UInt8 {
    
    let unsigned = signed >= 0 ?
        UInt8(signed) :
        UInt8(signed  - Int8.min) + UInt8(Int8.max) + 1
    
    return unsigned
}
class SFConfigListViewController : SFTableViewController ,ConfigTableViewControllerDelegate,AddFileDelegate,BarcodeScanDelegate{

    //var proxyArray = [NSDictionary]()
    /// The target VPN configuration.
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.navigationController?.tabBarItem.title =  "Rules".localized
        self.title = "Rules".localized
    }
    open override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let v = view as! UITableViewHeaderFooterView
        if ProxyGroupSettings.share.wwdcStyle {
            v.contentView.backgroundColor = UIColor.init(red: 0x2d/255.0, green: 0x30/255.0, blue: 0x3b/255.0, alpha: 1.0)
        }else {
            v.contentView.backgroundColor = UIColor.groupTableViewBackground
        }
        
    }
    open override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int){
        let v = view as! UITableViewHeaderFooterView
        if ProxyGroupSettings.share.wwdcStyle {
            v.contentView.backgroundColor = UIColor.init(red: 0x2d/255.0, green: 0x30/255.0, blue: 0x3b/255.0, alpha: 1.0)
        }else {
            v.contentView.backgroundColor =  UIColor.groupTableViewBackground
        }
        
    }

    
    //weak var startStopButton:UIButton?
    //var proxyList:NSMutableArray = NSMutableArray()
    //var proxyServerList:[String:SFProxy] = [:]
    var selectPath:IndexPath?
    //var hostIP:[String:String] = [:]
    //var configFiles:[String:SFConfig] = [:] //filename,desc
    //var files:[String] = []
    
    //var selectConf:String = ""
    var importList = ["New Empty Configuration","New Configuration with Default rules","Copy from iTunes File sharing","Download From URL","Import Config use iCloud"]
    //var proVersion:Bool = false

    var proxyGroupEnable:Bool = false
    
 
    func copyiTunsShareing(config:String) ->Bool {
        
         let url = applicationDocumentsDirectory.appendingPathComponent(config)
        let urlDst = groupContainerURL().appendingPathComponent(config)
        // 需要验证格式吗？
        if fm.fileExists(atPath: urlDst.path){
            try! fm.removeItem(atPath: urlDst.path)
        }
        
        do {
            try fm.copyItem(atPath: url.path, toPath: urlDst.path)
            try fm.removeItem(atPath: url.path)
            
        }catch let error {
            mylog("copy \(error)")
            return false
        }
        return true
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) ->CGFloat{
        return 48
    }
    func copyExampleConfigAndDefault() throws {
         let path = Bundle.main.path(forResource: sampleConfig, ofType: nil)
         let url = applicationDocumentsDirectory.appendingPathComponent(sampleConfig)
       
        
         _ = Bundle.main.path(forResource: DefaultConfig, ofType: nil)
         let urlDst = groupContainerURL().appendingPathComponent(DefaultConfig)
        
        do {
            try copyFile(URL.init(fileURLWithPath: path!) , dst: urlDst , forceCopy: false)
        } catch let  error {
            //mylog("copy \(error)")
            throw error
        }
        
        do {
            try copyFile(URL.init(fileURLWithPath: path!) , dst: url, forceCopy: true)
        } catch let  error {
            //mylog("copy \(error)")
             throw error
        }
        
        
    }

//    func loadConfigSummery(fName:String){
//        let q = dispatch_queue_create("com.yarshure.config", nil)
//        dispatch_async(q){[weak self] in
//            if let StrongSelf = self{
//                let configURL = applicationDocumentsDirectory.appendingPathComponent(fName)
//                let config:SFConfig = SFConfig.init(path: configURL!.path!,loadRule:false)
//                //let count =  config.keyworldRulers.count + config.ipcidrRulers.count + config.sufixRulers.count + config.geoipRulers.count +  config.agentRuler.count + 1
//                //var flag = ""
//                if let p = config.proxys.first {
//                    
//                    //StrongSelf.proxyServerList[fName] = p
//                    //print("### \(flag) \(p.serverAddress)")
//                }
//                
//                for p in config.proxys {
//                    ProxyGroupSettings.share.addProxy(p)
//                }
//                
//
//                //StrongSelf.configFiles[fName] = config
//                dispatch_async(dispatch_get_main_queue()){ [weak self ] in
//                    if let StrongSelf = self{
//                        StrongSelf.tableView.reloadData()
//                        
//                    }
//                    
//                }
//                
//
//            }
//            
//        }
//        
//    }

    func loadConfigs() {
        //when add,edit,del need refresh
  
        
        
    }
    /// Unwind segue handler.
    @IBAction func handleUnwind(sender: UIStoryboardSegue) {
    }
   

    /// Handle the event where the view is being hidden.
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Stop watching for status change notifications.
        //removeObserver()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        //registerStatus()
        // Re-load all of the configurations.
        
    }
    func removeObserver() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NEVPNStatusDidChange, object: SFVPNManager.shared.manager?.connection)
    }
  
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //copySampleConfig()
        self.title = "Rules".localized
        
        
        //self.tableView.allowsSelectionDuringEditing = true
        self.tableView.allowsMultipleSelectionDuringEditing = false
        tableView.separatorInset=UIEdgeInsetsMake(0,50, 0, 0);
        //navigationItem.rightBarButtonItem = editButtonItem()
        tableView.delegate = self
        

        
        
        let btn = UIButton.init(type: .custom)
        btn.frame = CGRect(x:0,y: 0, width:22, height: 22)
        btn.tintColor = UIColor.blue
        btn.setImage(UIImage.init(named: "704-compose-selected")?.withRenderingMode(.alwaysTemplate), for: .highlighted)
        btn.setImage(UIImage.init(named: "704-compose-toolbar")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btn.addTarget(self, action: #selector(SFConfigListViewController.textMode(_:)), for: .touchUpInside)
        btn.tintColor = UIColor.white
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: btn)
        //        let scan = UIBarButtonItem.init(title: "Check", style: .Plain, target: self, action: #selector(ProxyGroupViewController.showScan(_:)))
        //        let ritems:[UIBarButtonItem] = [scan,done]
        

        
        
        
        //NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "testrpc", userInfo: nil, repeats: true)
        
        
        // Do any additional setup after loading the view, typically from a nib.
        
        proxyGroupEnable = UserDefaults.standard.bool(forKey: kProxyGroup)
        
        
        let edit = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(SFConfigListViewController.showAlertCC(_:)))
        navigationItem.rightBarButtonItem = edit
    }
    @objc func textMode(_ sender:AnyObject) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "editView")
        self.navigationController?.pushViewController(vc, animated: true)
        //self.performSegue(withIdentifier: "showConfigEdit", sender: sender)
    }
    @objc func showAlertCC(_ sender:AnyObject) {
        if !verifyReceipt(.Rule) {
            changeToBuyPage()
        }
        
        var style:UIAlertControllerStyle = .actionSheet
        let deviceIdiom = UIScreen.main.traitCollection.userInterfaceIdiom
        switch deviceIdiom {
        case .pad:
            style = .alert
        default:
            break
            
        }
        
        
        //let str = importList[index]
        //["New Empty Configuration","New Empty Configuration with Default rules","Copy from iTunes File sharing",]
 //       switch index {
            
//        case 0:
//            let iden = "showConfig"
//            self.performSegue(withIdentifier:iden, sender: tableView.cellForRowAtIndexPath(indexPath))
//        case 1:
//            let iden = "showConfig"
//            self.performSegue(withIdentifier:iden, sender: tableView.cellForRowAtIndexPath(indexPath))
//        case 2:
//            showiTunesFileSelector()
//        case 3:
//            activeBarCodeScan()
//        case 4:
//            showIcloudmenu()

    

        
        let alert = UIAlertController.init(title: "Select", message: nil, preferredStyle: style)
        let action = UIAlertAction.init(title: "New Empty Configuration", style: .default) { [weak self ](action:UIAlertAction) -> Void in
            let iden = "showConfig"
            self!.performSegue(withIdentifier:iden, sender: "Default")
        }
        alert.addAction(action)
        let action1 = UIAlertAction.init(title: "New Configuration with Default rules", style: .default) {[weak self] (action:UIAlertAction) -> Void in
            let iden = "showConfig"
            self!.performSegue(withIdentifier: iden, sender: nil)
        }
        alert.addAction(action1)
        
        
        let action2 = UIAlertAction.init(title: "Copy from iTunes File sharing", style: .default) { [weak self ](action:UIAlertAction) -> Void in
            
            self!.showiTunesFileSelector()
        }
        alert.addAction(action2)
        let action3 = UIAlertAction.init(title: "Download From URL", style: .default) {[weak self] (action:UIAlertAction) -> Void in
            
            self!.activeBarCodeScan()
        }
        alert.addAction(action3)
        
        
        let action4 = UIAlertAction.init(title: "Import Config use iCloud", style: .default) {[weak self] (action:UIAlertAction) -> Void in
            
            self!.showIcloudmenu()
        }
        alert.addAction(action4)
        
        let action5 = UIAlertAction.init(title: "Cancel", style: .cancel) {(action:UIAlertAction) -> Void in
            
            //self!.showIcloudmenu()
        }
        alert.addAction(action5)

        self.present(alert, animated: true) { () -> Void in
            
        }
        
    }
    @IBAction func done(_ sender:AnyObject?){
        self.dismiss(animated: true){
            
        }
        
    }
    func testrpc() {
        SFVPNManager.shared.xpc()
    }

  
  
    /// Handle the event of the view being displayed.
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    override func setEditing(editing: Bool, animated: Bool) {
//        super.setEditing(editing, animated: animated)
//        tableView.setEditing(editing, animated: animated)
//        
//        tableView.reloadData()
//        
//    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
   
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         if section == 0 {
            let count = SFConfigManager.manager.configCount
            if count > 0 {
                
                return count
            }else {
                return 1 //alert cell
            }
            
        }else{
//            if tableView.editing == true {
//                return importList.count
//            }
//            return 1;
            return importList.count
        }
        
    }

//    @IBAction func startConnect(sender: AnyObject) {
//        startStopButton = sender as? UIButton
//        startStopToggled(sender)
//    }
    @IBAction func proxyGroupAction(_ sender:UISwitch){
        self.proxyGroupEnable = sender.isOn
        UserDefaults.standard.set(sender.isOn, forKey: kProxyGroup)
        do {
            try ProxyGroupSettings.share.save()
            UserDefaults.standard.synchronize()
        }catch let e as NSError{
            alertMessageAction(e.description, complete: nil)
        }
        
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        
        switch indexPath.section{
//            case 0:
//                if indexPath.row == 0 {
//                    let itemCell = tableView.dequeueReusableCellWithIdentifier("mode-select")
//                    return itemCell!
//                }else {
//                    let itemCell = tableView.dequeueReusableCellWithIdentifier("proxy-group") as! ProxyCell
//                    itemCell.enableSwitch.on = proxyGroupEnable
//                    return itemCell
//                }
            case 0:
                //let s = proxyList.objectAtIndex(indexPath.row) as! Socks
                
                guard  let itemCell = tableView.dequeueReusableCell(withIdentifier: "proxy-group")  else{
                    let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "citem-cell")
                    cell.textLabel?.text =  "Load cell error"
                    
                    cell.updateStandUI()
                    cell.accessoryType = UITableViewCellAccessoryType.detailButton
                    
                    
                    return cell
                }
                let proxyCell = itemCell as! CountryCustomProxyCell
                proxyCell.accessoryType = UITableViewCellAccessoryType.detailButton
                let count  = SFConfigManager.manager.configCount
                proxyCell.wwdcStyle()
               
                if count > 0 {
                    let config = SFConfigManager.manager.configAtInde(indexPath.row)
                    //mylog(fp)
                    proxyCell.proxyLabel?.text = config.configName
                    
                    proxyCell.countryLabel?.text = ""
                    
                    
                    proxyCell.subLabel?.text = config.description()
                    
                    
                    
                    //todo display much info
                    //itemCell.checkMarkView.hidden = true
                    //let  selectConfig = ProxyGroupSettings.share.config
                    
                    var isSelect:Bool = false
                    if selectPath == indexPath {
                        isSelect = true
                    }else{
                        let idx = SFConfigManager.manager.selectedIndex()
                        if indexPath.row == idx{
                            selectPath = indexPath
                            isSelect = true
                        }
                    }
                    if isSelect {
                        print("isSelect")
                        proxyCell.countryLabel?.text = "\u{f383}"
                        //proxyCell.proxyLabel.textColor = UIColor.cyanColor()
                        //proxyCell.subLabel.textColor = UIColor.cyanColor()
                        //updateStatus(proxyCell)
                    }else {
                        //proxyCell.proxyLabel.textColor = UIColor.blackColor()
                        //proxyCell.subLabel.textColor = UIColor.blackColor()
                    }
                }else {
                    let alertMessage = "No Valid Configration found please add"
                    proxyCell.proxyLabel?.text = alertMessage
                    proxyCell.countryLabel?.text = ""
                    proxyCell.subLabel?.text = ""
                }
                return itemCell
 
            
            case 1:
                if  !tableView.isEditing{
                    let row = indexPath.row
                    let desc = importList[row]
                    guard let addItemCell = tableView.dequeueReusableCell(withIdentifier: "add-item") else{
                        let cell = UITableViewCell(style: .default, reuseIdentifier: "add-item")
                        cell.textLabel?.text = desc
                        cell.accessoryType = UITableViewCellAccessoryType.detailButton
                        return cell
                    }
                    let c = addItemCell as! ActionsCell
                    c.myLabel.text = desc
                    return c;

                }else {
                    guard let _ = tableView.dequeueReusableCell(withIdentifier: "start-item") else {
                        return UITableViewCell(style: .default, reuseIdentifier: "start-item")
                    }
                    
                    //self.startStopButton = startItemCell.contentView.viewWithTag(1) as? UIButton
                    //updateStatus(nil)
                    //return startItemCell
                }
            
            default:
                break
       
        }
        
        
        return UITableViewCell()
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    
        //        if self.editing {
//            return true
//        }else {
//            return false
//        }
        
        return true
    }
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            let count = SFConfigManager.manager.configCount
            if count > 0 {
                
                    let iden = "show-add-controller"
                    
                    self.performSegue(withIdentifier: iden, sender: tableView.cellForRow(at: indexPath))
                
            }
        }
        
    }
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
    
        if indexPath.section ==  0 {
            return .delete
        }else {
            return .none
        }
        

        
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
         if section == 0{
            return ""
        }else {
            if tableView.isEditing {
                return "Add Config Method"
            }
            
        }
        return nil
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
        
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        let count = SFConfigManager.manager.configCount
        if indexPath.section == 0 {
            if count > 0 {
                let last = selectPath
                selectPath = indexPath
                let config = SFConfigManager.manager.configs[indexPath.row]
                SFConfigManager.manager.selectConfig = config
                
                
                if  let _ = SFVPNManager.shared.manager {
                    //SFVPNManager.shared.enabledToggled(false)
                    //registerStatus()
                }else {
                    //self.loadManager()
                }
                self.dismiss(animated: true){
                    
                }
                if let l = last {
                    tableView.reloadRows(at: [l,indexPath], with: .none)
                }else {
                    tableView.reloadRows(at: [indexPath], with: .none)
                }
                
                

            }else {
                //configActions(indexPath)
                alertMessageAction("Please Add Config Use below Choices",complete: nil)
            }
           
        }else{
            configActions(indexPath: indexPath)            
        }
    }
    func configActions(indexPath:IndexPath) {
        let index = indexPath.row
        //let str = importList[index]
        //["New Empty Configuration","New Empty Configuration with Default rules","Copy from iTunes File sharing",]
        switch index {
        
        case 0:
            let iden = "showConfig"
            self.performSegue(withIdentifier: iden, sender: tableView.cellForRow(at: indexPath ))
        case 1:
            let iden = "showConfig"
            self.performSegue(withIdentifier: iden, sender: tableView.cellForRow(at: indexPath))
        case 2:
            showiTunesFileSelector()
        case 3:
            activeBarCodeScan()
        case 4:
            showIcloudmenu()
        default:
            break
        }
    }
    func downloadFile(urlBase64:String) ->Bool{
        
        //let utf8str = urlBase64.dataUsingEncoding(NSUTF8StringEncoding)
        var urlString:String = ""
        if urlBase64.range(of: "http") != nil {
            urlString = urlBase64
            let r = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)
            
            var fn:String
            if let url = URL.init(string: r!){
                fn = url.lastPathComponent
                if !fn.hasSuffix(".conf"){
                    fn += ".conf"
                }
            }else {
                fn = "20070109.conf"
            }
            let tempURL = applicationDocumentsDirectory.appendingPathComponent(fn)
            //alertMessageAction("fixme", complete: nil)
            Alamofire.request(r!, method: .get, parameters: nil, encoding:URLEncoding.default , headers: nil)
            //request(.GET, r, parameters: nil)
                .validate(statusCode: 200..<300)
                //.validate(contentType: ["application/txt"])
                
                .response { [weak self ]  response in
                    //print(response)
                
                    
                    if let d = response.data {
                        if fm.fileExists(atPath:tempURL.path) {
                            try! fm.removeItem(at: tempURL)
                        }
                        try! d.write(to:tempURL)
                        
                        DispatchQueue.main.async(){
                           
                            SFConfigManager.manager.loadConfigs()
                            self!.tableView.reloadData()
                        }
                    }
                    
                    
            }
        }else {
            if  let data = Data.init(base64Encoded: urlBase64, options: .ignoreUnknownCharacters) {
                if let str = String.init(data: data , encoding: String.Encoding.utf8) {
                    urlString = str
                    
                    let r = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)
                   
                    Alamofire.request(r!, method: .get, parameters: nil, encoding:URLEncoding.default , headers: nil)
                        .responseData{[weak self ]  response in
                            
                            if let _ = response.result.value {
                                
                                var fn:String
                                if let url = NSURL.init(string: r!){
                                    fn = url.lastPathComponent!
                                }else {
                                    fn = "20070109"
                                }
                                if fn.range(of:configExt) == nil {
                                    fn = fn + configExt
                                }
                                self!.writeJSONData(data: response.data!,withName:fn)
                                self!.alertMessageAction("\(String(describing: r)) Downlowd success!",complete: nil)
                            }else {
                                self!.alertMessageAction("\(String(describing: r)) Downlowd failure! reason \(response.result.error.debugDescription)",complete: nil)
                            }
                    }

                }
                
            }
        }
        
        //let resultString =
        
        //print("url \(resultString)")
        //let x = "http://192.168.2.125/jp.json"
        
        
        return true
    }
    func writeJSONData(data:Data, withName name:String){
        let dest = groupContainerURL().appendingPathComponent(name)
        try! data.write(to: dest)
        SFConfigManager.manager.loadConfigs()
        tableView.reloadData()
    }
    func activeBarCodeScan() {
        
        
        var style:UIAlertControllerStyle = .actionSheet
        let deviceIdiom = UIScreen.main.traitCollection.userInterfaceIdiom
        switch deviceIdiom {
        case .pad:
            style = .alert
        default:
            break
            
        }
        let alert = UIAlertController.init(title: "Alert", message: "Select", preferredStyle: style)
        let action = UIAlertAction.init(title: "Use QrCode", style: .default) { [weak self ](action:UIAlertAction) -> Void in
            self!.performSegue(withIdentifier: "showBarCode", sender: nil)
        }
        alert.addAction(action)
        let action1 = UIAlertAction.init(title: "Input URL", style: .default) {[weak self] (action:UIAlertAction) -> Void in
            self!.inputURL()
        }
        alert.addAction(action1)
        self.present(alert, animated: true) { () -> Void in
            
        }
        
        
    }
    func inputURL(){
        var style:UIAlertControllerStyle = .alert
        let deviceIdiom = UIScreen.main.traitCollection.userInterfaceIdiom
        switch deviceIdiom {
        case .pad:
            style = .alert
        default:
            break
            
        }
        let alert = UIAlertController.init(title: "Input URL:", message: "http(s)://domainname.com/abigt.conf", preferredStyle: style)
        
        let action = UIAlertAction.init(title: "OK", style: .default) { [weak self ](action:UIAlertAction) -> Void in
            if let field = alert.textFields?.first, !field.text!.isEmpty {
                
                   _ = self!.downloadFile(urlBase64: field.text!)
            }else {
                
            }

        }
        alert.addTextField { (textfield) -> Void in
            
        }
        alert.addAction(action)
        let action1 = UIAlertAction.init(title: "Cancel", style: .default) {(action:UIAlertAction) -> Void in
            
        }
        alert.addAction(action1)
        self.present(alert, animated: true) { () -> Void in
            
        }

    }
    func barcodeScanDidScan(controller: BarcodeScanViewController, configString:String){
        if self.presentedViewController == controller {
            self.dismiss(animated: true, completion: { () -> Void in
                
            })
            
        }
        
        if downloadFile(urlBase64: configString) == false {
            alertMessageAction("\(configString) Invilad,Base64 Decode Error", complete: nil)
        }
    }
    func barcodeScanCancelScan(controller: BarcodeScanViewController){
        if self.presentedViewController == controller {
            self.dismiss(animated: true, completion: { () -> Void in
                
            })
            
        }
    }
    func showiTunesFileSelector(){
        let iden = "showiTunesFiles"
        self.performSegue(withIdentifier: iden, sender: nil)
    }
    
 
    func removeConf(index:Int) {
        
        if let s = selectPath {
            if s.row == index{
                selectPath = nil
            }
        }
        
        SFConfigManager.manager.delConfigAtIndex(index)
      
        
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete{
            
            //saveProxys()
            
            removeConf(index: indexPath.row)
            tableView.reloadData()
        }
        else if editingStyle == .insert{
            
            self.performSegue(withIdentifier: "show-add-controller", sender: nil)
            
        }
    }
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
        if segue.identifier == "show-add-controller"{
            guard let addEditController = segue.destination as? ConfigTableViewController else{return}
            guard let indexPath = self.tableView.indexPath(for: sender as! UITableViewCell) else {return }
            addEditController.navigationItem.title = "Edit Config"
            let config = SFConfigManager.manager.configs[indexPath.row]
            addEditController.config = config
            addEditController.mode = .Edit
            addEditController.delegate = self
        }else if segue.identifier == "showConfig"{
            
            guard let addEditController = segue.destination as? ConfigTableViewController else{return}
//            guard let indexPath = self.tableView.indexPathForCell(sender as! UITableViewCell) else {return }
//            if indexPath.row == 0 {
//                addEditController.mode = .NewDefault
//            }else {
//                addEditController.mode = .NewDefaultRule
//            }
            if let _ = sender{
                addEditController.mode = .NewDefault
            }else {
                addEditController.mode = .NewDefaultRule
            }
           
            addEditController.delegate = self
            
            addEditController.navigationItem.title = "Add Config"

        }else if segue.identifier == "showiTunesFiles" {
            guard let nvc = segue.destination as? UINavigationController else {return }
            let vc = nvc.viewControllers.first as! iTunesFileTableViewController
            vc.delegate = self
        }else if segue.identifier == "showBarCode"{
            guard let barCodeController = segue.destination as? BarcodeScanViewController  else{return}
            
            barCodeController.delegate = self
            //barCodeController.navigationItem.title = "Add Proxy"
            
        }else if segue.identifier == "showOndemand" {
            guard let _ = segue.destination as? OndemandController  else{return}

        }
    
    }
    func importFileConfig(controller: iTunesFileTableViewController, config:String){
        self.dismiss(animated: true) { () -> Void in
            
        }
        if copyiTunsShareing(config: config) {
            SFConfigManager.manager.loadConfigs()
            tableView.reloadData()
            
        }
    }
    func cancelSelect(controller: iTunesFileTableViewController){
        self.dismiss(animated: true) { () -> Void in
            
        }
    }
    func saveConfig(controller: ConfigTableViewController, config:String,edit:Bool){
        if !edit {
            SFConfigManager.manager.loadConfigs()
            //loadConfigSummery(config + configExt)
            //files.append(config+configExt)
//            loadConfigSummery(config + configExt)
        }else {
            SFConfigManager.manager.loadConfigs()
            //loadConfigSummery(config + configExt)
        }
        self.tableView.reloadData()
    }
}
extension SFConfigListViewController: UIDocumentPickerDelegate{//UIDocumentMenuDelegate
    func showIcloudmenu() {
//        let importMenu = UIDocumentMenuViewController.init(documentTypes: [configExt], inMode:  .Import)
//        importMenu.delegate = self
//        self.present(importMenu, animated: true) { () -> Void in
//            
//        }
        //kUTTypeJSON
        let picker = UIDocumentPickerViewController.init(documentTypes: ["public.item","public.text"], in: .import)
        picker.delegate = self
        self.present(picker, animated: true) { () -> Void in
            
        }
    }
//    internal func documentMenu(documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController)
//    {
//        self.dismissViewControllerAnimated(true) { () -> Void in
//            
//        }
//    }
//    
//    
//    internal func documentMenuWasCancelled(documentMenu: UIDocumentMenuViewController){
//        self.dismissViewControllerAnimated(true) { () -> Void in
//            
//        }
//    }
    internal func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL){
       
//        self.dismissViewControllerAnimated(false) { () -> Void in
//        }
        let path = url.path
        if path.hasSuffix(".conf"){
            let fn = path.components(separatedBy: "/").last!
             let tempURL = applicationDocumentsDirectory.appendingPathComponent(fn) 
            do {
                try fm.copyItem(at: url, to: tempURL)
            } catch let e {
                alertMessageAction("Copy File Error:\(e.localizedDescription)", complete: nil)
            }
            
            SFConfigManager.manager.loadConfigs()
            self.tableView.reloadData()
            
        }else {
//            let fn = path.components(separatedBy: "/").last!
//            let config = SFConfig.init(path: path, loadRule: false)
//            if config.loadResult {
//                do {
//                    try copyFile(url, dst: groupContainerURL().appendingPathComponent(fn), forceCopy: true)
//                    self.loadConfigs()
//                    self.tableView.reloadData()
//                }catch let error as NSError{
//                    
//                    self.alertMessageAction(error.debugDescription,complete: nil)
//                }
//                
//                
//            }else {
//                self.alertMessageAction("Config File format Invalid",complete: nil)
//            }

        }
        
    }
    
   
    internal func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController){
//        self.dismissViewControllerAnimated(true) { () -> Void in
//            
//        }
    }

}
class CustomProxyCell: UITableViewCell{
    
    @IBOutlet weak var checkMarkView: UIImageView!
    @IBOutlet weak var myLabel:UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
       self.checkMarkView.isHidden = true
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
         super.setSelected(selected, animated: animated)
        
    }
}
class ActionsCell :UITableViewCell{
    @IBOutlet weak var myLabel:UILabel!
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    override func willTransition(to s: UITableViewCellStateMask) {
        super.willTransition(to: s)
        //self.state = s;
    }
}
class ImageActionCell: UITableViewCell {
    @IBOutlet weak var btnImageView:UIImageView!
}
class CountryCustomProxyCell: UITableViewCell{
    @IBOutlet weak var proxyLabel:UILabel!
    @IBOutlet weak var countryLabel:UILabel!
    @IBOutlet weak var subLabel:UILabel!
    
    func wwdcStyle(){
        if ProxyGroupSettings.share.wwdcStyle {
            proxyLabel.textColor = UIColor.white
            countryLabel.textColor = UIColor.white
            subLabel.textColor = UIColor.lightGray
        }else {
            proxyLabel.textColor = UIColor.darkText
            
            subLabel.textColor = UIColor.lightGray
            countryLabel.textColor = UIColor.init(red: 0x0b/255.0, green: 0x60/255.0, blue: 0xb1/255.0, alpha: 1.0)
        }
    }
}
