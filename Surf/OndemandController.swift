//
//  OndemandController.swift
//  Surf
//
//  Created by abigt on 16/2/22.
//  Copyright © 2016年 abigt. All rights reserved.
//

import UIKit
import SFSocket
import  XRuler
let default_domains = ["twitter.com","twimg.com","t.co","google.com","ggpht.com","googleapis.com","instagram.com","cdninstgram","facebook.com","fb.com","fbcdn.net","tumblr.com","yahoo.com"
]

class OndemandController: SFTableViewController,UITextFieldDelegate {

    var wifiEnable:Bool = true
    //var onDemandEnable:Bool  = false
    var domains:[String] = []
    func wifiStatus() ->Bool{
        if let m = SFVPNManager.shared.manager {
            if let rule =  m.onDemandRules?.first{
                if rule.interfaceTypeMatch == .any {
                    wifiEnable = true
                }else {
                    wifiEnable = false
                }
                return wifiEnable
                //onDemandEnable =  m.onDemandEnabled
            }
        }
        return false
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Advance"
        
        
//        let done = UIBarButtonItem.init(title: "Done", style: .Plain, target: self, action: #selector(OndemandController.doneAction(_:)))
//        
//        self.navigationItem.rightBarButtonItem = done
    }
    @IBAction func valueChangedWIFI(_ sender:UISwitch){
        self.wifiEnable = sender.isOn
        doneAction(true)
    }
    @IBAction func valueChanged(_ sender:UISwitch){
        if let m = SFVPNManager.shared.manager {
            if let _ =  m.onDemandRules?.first{
//                if rule.interfaceTypeMatch == .Any {
//                    wifiEnable = true
//                }else {
//                    wifiEnable = false
//                }
                 m.isOnDemandEnabled = sender.isOn
            }
        }//= sender.on
        doneAction(sender.isOn)
//        SFVPNManager.shared.addOnDemandRule(domains,enable: onDemandEnable,wifiEnable:wifiEnable) {[weak self] (error) -> Void in
//            if let e = error {
//                self!.alertMessageAction("Error:\(e.description)",complete: nil)
//            }else {
//                self!.alertMessageAction("Success!",complete: nil)
//            }
//        }
    }
    func doneAction(_ enable:Bool){
        UserDefaults.standard.set(domains, forKey: onDemandKey)
        UserDefaults.standard.synchronize()
        SFVPNManager.shared.addOnDemandRule(domains,wifiEnable:wifiEnable,enable:enable) {[weak self] (error) -> Void in
            if let e = error {
                self!.alertMessageAction("\(e.localizedDescription)",complete: nil)
            }else {
//                self!.alertMessageAction("On demand Rule add Success!") {  () -> Void in
//                    if let strongSelf = self,let nvc = strongSelf.navigationController {
//                        nvc.popViewController(animated:(true)
//                    }
//                }
            }
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadDomains()
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
      
        if section == 0{
            return "MISC"
        }else if section == 1{
            return "On Demand"
        }else if section == 2{
            return "Add New domain"
        }else {
            
            return "On Demand domains "
        }
        
    }
    func loadDomains(){
        //fm.
        if let x = UserDefaults.standard.stringArray(forKey: onDemandKey) {
            for xx in x {
                var found = false
                for i in domains {
                    if xx == i {
                        found = true
                    }
                }
                if !found{
                    domains.append(xx)
                }
              
            }
            
        }else {
            if domains.isEmpty {
                domains.append(contentsOf: default_domains)
            }
            
        }
        tableView.reloadData()
    }
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
       
        // #warning Incomplete implementation, return the number of sections
        return 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return 4
        }else if section == 1 {
            return 3
        } else if section == 2 {
            return 1
        }
        return domains.count
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
       
