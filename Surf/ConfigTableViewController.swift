//
//  ConfigTableViewController.swift
//  Surf
//
//  Created by abigt on 16/1/18.
//  Copyright © 2016年 abigt. All rights reserved.
//


import UIKit
import Foundation
import SFSocket
import XRuler
import Xcon
@objc  protocol ConfigTableViewControllerDelegate:class {
    func saveConfig(controller: ConfigTableViewController, config:String,edit:Bool)// file name
    
}
public enum SFConfigMode:Int, CustomStringConvertible{
    case Edit = 0
    case NewDefault = 1
    case NewDefaultRule = 2
    public var description: String {
        switch self {
        case .Edit:return "Edit"
        case .NewDefault:return "NewDefault"
        case .NewDefaultRule:return "NewDefaultRule"
        }
    }
}
struct SFAction {
    var title:String
    var action:String
    init(t:String,a:String){
        title = t
        action = a
    }
}
class ConfigTableViewController: SFTableViewController,LoglevelDelegate ,AddEditProxyDelegate,AddEditRulerDelegate{
    

    var config:SFConfig?
    var mode:SFConfigMode = .Edit
    
    var fileName:String = ""
    weak var delegate:ConfigTableViewControllerDelegate?
    var misc:[SFAction] = []//
    weak var nameField:UITextField?
//    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
//        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
//        
//    }
    
