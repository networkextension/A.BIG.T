//
//  RuleTableViewController.swift
//  Surf
//
//  Created by abigt on 16/2/16.
//  Copyright © 2016年 abigt. All rights reserved.
//

import UIKit
import SFSocket
import XRuler
protocol AddEditRulerDelegate:class {
    func addRulerConfig(controller: RuleTableViewController, rule:SFRuler)//
    func editRulerConfig(controller: RuleTableViewController, rule:SFRuler,newType:SFRulerType)//
}
class AdvancedCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var s: UISwitch!
    func wwdcStyle(){
        if ProxyGroupSettings.share.wwdcStyle {
            label.textColor = UIColor.white
        }else {
            label.textColor = UIColor.black
        }
    }
}
let headers:[String] = ["TYPE","VALUE","POLICY","ADVANCE"]
let footersA:[String] = ["","use http user-agent keyword","","test feature"]
let footersB:[String] = ["","Rule matches if the domain of request have suffix,For example: 'google.com' matchs 'google.com','www.google.com'\n Notes: if have two rule: itunes.apple.com,apple.com, request itunes.apple.com will match first because  full match higher priority  ","","Default remote proxy send dns requst"]
let footersC:[String] = ["","Rule matches if the domain of request contain keyword","","Default remote proxy send dns requst"]
let footersD:[String] = ["","Rule match if the IP address of request in set network","",""]
let footersE:[String] = ["","Rule test use GeoIP Country result","",""]
class RuleTableViewController: SFTableViewController,UITextFieldDelegate,PolicyDelegate,CountryDelegate {

