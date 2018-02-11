//
//  RecnetReqViewController.swift
//  Surf
//
//  Created by abigt on 16/2/14.
//  Copyright © 2016年 abigt. All rights reserved.
//

import UIKit
import NetworkExtension
import SwiftyJSON
import SFSocket
import XRuler
import Xcon
import XProxy
class RecenetReqViewController: SFTableViewController {
    var results:[SFRequestInfo] = []
    var resultsFin:[SFRequestInfo] = []
    var dbURL:URL?
    
    var session:String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Recent Requests"
        
        recent()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        let item = UIBarButtonItem.init(image: UIImage.init(named: "760-refresh-3-toolbar"), style: .plain, target: self, action: #selector(RecenetReqViewController.refreshAction(_:)))
       
       
        self.navigationItem.setRightBarButtonItems([item], animated: false)
        
    }
    //sharedb feature 废弃，使用session 中的share
    @objc func refreshAction(_ sender:AnyObject){
        recent()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !verifyReceipt(.Analyze) {
            changeToBuyPage()
            return
        }
    }
   
    func requests() {
        
        if ProxyGroupSettings.share.historyEnable{
            //resultsFin.removeAll()
            if !session.isEmpty {
                dbURL = RequestHelper.shared.openForApp(session)
            }
            resultsFin = RequestHelper.shared.fetchAll()
        }
        
    }
    func test() {
        let path = Bundle.main.path(forResource: "1.txt", ofType: nil)
        if let _ = NSData.init(contentsOfFile: path!) {
            
        }
    }
    func recent(){
        // Send a simple IPC message to the provider, handle the response.
        //AxLogger.log("send Hello Provider")
        //var rpc = false
        if let m = SFVPNManager.shared.manager  {
            let date = Date()
            let  me = SFVPNXPSCommand.RECNETREQ.rawValue + "|\(date)"
            if let session = m.connection as? NETunnelProviderSession,
                let message = me.data(using: .utf8), m.connection.status == .connected
            {
                do {
                    //rpc = true
                    try session.sendProviderMessage(message) {[weak self] response in
                        guard let s = self else {return}
                        if response != nil {
                            //let responseString = NSString(data: response!, encoding: NSUTF8StringEncoding)
                            //mylog("Received response from the provider: \(responseString)")
                            s.processData(data: response!)
                            //self.registerStatus()
                        } else {
                            s.alertMessageAction("Got a nil response from the provider",complete: nil)
                        }
                    }
                } catch {
                    alertMessageAction("Failed to send a message to the provider",complete: nil)
                }
            }
        }
        
    }
    func processData(data:Data)  {
        results.removeAll()
        //let responseString = NSString(data: response!, encoding: NSUTF8StringEncoding)
        let obj = try! JSON.init(data: data)
        if obj.error == nil {
            
            let count = obj["count"]
            self.session = obj["session"].stringValue
            //print("recent request count:\(count.stringValue)")
            if count.intValue != 0 {
                //alertMessageAction("Don't have Record yet!",complete: nil)
                //return
                let result = obj["data"]
                if result.type == .array {
                    for item in result {
                        
                        let json = item.1
                        let r = SFRequestInfo.init(rID: 0)
                        r.map(json)
                        
                        results.append(r)
                    }
                }
                if results.count > 0 {
                    results.sort(by: { $0.sTime.compare($1.sTime as Date) == ComparisonResult.orderedDescending })
                    
                }
            
            }
            
            
        }
        requests()
        tableView.reloadData()
        //mmlog("Received response from the provider: \(responseString)")
        //self.registerStatus()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        
    
        // #warning Incomplete implementation, return the number of sections
        if ProxyGroupSettings.share.historyEnable{
            return 2
        }
        return 1
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
   
        if ProxyGroupSettings.share.historyEnable{
            if section == 0 {
                return "Active REQUESTS"
            }
            return "RENCENT REQUESTS"
        }else {
            return "Active REQUESTS"
        }
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            if results.count == 0 {
                return 1
            }
            return results.count
        }else {
            return resultsFin.count
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
  
        let cell = tableView.dequeueReusableCell(withIdentifier: "recent", for: indexPath)
        cell.updateStandUI()
        
        // Configure the cell...
        
        var  request:SFRequestInfo?
        if indexPath.section == 0 {
            if indexPath.row < results.count {
                request = results[indexPath.row]
            }
            
        }else {
            request = resultsFin[indexPath.row]

        }
        
        
        
        if let request = request{
            cell.detailTextLabel?.textColor = UIColor.lightGray
            
            cell.textLabel?.text = request.url //+   " " + String(request.reqID) + " "  + String(request.subID)

            cell.detailTextLabel?.attributedText = request.detailString()
        }else {
            cell.textLabel?.text = "Session Not Start".localized
            if let m = SFVPNManager.shared.manager {
                if m.connection.status == .connected {
                    cell.textLabel?.text = "Session Running"
                }
            }
            
            cell.detailTextLabel?.text = ""
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
        if segue.identifier == "requestDetail" {
            guard let detail = segue.destination as? RequestDetailViewController else{return}
            guard let indexPath = self.tableView.indexPath(for: sender as! UITableViewCell) else {return }
            var  request:SFRequestInfo
            if indexPath.section == 0 {
                if results.count == 0 {
                    return
                }else {
                    request = results[indexPath.row]
                }
                
            }else {
                request = resultsFin[indexPath.row]
                
            }
            if request.url.isEmpty {
                alertMessageAction("Request url empty", complete: nil)
            }else {
                detail.request = request
            }
            
        }
        
     }
    
}