    func loadSFConfig(){
        var path:String?
        switch mode {
        case .Edit:
            if !fileName.isEmpty{
                let url = applicationDocumentsDirectory.appendingPathComponent(fileName)
                path = url.path
                
            }else {
                path = Bundle.main.path(forResource: DefaultConfig, ofType: nil)
                
            }
        case .NewDefault:
             path = Bundle.main.path(forResource: DefaultConfig, ofType: nil)
            
        case .NewDefaultRule:
            path = Bundle.main.path(forResource: sampleConfig, ofType: nil)
            
        }
        if let p = path {
            let q = DispatchQueue(label:"com.abigt.config")
            q.async ( execute: { [unowned self] in
                self.config = SFConfig.init(path: p,loadRule: true)
                DispatchQueue.main.async(execute:{
                    self.tableView.reloadData()
                })
                
            })
            
        }else {
            alertMessageAction("Error load Config", complete: nil)
        }
        
    }
    func loadMisc() {
        let x:[String:String] = ["Export To iTunes Share":"itunesShare","Export To iCloud":"icloudShare","Duplicate":"duplicate"]
        for (key,value) in x {
            let y = SFAction.init(t: key, a: value)
            misc.append(y)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.title = "Config Rules"
        loadMisc()
        if config == nil {
            loadSFConfig()
        }else {
            fileName = config!.configName + configExt
        }
        
        //let = UILabel.init()
        let back = UIBarButtonItem.init(title: "Cancel", style: .plain, target: self, action: #selector(ConfigTableViewController.backAction(_:)))
        let done = UIBarButtonItem.init(title: "Done", style: .plain, target: self, action: #selector(ConfigTableViewController.doneAction(_:)))
        self.navigationItem.leftBarButtonItem = back
        self.navigationItem.rightBarButtonItem = done
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
    }
    @objc func backAction(_ sender:AnyObject){
        var style:UIAlertControllerStyle = .alert
        let deviceIdiom = UIScreen.main.traitCollection.userInterfaceIdiom
        switch deviceIdiom {
        case .pad:
            style = .alert
        default:
            break
            
        }
        let alert = UIAlertController.init(title: "Alert", message: "Discard unsaved changed?", preferredStyle: style)
        let action = UIAlertAction.init(title: "Stay", style: .default) { (action:UIAlertAction) -> Void in
            
        }
        let action2 = UIAlertAction.init(title: "Discard", style: .default) { (action:UIAlertAction) -> Void in
            _ = self.navigationController?.popViewController(animated:true)
        }
        
        alert.addAction(action)
        alert.addAction(action2)
        
        
        self.present(alert, animated: true) { () -> Void in
            
        }

        
    }
    @objc func doneAction(_ sender:AnyObject){
        
       
        var alertMessage:String?
                //var force:Bool = false
        if let config = self.config {
            var toName:String = ""
            if let f = self.nameField { // Done maybe input not finish
                toName = f.text!
            }

            if toName.isEmpty {
                alertMessageAction("Configuration Name invalid",complete: nil)
                return
            }
            let error:SFConfigWriteError = config.writeConfig(name: toName, copy: false, force: true,shareiTunes: false)
            switch error {
            case .success:
                
                if toName == config.configName {
                    delegate?.saveConfig(controller: self, config: config.configName, edit: true)
                }else {
                    delegate?.saveConfig(controller: self, config: toName, edit: false)
                }
                _ = self.navigationController?.popViewController(animated: true)
                return
            case .exist:
                alertMessage = "\(error.description), force save?"
            case .noName:
                alertMessage = "\(error.description), please input Name"
            case .other:
                alertMessage =  "\(error.description) error"
            }
        }
        if let message = alertMessage {
           
            alertMessageAction(message, complete: nil)
        }
       
    }
//    func loadRuler(inout ruler:[SFRuler],j:JSON,type:SFRulerType) {
//        if j.error == nil{
//            //print(j)
//            if j.type == .Dictionary {
//                for (key,value) in j.dictionaryValue{
//                   let r = SFRuler()
//                    r.name = key
//                    r.type = type
//                    let p = value["Proxy"]
//                    if p.error == nil {
//                        r.proxyName = p.stringValue
//                    }
//                    ruler.append(r)
//                }
//            }
//        }else {
//            //show error
//        }
//    }
  
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
   
        var title = ""
        switch section {
        case 0:
            title = "NAME"
        case 1:
            title = "GENERAL"
//        case 2:
//            title = "PROXY"
        case 2:
            title = "RULE"
        case 3:
            title = "MISC"
        default:
            break
        }
        return title
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        if let config = self.config {
            switch section {
            case 0:
                count = 1 //name
            case 1:
                count = 1 //general
//            case 2:
//                
//                count = 1 + config.proxys.count
            case 2:
                let c =  config.keyworldRulers.count + config.ipcidrRulers.count + config.sufixRulers.count + config.geoipRulers.count +  config.agentRuler.count + 1
                if c > 0 {
                    count = 3
                }else {
                    count = 2
                }
                //rulers
            case 3:
                count = misc.count
            default:
                break
            }
        }
        
        
        return count
    }
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    
        if indexPath.section == 0 {
            return nil
        }
        return indexPath
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     
        if let config = self.config {
            switch indexPath.section {
            case 0 :
                let cell = tableView.dequeueReusableCell(withIdentifier: "name") as! TextFieldCell
                
                cell.textField.text = config.configName
                cell.wwdcStyle()
                
                self.nameField = cell.textField
                cell.valueChanged = { [weak self] (textfield:UITextField) -> Void in
                    let text = textfield.text!
                    if self!.config!.configName != text{
                        self!.config!.configName = text
                        self!.config!.changed = true
                    }
                    
                }
                cell.wwdcStyle()
                return cell
            case 1 :
                let cell = tableView.dequeueReusableCell(withIdentifier: "loglevel") as! TwoLableCell
                
                if let g = config.general {
                    cell.cellLabel.text = g.loglevel
                }
                cell.wwdcStyle()
                return cell

            case 2 :
                let c =  config.keyworldRulers.count + config.ipcidrRulers.count + config.sufixRulers.count + config.geoipRulers.count +  config.agentRuler.count + 1
                var count = 1
                
                if c > 0{
                    count = 2
                }
                
                var cell:UITableViewCell?
                if count == 2 {
                    if indexPath.row == 0{
                        cell = tableView.dequeueReusableCell(withIdentifier:"twoline")
                        cell?.textLabel!.text = "Rules"
                        
                        cell?.detailTextLabel!.text = "\(c) Rules"
                        
                        
                    }else if  indexPath.row == 1{
                        
                        cell = tableView.dequeueReusableCell(withIdentifier:"twoline")
                        cell?.textLabel!.text = "DNS Map ..."
                       
                        cell?.detailTextLabel?.text = "\(config.hosts.count) Record"
                        
                    }else {
                        
                        cell = tableView.dequeueReusableCell(withIdentifier: "twoline")
                        cell?.textLabel!.text = "DNS Server ..."
                        
                        if let g = config.general {
                             cell?.detailTextLabel?.text = "\(g.dnsserver.count) Record"
                        }else {
                            cell?.detailTextLabel?.text = ""
                        }
                       
                        
                    }
                   cell?.updateStandUI()
                    
                }else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "AddRule")
                    cell?.textLabel!.text = "Add Rule ..."
                    cell?.updateStandUI()
                    
                   
                }
                 return cell!
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier:"AddRule")
                let m = misc[indexPath.row]
                cell?.textLabel!.text = m.title
                cell?.updateStandUI()
                
                return cell!
                
            default:
                break
            }
        }
        
        let cell = UITableViewCell()
        cell.textLabel?.text = "config error"
        return cell
        
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
   
