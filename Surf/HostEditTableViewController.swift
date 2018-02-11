//
//  HostEditTableViewController.swift
//  Surf
//
//  Created by 孔祥波 on 16/5/14.
//  Copyright © 2016年 abigt. All rights reserved.
//

import UIKit
import SFSocket
import XRuler
@objc  protocol HostEditDelegate: class {
    func hostDidChange(controller: HostEditTableViewController,new:Bool)
    //func cancel(controller: HostEditTableViewController)
    
}

  class HostEditTableViewController: SFTableViewController {

    var record:DNSRecord = DNSRecord(name: "", ips: "")
    var new:Bool = false
    weak var delegate:HostEditDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()

        let edit = UIBarButtonItem.init(barButtonSystemItem: .done, target: self, action: #selector(HostEditTableViewController.doneAction(_:)))
        navigationItem.rightBarButtonItem = edit

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    @objc func doneAction(_ anyObject:AnyObject) {
        if let d = delegate {
            var indexPath = IndexPath.init(row: 0, section: 0)
            var cell = tableView.cellForRow(at: indexPath) as! TextFieldCell
            record.name = cell.textField.text!
            
            indexPath = IndexPath.init(row: 0, section: 1)
            cell = tableView.cellForRow(at: indexPath) as! TextFieldCell
            record.ips += cell.textField.text!
            
                d.hostDidChange(controller: self, new: new)
        }
        _ = navigationController?.popViewController(animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Domain Name"
        }
        return "IP address"
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let cell = tableView.dequeueReusableCell(withIdentifier: "hostCell", for: indexPath) as! TextFieldCell

        // Configure the cell...
        cell.wwdcStyle()
        if indexPath.section == 0 {
            if !record.name.isEmpty{
                 cell.textField.text = record.name
            }
            cell.textField.placeholder = "Domain Name"
            
        }else {
            if let t = record.ip(){
                cell.textField.text = t
            }
            cell.textField.placeholder = "1.2.3.4"
            
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
   
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath) as! TextFieldCell
        cell.textField.becomeFirstResponder()
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
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
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
