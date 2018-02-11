//
//  KcpTableViewController.swift
//  Surf
//
//  Created by 孔祥波 on 16/05/2017.
//  Copyright © 2017 abigt. All rights reserved.
//

import UIKit
import SFSocket
import XRuler
import Xcon
let kcpName:[String] = ["Crypto","Key","Compress","mode","datashard","parityshard"]
class KcpTableViewController: SFTableViewController {

    var cryptoField:UITextField!
    var keyField:UITextField!
    var modeField:UITextField!
    var datashardField:UITextField!
    var parityshardField:UITextField!
    var kcpinfo:SFKCPTunConfig!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "KCPTun Settings"
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action:#selector(KcpTableViewController.saveConfig(_:)))
    }

    @objc func saveConfig(_ sender:Any){
        
        kcpinfo.crypt = self.cryptoField!.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        kcpinfo.key = self.keyField!.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        kcpinfo.mode = self.modeField!.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if let x = Int(self.datashardField!.text!.trimmingCharacters(in: .whitespacesAndNewlines)){
            kcpinfo.datashard = x
        }
        if let y = Int(self.parityshardField!.text!.trimmingCharacters(in: .whitespacesAndNewlines)){
              kcpinfo.parityshard = y
        }
        self.navigationController?.popViewController(animated: true)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MA∫RK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 6
    }

    @objc func  comp(_ sender:UISwitch){
        sender.isOn = false
        self.showAlert(alertWithTitle("Alert", message: "Compress not Support Currently"))
        return
        kcpinfo.noComp = sender.isOn
    }
     
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Advance", for: indexPath as IndexPath) as! AdvancedCell
            cell.wwdcStyle()
            
            cell.label.text = kcpName[indexPath.row]
            cell.s.isOn = kcpinfo.noComp
            cell.s.addTarget(self, action: #selector(KcpTableViewController.comp(_:)), for: .valueChanged)
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "textfield-cell", for: indexPath) as! TextFieldCell
            
            cell.cellLabel?.text = kcpName[indexPath.row]
            switch indexPath.row {
            case 0:
                cell.textField.text = kcpinfo.crypt
                self.cryptoField = cell.textField
            case 1:
                cell.textField.text = kcpinfo.key
                self.keyField = cell.textField
            case 3:
                cell.textField.text = kcpinfo.mode
                self.modeField = cell.textField
            case 4:
                
                cell.textField.text = String(kcpinfo.datashard)
                self.datashardField = cell.textField
            case 5:
                cell.textField.text = String(kcpinfo.parityshard)
                self.parityshardField = cell.textField
            default:
                break
            }
            // Configure the cell...
            cell.wwdcStyle()
            return cell
        }
        
    }
 
    public override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Crypto only support none, aes/aes-128/aes-192 support soon,Compress currently not suport"
    }
    public override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        
        return "KCPTun client base https://github.com/xtaci/kcptun; A Secure Tunnel Based On KCP with N:M Multiplexing"
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