//        if indexPath.section == 2  {
//            if let c = config {
//                if indexPath.row < c.proxys.count {
//                    return true
//                }
//            }
//            
//        }
        return false
    }
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
       
//        if indexPath.section == 2  {
//            if let c = config {
//                if indexPath.row < c.proxys.count {
//                    return .Delete
//                }
//            }
//            
//        }
        return .none
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete{
            if indexPath.section == 2  {
                if let c = config {
                    if indexPath.row < c.proxys.count {
                        c.proxys.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .automatic)
                    }
                }
                
            }

        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        
        tableView.deselectRow(at: indexPath, animated: false)
        switch indexPath.section{
        case 0: break
        case 1: break
            //self.performSegue(withIdentifier:"loglevel", sender: tableView.cellForRowAtIndexPath(indexPath))
//        case 2:
//            self.performSegue(withIdentifier:"AddEditProxy", sender: tableView.cellForRowAtIndexPath(indexPath))
        case 2:
            if indexPath.row == 0{
                self.performSegue(withIdentifier: "showRules", sender: tableView.cellForRow(at: indexPath))
            }else if indexPath.row == 1{
                self.performSegue(withIdentifier: "showHosts", sender: tableView.cellForRow(at: indexPath))
            }else {
                self.performSegue(withIdentifier: "dnsServer", sender: tableView.cellForRow(at: indexPath))
            }
            
        case 3:
            let m = misc[indexPath.row]
            miscSwith(m: m)
        default:
            break
        }
        //delegate?.importFileConfig(self, config: iTunesFiles[indexPath.row])
    }
    func miscSwith(m:SFAction) {
        //["Export To iTunes Share":"itunesShare","Export To iCloud":"icloudShare","Duplicate":"duplicate"]
        let action = m.action
        //performSelector not support in Swift lang
        if action == "itunesShare" {
            itunesShare()
        }else if action == "icloudShare" {
            icloudShare()
        }else if action == "duplicate" {
            duplicate()
        }else {
            
        }
        
    }
    func itunesShare(){
        if let c = config {
            if c.writeConfig(name: c.configName, copy: false, force: true,shareiTunes: true) == .success {
                alertMessageAction("iTunes Share save Success",complete: nil)
            }else {
                alertMessageAction("iTunes Share save failed",complete: nil)
            }
        }else {
            alertMessageAction("config invale",complete: nil)
        }
        
        
    }
    
    func duplicate(){
        var style:UIAlertControllerStyle = .alert
        let deviceIdiom = UIScreen.main.traitCollection.userInterfaceIdiom
        switch deviceIdiom {
        case .pad:
            style = .alert
        default:
            break
            
        }
        let alert = UIAlertController.init(title: "Alert", message: "Please input Config Name", preferredStyle: style)
        let action = UIAlertAction.init(title: "OK", style: .default) { [weak self] (action:UIAlertAction) -> Void in
            if let field = alert.textFields?.first {
                if let configName = field.text {
                    if !configName.isEmpty {
                        if self!.config?.writeConfig(name: configName, copy: true, force: true,shareiTunes: false) == .success {
                            self!.delegate?.saveConfig(controller: self!, config: configName, edit: false)
                            _ = self!.navigationController?.popViewController(animated: true)
                        }else {
                            self!.alertMessageAction("Error",complete: nil)
                        }
                    }else {
                        self!.alertMessageAction("config Name invalid",complete: nil)
                    }
                }
            }
        }
        let actionC = UIAlertAction.init(title: "Cancel", style: .default) { (action:UIAlertAction) -> Void in
            
        }
        alert.addTextField { (textfield) -> Void in
            
        }
        alert.addAction(action)
        alert.addAction(actionC)
        self.present(alert, animated: true) { () -> Void in
            
        }
    }
  
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
        if segue.identifier == "loglevel" {
            guard let c = segue.destination as? LoglevelTableViewController else {return}
            c.delegate = self
           // c.general = config?.general
        }else if segue.identifier == "AddEditProxy"{
            guard let c = segue.destination as? AddEditProxyController else {return}
            guard let indexPath = self.tableView.indexPath(for: sender as! UITableViewCell) else {return }
            if indexPath.row < (config?.proxys.count)!{
                c.proxy = config?.proxys[indexPath.row]
            }
            c.delegate = self
        }else if segue.identifier == "showRules" {
            guard let c = segue.destination as? RulesTableViewController else {return}
            c.config = self.config
           
        }else if segue.identifier == "addRule" {
            guard let c = segue.destination as? RuleTableViewController else {return}
            c.config = self.config
            c.delegate = self
        }else if segue.identifier == "showHosts" {
            guard let c = segue.destination as? HostsTableViewController else {return}
            c.config = self.config
            //c.delegate = self
        }else if segue.identifier == "dnsServer" {
            guard let c = segue.destination as? DNSViewController else {return}
            c.config = self.config
            //c.delegate = self
        }
    }
    func addRulerConfig(controller: RuleTableViewController, rule:SFRuler){
        switch rule.type {
        case .domainkeyword:
            config!.keyworldRulers.append(rule)
        case .ipcidr:
            config!.ipcidrRulers.append(rule)
        case .domainsuffix:
            config!.sufixRulers.append(rule)
        case .geoip:
            config!.geoipRulers.append(rule)
        case .agent:
            config!.agentRuler.append(rule)
        default:
            break
        }
        tableView.reloadData()
    }
    func editRulerConfig(controller: RuleTableViewController, rule:SFRuler,newType:SFRulerType){
        tableView.reloadData()
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
            v.contentView.backgroundColor = UIColor.groupTableViewBackground
        }
        
    }
    func didSelectLogLevel(controller: LoglevelTableViewController){
        if let config = config{
            config.changed = true
            tableView.reloadData()
        }
        
    }
     func addProxyConfig(_ controller: AddEditProxyController, proxy: SFProxy) {
    
        if let config = config{
            
            config.proxys.append(proxy)
            tableView.reloadData()
        }
    }
    func editProxyConfig(_ controller: AddEditProxyController, proxy:SFProxy){
        if let config = config{
            config.changed = true
            //config.proxys.append(proxy)
            tableView.reloadData()
        }
    }

}
extension ConfigTableViewController: UIDocumentPickerDelegate{//UIDocumentMenuDelegate
    
    func icloudShare() {
        //        let importMenu = UIDocumentMenuViewController.init(documentTypes: [configExt], inMode:  .Import)
        //        importMenu.delegate = self
        //        self.present(importMenu, animated: true) { () -> Void in
        //
        //        }
        //kUTTypeJSON
        //self.alertMessageAction("Export Config need todo")
        let document = applicationDocumentsDirectory
        let dest = document.appendingPathComponent(config!.configName + configExt)
        
        if let data = config?.genData() {
            
            try! data.write(to: dest, atomically: true,encoding:String.Encoding.utf8)
            //alertMessageAction("Export Success!!")
        }else {
            alertMessageAction("Export Config Failure",complete: nil)
            return
        }

        
        let picker = UIDocumentPickerViewController.init(url: dest, in: .exportToService)
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
        print(url)
        
        self.dismiss(animated: true) { () -> Void in
            
        }
        
    }

    internal func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController){
        self.dismiss(animated: true) { () -> Void in
        }
    }
}
