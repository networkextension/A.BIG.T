//
//  DNSViewController.swift
//  Surf
//
//  Created by abigt on 16/5/25.
//  Copyright © 2016年 abigt. All rights reserved.
//


import UIKit
import SFSocket
import XRuler
class DNSViewController: HostEditTableViewController {
    var dnsString:String = ""
    var config:SFConfig!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "DNS Server"
        let edit = UIBarButtonItem.init(barButtonSystemItem: .done, target: self, action: #selector(HostEditTableViewController.doneAction(_:)))
        navigationItem.rightBarButtonItem = edit
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    override func doneAction(_ anyObject:AnyObject) {
        // if let _ = delegate {
            let indexPath = IndexPath.init(row: 0, section: 0)
            let cell = tableView.cellForRow(at: indexPath) as! TextFieldCell
            let result  = cell.textField.text!
            if let g = config.general {
                
                g.updateDNS(result)
            }

            
            
            //d.hostDidChange(self, new: new)
        //}
        _ = navigationController?.popViewController(animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    
        return "DNS Server Setting"
    }
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
            return "You can overide the System Default DNS Server"
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
  
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let cell = tableView.dequeueReusableCell(withIdentifier: "hostCell", for: indexPath as IndexPath) as! TextFieldCell
        
        // Configure the cell...
        if indexPath.section == 0 {
            cell.wwdcStyle()
            
            cell.textField.placeholder = "Separated by Commas,"
            if let g = config.general {
                cell.textField.text = g.dnsString()
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath) as! TextFieldCell
        cell.textField.becomeFirstResponder()
    }
}
