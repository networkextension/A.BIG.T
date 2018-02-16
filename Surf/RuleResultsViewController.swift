//
//  RuleResultsViewController.swift
//  Surf
//
//  Created by abigt on 16/2/14.
//  Copyright © 2016年 abigt. All rights reserved.
//

import UIKit
import NetworkExtension

import SFSocket
class RuleResultsViewController: SFTableViewController {

    var results:[SFRuleResult] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Rule Test Results"
        recent()
        //test()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        let item = UIBarButtonItem.init(image: UIImage.init(named: "760-refresh-3-toolbar"), style: .plain, target: self, action: #selector(RuleResultsViewController.refreshAction(_:)))
        self.navigationItem.rightBarButtonItem = item
    }
    func refreshAction(_ sender:AnyObject){
        recent()
    }
//    func test() {
//        let path = Bundle.main.path(forResource: "1.txt", ofType: nil)
//        if let data = try! Data.init(contentsOf: path) {
//            processData(data: data)
//        }
//    }
    func recent(){
        // Send a simple IPC message to the provider, handle the response.
        //AxLogger.log("send Hello Provider")
        if let m = SFVPNManager.shared.manager,  m.isEnabled{
            let date = NSDate()
            let  me = SFVPNXPSCommand.RULERESULT.rawValue + "|\(date)"
            if let session = m.connection as? NETunnelProviderSession,
                let message = me.data(using: .utf8), m.connection.status == .connected
            {
                do {
                    try session.sendProviderMessage(message) { [weak self] response in
                        if response != nil {
                            self!.processData(data: response!)
                        } else {
                            self!.alertMessageAction("Got a nil response from the provider",complete: nil)
                        }
                    }
                } catch {
                    alertMessageAction("Failed to Get result ",complete: nil)
                }
            }else {
                alertMessageAction("Connection not Started",complete: nil)
            }
        }else {
            
            alertMessageAction("VPN not running",complete: nil)
        }
        
    }
    func processData(data:Data)  {
        results.removeAll()
        //let responseString = NSString(data: response!, encoding: NSUTF8StringEncoding)
        let obj = JSON.init(data: data)
        if obj.error == nil {
            if obj.type == .array {
                for item in obj {
                    //{"api.smoot.apple.com":{"Name":"apple.com","Type":"DOMAIN-SUFFIX","Proxy":"jp","Policy":"Proxy"}}
                    let json = item.1
                    
                    for (k,v) in json {
                        let rule = SFRuler()
                        rule.mapObject(v)
                        //let policy = v["Policy"].stringValue
                        
                        let result = SFRuleResult.init(request: k, r: rule)
                        results.append(result)
                    }
                }
            }
            if results.count > 0 {
               tableView.reloadData()
            }else {
                alertMessageAction("Don't have Record yet!",complete: nil)
            }
            
        }
        //mylog("Received response from the provider: \(responseString)")
        //self.registerStatus()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
   
   
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return results.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
     let cell = tableView.dequeueReusableCell(withIdentifier: "rule", for: indexPath as IndexPath)
     
     // Configure the cell...
        let x = results[indexPath.row]
        cell.textLabel?.text = x.req
        var proxyName = ""
        if x.result.proxyName == "" {
            proxyName = x.result.name
        }else {
            proxyName = x.result.proxyName
        }
        let timing = String.init(format: " timing: %.04f sec", x.result.timming)
        if x.result.type == .final {
            
            cell.detailTextLabel?.text = x.result.type.description + " " + x.result.policy.description + "->" + proxyName + timing
        }else {
            cell.detailTextLabel?.text = x.result.type.description + " " + x.result.name + "->" + proxyName + timing
        }
        cell.updateUI()
        
        return cell
     }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    
        changeRule()
    }
    func changeRule() {
        var style:UIAlertControllerStyle = .alert
        let deviceIdiom = UIScreen.main.traitCollection.userInterfaceIdiom
        switch deviceIdiom {
        case .pad:
            style = .alert
        default:
            style = .actionSheet
            break
            
        }
        guard let indexPath = tableView.indexPathForSelectedRow else {return}
        
        let result = results[indexPath.row]
        let alert = UIAlertController.init(title: "Alert", message: "Please Select Policy", preferredStyle: style)
        
        let action = UIAlertAction.init(title: "PROXY", style: .default) {[unowned self ]  (action:UIAlertAction) -> Void  in
            
            result.result.proxyName = "Proxy"
            self.updateResult(rr: result)
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
        let action1 = UIAlertAction.init(title: "REJECT", style: .default) { [unowned self ] (action:UIAlertAction) -> Void in
            
            result.result.proxyName = "REJECT"
            self.updateResult(rr: result)
            self.tableView.deselectRow(at: indexPath, animated: true)
            
        }
        let action2 = UIAlertAction.init(title: "DIRECT", style: .default) { [unowned self ] (action:UIAlertAction) -> Void in
          
            result.result.proxyName = "DIRECT"
            self.updateResult(rr: result)
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
        let cancle = UIAlertAction.init(title: "Cancel", style: .cancel) { [unowned self ] (action:UIAlertAction) -> Void in
           
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
        alert.addAction(action)
        alert.addAction(action1)
        alert.addAction(action2)
        alert.addAction(cancle)
        self.present(alert, animated: true) { () -> Void in
            
        }
    }
    func updateResult(rr:SFRuleResult){
        var r:[String:AnyObject] = [:]
        r["request"] = rr.req as AnyObject?
        r["ruler"] = rr.result.resp() as AnyObject?
        
        let j = JSON(r)
        
        
        
        var data:Data
        do {
            try data = j.rawData()
        }catch let error as NSError {
            //AxLogger.log("ruleResultData error \(error.localizedDescription)")
            //let x = error.localizedDescription
            //data = error.localizedDescription.dataUsingEncoding(NSUTF8StringEncoding)!// NSData()
            alertMessageAction("error :\(error.localizedDescription)", complete: { 
                
            })
            return
        }
        
        
        
        let  me = SFVPNXPSCommand.UPDATERULE.rawValue + "|"
        var message = Data.init()
        message.append(me.data(using: .utf8)!)
        
        
        if let m = SFVPNManager.shared.manager, m.connection.status == .connected {
            if let session = m.connection as? NETunnelProviderSession
            {
                do {
                    try session.sendProviderMessage(message) { [weak self] response in
                        if let r = String.init(data: response!, encoding: String.Encoding.utf8) {
                            print("change policy : \(r)")
                            //self!.alertMessageAction(r,complete: nil)
                            
                        } else {
                            self!.alertMessageAction("Failed to Change Policy",complete: nil)
                        }
                    }
                } catch let e as NSError{
                    alertMessageAction("Failed to Change Proxy,reason \(e.description)",complete: nil)
                }
                
            }
        }
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