        addDomain(domain: textField.text!)
        doneAction(true)
        textField.text = ""
        //valueChanged?(textField)
    }
    func addDomain(domain:String){
        domains.insert(domain, at: 0)
        let indexPath = IndexPath(row: 0, section: 3)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //valueChanged?(textField)
        return true
    }
    @objc func valueChangedSleep(_ send:UISwitch) {
        if let mangager = SFVPNManager.shared.manager {
            if let config = mangager.protocolConfiguration {
                config.disconnectOnSleep = send.isOn
                mangager.saveToPreferences(completionHandler: { [weak self ](error) -> Void in
                    //print(error)
                    if let e = error {
                        self!.alertMessageAction("save config error: \(e)",complete: nil)
                    }
                })
            }
        }
    }
    @objc func adBlockAction(_ sender:UISwitch){
        ProxyGroupSettings.share.historyEnable = sender.isOn
        try! ProxyGroupSettings.share.save()
    }
    @objc func widgetAction(_ sender:UISwitch){
        ProxyGroupSettings.share.disableWidget = sender.isOn
        try! ProxyGroupSettings.share.save()
    }
    @objc func widgetFlowAction(_ sender:UISwitch){
         if  let defaults = UserDefaults(suiteName:groupIdentifier) {
            defaults.set(sender.isOn, forKey: "widgetFlow")
            defaults.synchronize()
        }
        
        ProxyGroupSettings.share.widgetFlow = sender.isOn
        try! ProxyGroupSettings.share.save()
    }
    @objc func countryFlagChanged(_ sender:UISwitch){
        
        ProxyGroupSettings.share.showCountry = sender.isOn
        try! ProxyGroupSettings.share.save()

    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "switchCell") as! SwitchCell
            if indexPath.row == 0 {
                cell.label?.text = "Request History".localized
                cell.enableSwitch?.isOn = ProxyGroupSettings.share.historyEnable
                cell.enableSwitch.addTarget(self, action: #selector(OndemandController.adBlockAction(_:)), for: .valueChanged)
            } else if indexPath.row == 1 {
                cell.label?.text = "Today Widget Select".localized
                cell.enableSwitch.isHidden = true
                cell.enableSwitch?.isOn = ProxyGroupSettings.share.disableWidget
                cell.enableSwitch.addTarget(self, action: #selector(OndemandController.widgetAction(_:)), for: .valueChanged)
            }else if indexPath.row == 2 {
                cell.label?.text = "Today Widget Flow".localized
                cell.enableSwitch.isHidden = false
                cell.enableSwitch?.isOn = ProxyGroupSettings.share.widgetFlow
                cell.enableSwitch.addTarget(self, action: #selector(OndemandController.widgetFlowAction(_:)), for: .valueChanged)
            }else {
                cell.label?.text = "Show Country Flag".localized
                cell.enableSwitch.isHidden = false
                cell.enableSwitch?.isOn = ProxyGroupSettings.share.showCountry
                cell.enableSwitch.addTarget(self, action: #selector(OndemandController.countryFlagChanged(_:)), for: .valueChanged)
            }
           
            cell.wwdc()
            
            return cell
        }else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "switchCell") as! SwitchCell
            if indexPath.row == 0 {
                if let manager = SFVPNManager.shared.manager {
                    cell.enableSwitch.setOn(manager.isOnDemandEnabled, animated: false)
                    cell.enableSwitch.addTarget(self, action: #selector(OndemandController.valueChanged(_:)), for: .valueChanged)
                }
            }else if indexPath.row == 1 {
                if let _ = SFVPNManager.shared.manager {
                    let s = wifiStatus()
                    cell.enableSwitch.setOn(s, animated: false)
                    cell.enableSwitch.addTarget(self, action: #selector(OndemandController.valueChangedWIFI(_:)), for: .valueChanged)
                }
                cell.label.text = "WI-FI"
            }else {
                if let mangager = SFVPNManager.shared.manager {
                    cell.enableSwitch.setOn((mangager.protocolConfiguration?.disconnectOnSleep)!, animated: false)
                    cell.enableSwitch.addTarget(self, action: #selector(OndemandController.valueChangedSleep(_:)), for: .valueChanged)
                }
                cell.label.text = "Disconnect On Sleep".localized
            }
            
            cell.wwdc()
            return cell
        }else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "onDemandAdd") as! TextFieldCell
            cell.textField.delegate = self
            cell.wwdcStyle()
            
            let color:UIColor = UIColor.cyan
            
            let title = "Input Domain Name"
            let s = NSMutableAttributedString(string:title)
            _ = (title as NSString)
            s.addAttributes([NSAttributedStringKey.foregroundColor:color], range: NSMakeRange(0, title.count))
            cell.textField?.attributedPlaceholder =  s
//            cell.valueChanged = {[weak self] (textfield:UITextField) -> Void in
//                //self!.proxy.proxyName = textfield.text!{
//                print(textfield.text)
//                    
//            }
            
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "onDemand")
            cell!.textLabel!.text = domains[indexPath.row]
            cell?.updateStandUI()
            
            return cell!
        }
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     
        // Return false if you do not want the specified item to be editable.
        if indexPath.section == 0 {
            return false
        }
        return true
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
    
    
        if editingStyle == .delete{
            domains.remove(at: indexPath.row)
            doneAction(true)
            tableView.deleteRows(at: [indexPath as IndexPath], with: .automatic)
        }else if editingStyle == .insert {
        }
    }
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
      
        return indexPath
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath as IndexPath)
        
        switch indexPath.section{
            //        case 0:
        //            self.performSegue(withIdentifier:"showURL", sender: cell)
        case 0:
            if indexPath.row == 1 {
                self.performSegue(withIdentifier:"WidgetSegue", sender: cell)
            }
            
        default:
            
            break
        }
    }
}