    var config:SFConfig!
    var rule:SFRuler?
    var type:SFRulerType = .domainkeyword
    weak var segControl:UISegmentedControl?
    var needAdd:Bool = false
    weak var delegate:AddEditRulerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Rule"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .done, target: self, action: #selector(RuleTableViewController.DoneAction(_:)))
        if rule == nil {
            rule = SFRuler()
            if let p = config.proxys.first {
                //rule?.configPolicy(p.proxyName)
                rule?.name = p.proxyName
            }
            needAdd = true
        }
        type = (rule?.type)!
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    @IBAction func valueChanged2(sender: UISwitch) {
        alertMessageAction("not finish",complete: nil)
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        //valueChanged?(textField)
        self.rule?.name = textField.text!
        textField.resignFirstResponder()
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.rule?.name = textField.text!
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func DoneAction(_ sender:AnyObject) {
        
        var type:SFRulerType
        let index = self.segControl!.selectedSegmentIndex
        switch index {
        case 0://.DOMAINKEYWORD:
            type = .agent
        case 1://.IPCIDR:
            type = .domainsuffix
        case 2://.DOMAINSUFFIX:
            type = .domainkeyword
        case 3://.GEOIP:
            type = .ipcidr
        case 4://.AGENT:
            type = .geoip
        default:
            type = .final
            break
        }
        guard let rule = self.rule else{ return}
        
        if needAdd {
           
            
            rule.type = type
            var indexPath = IndexPath.init(row: 0, section: 2)
            let cell = tableView.cellForRow(at: indexPath)! as! TwoLableCell
            rule.proxyName = cell.cellLabel.text!
            
           
            indexPath = IndexPath.init(row: 0, section: 1)
            //crash
            if segControl?.selectedSegmentIndex == 4 {
                if let cell2 = tableView.cellForRow(at: indexPath){
                    rule.name = (cell2.textLabel?.text!)!

                }
            }else {
                let cell2 = tableView.cellForRow(at: indexPath)! as!  TextFieldCell
                rule.name = cell2.textField.text!
            }
            
            if rule.name.isEmpty || rule.proxyName.isEmpty {
                alertMessageAction("VALUE should not empty",complete: nil)
                return
            }
            delegate?.addRulerConfig(controller: self, rule: rule)
            _ = self.navigationController?.popViewController(animated:true)
        }else {
            rule.type = type
            var indexPath = IndexPath.init(row: 0, section: 2)
            let cell = tableView.cellForRow(at: indexPath)! as! TwoLableCell
            rule.proxyName = cell.cellLabel.text!
            
            
            indexPath = IndexPath.init(row: 0, section: 1)
            
            if segControl?.selectedSegmentIndex == 4 {
                if let cell2 = tableView.cellForRow(at: indexPath){
                    rule.name = (cell2.textLabel?.text!)!
                    
                }
            }else {
                let cell2 = tableView.cellForRow(at: indexPath)! as!  TextFieldCell
                rule.name = cell2.textField.text!
            }
            
            if rule.name.isEmpty || rule.proxyName.isEmpty {
                alertMessageAction("VALUE should not empty",complete: nil)
                return
            }
            delegate?.editRulerConfig(controller: self, rule: rule,newType:type)
            _ = self.navigationController?.popViewController(animated:true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func modeChanged(sender:UISegmentedControl){
        
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
    
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        return headers[section]
    }
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String?{
        //guard let r = rule else {return ""}
        var foot:[String]
        
        switch self.type {
        case .domainkeyword:
            foot = footersC
        case .ipcidr:
            foot = footersD
        case .domainsuffix:
            foot = footersB
        case .geoip:
            foot = footersE
        case .agent:
            foot = footersA
        default:
            foot = footersA
            break
        }
        return foot[section]
    }
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
       
        if indexPath.section == 2 {
            return indexPath
        }else if indexPath.section == 1 {
            if segControl?.selectedSegmentIndex == 4 {
                return indexPath
            }
        }
        
        return nil
    }
    @objc func valueChanged(_ sender:UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        switch index {
        case 0://.DOMAINKEYWORD:
            type =  .agent
        case 1://.IPCIDR:
            type = .domainsuffix
        case 2://.DOMAINSUFFIX:
            type = .domainkeyword
        case 3://.GEOIP:
            type = .ipcidr
        case 4://.AGENT:
            type = .geoip
        default:
            break
        }
        tableView.reloadData()
    }
    func configSegment(control:UISegmentedControl){
        if control.allTargets.count == 0 {
            guard let r = rule else {return}
            var index = 0
            switch r.type {
            case .domainkeyword:
                index = 2
            case .ipcidr:
                index = 3
            case .domainsuffix:
                index = 1
            case .geoip:
                index = 4
            case .agent:
                index = 0
            default:
                break
            }
            control.selectedSegmentIndex = index
            if control.isEnabled == false {
                control.isEnabled = true
                control.addTarget(self, action: #selector(RuleTableViewController.valueChanged(_:)), for: .valueChanged)
                self.segControl = control
            }
            tableView.reloadData()
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section{
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "segment", for: indexPath) as! SegmentCell
            configSegment(control: cell.segement)
            return cell
        case 1:
            if segControl?.selectedSegmentIndex == 4 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath)
                cell.textLabel?.text = self.rule?.name
                cell.textLabel?.textColor = UIColor.white
                return cell
            }else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "textfield-cell", for: indexPath) as! TextFieldCell
                cell.textField.text = self.rule?.name
                //            if cell.valueChanged == nil {
                //                cell.valueChanged = { [weak self] (textfield:UITextField) -> Void in
                //                    self?.rule?.name = textfield.text!
                //                }
                //            }
                cell.wwdcStyle()
                return cell
            }

        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "policy", for: indexPath) as! TwoLableCell
            if let r = rule {
//                if r.proxyName.isEmpty {
//                    cell.cellLabel.text = r.policy.description
//                }else {
//                    cell.cellLabel.text = r.proxyName
//                }
                cell.cellLabel.text = r.desc()
                
            }
            cell.wwdcStyle()
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Advance", for: indexPath) as! AdvancedCell
            cell.label.text = "Adv"
             cell.label.textColor = UIColor.white
            cell.s.isOn = false
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            return cell
        }
        
    }

//selectPolicy
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: IndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: IndexPath, toIndexPath: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      
        // Get the new view controller using segue.destination.
        if segue.identifier == "selectPolicy" {
            guard let vc = segue.destination as? PolicyViewController else { return }
            //guard let indexPath = self.tableView.indexPathForCell(sender as! UITableViewCell) else {return }
            vc.proxys = config.proxys
            vc.delegate = self
            vc.oladValue = rule?.proxyName
        }else if segue.identifier == "selectCountry" {
            guard let vc = segue.destination as? CountrySelectController else { return }
            //guard let indexPath = self.tableView.indexPathForCell(sender as! UITableViewCell) else {return }
            //vc.proxys = config.proxys
            vc.delegate = self
            //vc.oladValue = rule?.desc()
        }
        // Pass the selected object to the new view controller.
    }
    func countrySelected(controller: CountrySelectController, code:String){
        self.rule?.name = code
        tableView.reloadData()
    }
    func editPolicyConfig(controller: PolicyViewController, policy:String){
        rule?.proxyName = policy
        tableView.reloadData()
    }

}
