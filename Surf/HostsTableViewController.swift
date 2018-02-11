//
//  HostsTableViewController.swift
//  
//
//  Created by 孔祥波 on 16/5/14.
//
//

import UIKit
import SFSocket
import XRuler
class HostsTableViewController: SFTableViewController ,HostEditDelegate{

    var config:SFConfig!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "DNS Map"
        //self.tableView.allowsSelectionDuringEditing = true
        let edit = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(HostsTableViewController.addEditHost(_:)))
        navigationItem.rightBarButtonItem = edit
        tableView.delegate = self
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    @objc func addEditHost(_ object:AnyObject){
        self.performSegue(withIdentifier:"AddEditHost", sender: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
                // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return config.hosts.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String
    {
        return "Function like /etc/hosts"
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
      
        return true
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath){
        
        if editingStyle == .delete {
            // Delete the row from the data source
            
            
            
            if indexPath.row < config.hosts.count{
                config.hosts.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath as IndexPath], with: .fade)
            }else {
                tableView.reloadData()
            }
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = tableView.dequeueReusableCell(withIdentifier: "hosts", for: indexPath as IndexPath)

        // Configure the cell...
        let x :DNSRecord = config.hosts[indexPath.row]
        cell.textLabel?.text = x.name
        if let ip = x.ip() {
            cell.detailTextLabel?.text = ip
        }
        
        return cell
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "AddEditHost"{
            guard let vc = segue.destination as? HostEditTableViewController  else{return}
            //barCodeController.useCamera = self.useCamera
            if let s = sender{
                guard let indexPath = self.tableView.indexPath(for: s as! UITableViewCell) else {return }
                vc.record = config.hosts[indexPath.row]
                vc.title = "Record"
            }else {
                vc.title = "New Record"
                vc.new = true
            }
            
            
            vc.delegate = self
            
            
            
        }

    }
 
    func hostDidChange(controller: HostEditTableViewController,new:Bool){
        if new{
            config.hosts.insert(controller.record, at: 0)
        }
        tableView.reloadData()
    }


}
