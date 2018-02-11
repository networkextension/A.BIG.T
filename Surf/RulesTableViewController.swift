//
//  RulesTableViewController.swift
//  Surf
//
//  Created by 孔祥波 on 16/1/26.
//  Copyright © 2016年 abigt. All rights reserved.
//

import UIKit
import SFSocket
import XRuler
class RulesTableViewController: SFTableViewController,AddEditRulerDelegate {
    var config:SFConfig?
    var selectIndex:Int = -1
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Config rules"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(RulesTableViewController.AddAction(_:)))
    }
    @objc func AddAction(_ sender:AnyObject){
        self.performSegue(withIdentifier: "AddRule", sender: sender)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        
        switch section {
        case 1: return "DOMAIN-KEYWORD"
        case 3: return "IP-CIDR"
        case 2: return "DOMAIN-SUFFIX"
        case 4: return "GEOIP"
        case 5: return "FINAL"
        case 0: return "AGENT"
        default:
            break
        }
        if section <= 5 {
            //let type = SFRulerType(rawValue: section)
            //return type?.description

        }

        return ""
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        var count = 0
    
        if let config = self.config {
            switch section{
            case 0:
                count = config.agentRuler.count
            case 1:
                count = config.keyworldRulers.count
            case 2:
                count = config.sufixRulers.count
            case 3:
                count = config.ipcidrRulers.count
            case 4:
                count = config.geoipRulers.count
            case 5:
                count = 1
            default:
                break
            }
        }
        
        if count == 0 {
            count = 1
        }

        
        return count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        var iden = "rule"
        if indexPath.section == 5 {
            iden = "ruleFinal"
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: iden)
        cell?.updateStandUI()
        
        var ruler:SFRuler?
        if let config = self.config {
            switch indexPath.section{
            case 0:
                if config.agentRuler.count <= indexPath.row  {
                    cell?.textLabel?.text = "No user-agent base rule"
                    return cell!
                }else {
                    ruler = config.agentRuler[indexPath.row]
                }
                
            case 1:
                if config.keyworldRulers.count <= indexPath.row  {
                    cell?.textLabel?.text = "No keyword base rule"
                    return cell!
                }else {
                    ruler = config.keyworldRulers[indexPath.row]
                }
                
            case 2:
                if config.sufixRulers.count <= indexPath.row  {
                    cell?.textLabel?.text = "No domain suffix base rule"
                    return cell!
                }else {
                    ruler = config.sufixRulers[indexPath.row]
                }
                
            case 3:
                if config.ipcidrRulers.count <= indexPath.row  {
                    cell?.textLabel?.text = "No ip-cidr base rule"
                    return cell!
                }else {
                    ruler = config.ipcidrRulers[indexPath.row]
                }
               
            case 4:
                if config.geoipRulers.count <= indexPath.row  {
                    cell?.textLabel?.text = "No geoip base rule"
                    return cell!
                }else {
                    ruler = config.geoipRulers[indexPath.row]
                }
                
            case 5:
                ruler = config.finalRuler
            default:
                
                break
            }
        }
        
        if let r = ruler {
            if r.name.count == 0 {
              cell?.textLabel?.text = r.proxyName
              
              if indexPath.section == 5 {
                if r.proxyName == "DIRECT" || r.proxyName == "REJECT" {
                    cell?.detailTextLabel?.text = r.proxyName
                }else {
                    cell?.detailTextLabel?.text = "PROXY"
                }
              }else {
                if r.proxyName.isEmpty {
                    cell?.detailTextLabel?.text = r.policy.description
                }else {
                    cell?.detailTextLabel?.text = r.proxyName
                }
                
              }
              
            }else {
                cell?.textLabel?.text = r.name
                if indexPath.section == 5 {
                    cell?.detailTextLabel?.text = r.proxyName
                }else {
                    if r.proxyName.isEmpty {
                        cell?.detailTextLabel?.text = r.policy.description
                    }else {
                        cell?.detailTextLabel?.text = r.proxyName
                    }
                }
                
            }
//            if config!.verifyRules(r) == false {
//                cell?.textLabel?.textColor = UIColor.redColor()
//                cell?.detailTextLabel?.text = "Don't found \(r.proxyName) in proxy setting,please fixed"
//            }
        }else {
            cell?.textLabel?.text = "rule error"
        }
        
        return cell!
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
            if indexPath.section == 5 {
            finaleRuleAction()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func finaleRuleAction() {
        var style:UIAlertControllerStyle = .alert
        let deviceIdiom = UIScreen.main.traitCollection.userInterfaceIdiom
        switch deviceIdiom {
        case .pad:
            style = .alert
        default:
            break
            
        }
        let alert = UIAlertController.init(title: "Alert", message: "Please Select", preferredStyle: style)
        let action = UIAlertAction.init(title: "PROXY", style: .default) {[unowned self ]  (action:UIAlertAction) -> Void  in
//            if let callback = complete {
//                callback()
//            }
            self.config!.finalRuler.proxyName = "PROXY"
            self.tableView.reloadSections(NSIndexSet(index:5) as IndexSet, with: .fade)
        }
        let action1 = UIAlertAction.init(title: "REJECT", style: .default) { [unowned self ] (action:UIAlertAction) -> Void in
            //            if let callback = complete {
            //                callback()
            //            }
            self.config!.finalRuler.proxyName = "REJECT"
            self.tableView.reloadSections(NSIndexSet(index:5) as IndexSet, with: .fade)
        }
        let action2 = UIAlertAction.init(title: "DIRECT", style: .default) { [unowned self ] (action:UIAlertAction) -> Void in
            //            if let callback = complete {
            //                callback()
            //            }
            self.config!.finalRuler.proxyName = "DIRECT"
            //self.config!.finalRuler.proxyName = self.config!.finalRuler.policy.description
            self.tableView.reloadSections(NSIndexSet(index:5) as IndexSet, with: .fade)
        }
        alert.addAction(action)
        alert.addAction(action1)
        alert.addAction(action2)
        self.present(alert, animated: true) { () -> Void in
            
        }
    }
    func deleteRuleAtIndexPath(indexPath:IndexPath){
        guard let config = config else {return }
        switch indexPath.section {
//            ruler = config.agentRuler[indexPath.row]
//        case 1:
//            ruler = config.keyworldRulers[indexPath.row]
//        case 2:
//            ruler = config.sufixRulers[indexPath.row]
//        case 3:
//            ruler = config.ipcidrRulers[indexPath.row]
//        case 4:
//            ruler = config.geoipRulers[indexPath.row]
        case 0:
            config.agentRuler.remove(at: indexPath.row)
        case 1:
            config.keyworldRulers.remove(at: indexPath.row)
        case 2:
            config.sufixRulers.remove(at: indexPath.row)
        case 3:
            config.ipcidrRulers.remove(at: indexPath.row)
        case 4:
            config.geoipRulers.remove(at: indexPath.row)
        default:
            break
        }
        tableView.reloadData()
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            
            //saveProxys()
            
            deleteRuleAtIndexPath(indexPath: indexPath)
            //removeConf(indexPath.row)
            //tableView.reloadData()
        }
        else if editingStyle == .insert{
            
            //self.performSegue(withIdentifier:"show-add-controller", sender: nil)
            
        }
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
   
        guard let config = config else {return false}
        switch indexPath.section {
        case 5:
            return false
        case 0:
            if config.agentRuler.count > 0 {
                return true
            }
        case 1:
            if config.keyworldRulers.count > 0 {
                return true
            }
        case 2:
            if config.sufixRulers.count > 0 {
                return true
            }
        case 3:
            if config.ipcidrRulers.count > 0 {
                return true
            }
        case 3:
            if config.geoipRulers.count > 0 {
                return true
            }
        default:
            break
        }
        return false
    }
    
    override  func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let config = self.config {
            switch indexPath.section{
            case 0:
                if config.agentRuler.count <= indexPath.row  {
                   
                    return nil
                }
                
            case 1:
                if config.keyworldRulers.count <= indexPath.row  {
                     return nil
                }
                
            case 2:
                if config.sufixRulers.count <= indexPath.row  {
                     return nil
                }
                
            case 3:
                if config.ipcidrRulers.count <= indexPath.row  {
                    return nil
                }
                
            case 4:
                if config.geoipRulers.count <= indexPath.row  {
                     return nil
                }
            
            default:
                
                break
            }
        }
        return indexPath
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
         if segue.identifier == "showRule" {
            guard let c = segue.destination as? RuleTableViewController else {return}
            guard let indexPath = self.tableView.indexPath(for: sender as! UITableViewCell) else {return }
            guard let config = self.config else {return }
            var rule:SFRuler
            switch indexPath.section{
            case 0:
                rule = config.agentRuler[indexPath.row]
            case 1:
                rule = config.keyworldRulers[indexPath.row]
            case 2:
                rule = config.sufixRulers[indexPath.row]
            case 3:
                rule = config.ipcidrRulers[indexPath.row]
            case 4:
                rule = config.geoipRulers[indexPath.row]
            default:
                rule = config.finalRuler

            }
            selectIndex = indexPath.row
            c.rule = rule
            c.config = self.config
            c.delegate = self
            
        }else if segue.identifier == "AddRule" {
            guard let c = segue.destination as? RuleTableViewController else {return}
            c.config = self.config
            c.delegate = self
            c.delegate = self
        }
    }
    func addRulerConfig(controller: RuleTableViewController, rule:SFRuler){
       self.addRule(rule: rule)
        tableView.reloadData()
    }
    func editRulerConfig(controller: RuleTableViewController, rule:SFRuler, newType:SFRulerType){
        if rule.type != newType {
            switch rule.type {
            case .domainkeyword:
                config!.keyworldRulers.remove(at: selectIndex)
            case .ipcidr:
                config!.ipcidrRulers.remove(at: selectIndex)
            case .domainsuffix:
                config!.sufixRulers.remove(at: selectIndex)
            case .geoip:
                config!.geoipRulers.remove(at: selectIndex)
            case .agent:
                config!.agentRuler.remove(at: selectIndex)
            default:
                break
            }
            selectIndex = -1
            rule.type = newType
            self.addRule(rule: rule)
        }
        tableView.reloadData()
    }
    func addRule(rule:SFRuler){
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
    }
}
