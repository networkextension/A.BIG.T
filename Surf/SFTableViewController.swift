//
//  SFTableViewController.swift
//  Surf
//
//  Created by abigt on 16/2/14.
//  Copyright © 2016年 abigt. All rights reserved.
//

import UIKit
import SFSocket
import XRuler
import SwiftyStoreKit
enum RegisteredPurchase: String {
    
    case KCP
    case HTTP
    case Rule
    case Analyze
    case Pro
    case VIP
    case OneGB //1GB 不限流量
    //case 30D
    case nonConsumablePurchase
    case consumablePurchase
    case autoRenewablePurchase
    case nonRenewingPurchase
}
open class SFTableViewController: UITableViewController {
    let appBundleId = "com.abigt.Surf"
  
    func dataForShare(filePath:URL?) ->Data? {
        guard let u = filePath else  {
            return nil
        }
        do {
            let  data = try  Data.init(contentsOf: u)
            return data
        }catch let e {
            print(e.localizedDescription)
        }
        return nil
    }
    func messageForProductRetrievalInfo(_ result: RetrieveResults) -> String {
        
        if let product = result.retrievedProducts.first {
            let priceString = product.localizedPrice!
            return  " \(product.localizedTitle) - \(priceString)"
        } else if let invalidProductId = result.invalidProductIDs.first {
            return "Could not retrieve product info" +  " Invalid product identifier: \(invalidProductId)"
        } else {
            let errorString = result.error?.localizedDescription ?? "Unknown error. Please contact support"
            return "Could not retrieve product info " + errorString
        }
        
    }
    
    func alertMessageAction(_ message:String,complete:(() -> Void)?) {
        var style:UIAlertControllerStyle = .alert
        let deviceIdiom = UIScreen.main.traitCollection.userInterfaceIdiom
        switch deviceIdiom {
        case .pad:
            style = .alert
        default:
            break
            
        }
        let alert = UIAlertController.init(title: "Alert", message: message, preferredStyle: style)
        let action = UIAlertAction.init(title: "OK", style: .default) { (action:UIAlertAction) -> Void in
            if let callback = complete {
                callback()
            }
        }
        let actionCancel = UIAlertAction.init(title: "Cancel", style: .default) { (action:UIAlertAction) -> Void in
            
        }
        alert.addAction(action)
        alert.addAction(actionCancel)
        self.present(alert, animated: true) { () -> Void in
            
        }
    }
    
    func alertMessageAction(_ message:String) {
        var style:UIAlertControllerStyle = .alert
        let deviceIdiom = UIScreen.main.traitCollection.userInterfaceIdiom
        switch deviceIdiom {
        case .pad:
            style = .alert
        default:
            break
            
        }
        let alert = UIAlertController.init(title: "Alert", message: message, preferredStyle: style)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            alert.dismiss(animated: false, completion: nil)
        }
        self.present(alert, animated: true) { () -> Void in
            
        }
    }
    
    
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return  .lightContent
    }
    func shareAirDropURL(_ u:URL,name:String) {
        if !FileManager.default.fileExists(atPath: u.path) {
            return
        }
        let dest = URL.init(fileURLWithPath: NSTemporaryDirectory()+name)
        do {
            try FileManager.default.copyItem(at: u, to: dest)
        }catch let e {
            print(e.localizedDescription)
        }
        let controller = UIActivityViewController(activityItems: [dest],applicationActivities:nil)
        if let actv = controller.popoverPresentationController {
            actv.barButtonItem = self.navigationItem.rightBarButtonItem
            actv.sourceView = self.view
        }
        controller.completionWithItemsHandler = { (type,complete,items,error) in
            do {
                try FileManager.default.removeItem(at: dest)
            }catch let e {
                print(e.localizedDescription)
            }
            
        }
        
        self.present(controller, animated: true) { () -> Void in
        }
    }
    override open func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "themeChanged"), object: nil, queue: OperationQueue.main) {[weak self] (noti) in
            if let strong = self {
                strong.refreshTheme()
            }
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    func refreshTheme(){
        let blackStyle = ProxyGroupSettings.share.wwdcStyle
        if blackStyle {
            let color3 = UIColor.init(red: 0x26/255.0, green: 0x28/255.0, blue: 0x32/255.0, alpha: 1.0)
            self.tableView.backgroundColor = color3
        }else {
            self.tableView.backgroundColor =  UIColor.groupTableViewBackground
        }
        self.tableView.reloadData()
    }
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshTheme()
    }
//    override public func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//
//    // MARK: - Table view data source
//
//    override public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }
//
//    override public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

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
//    override open  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return "    "
//    }
//     override open func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
//        return "  "
//    }
    open override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let v = view as! UITableViewHeaderFooterView
        if ProxyGroupSettings.share.wwdcStyle {
            v.contentView.backgroundColor = UIColor.init(red: 0x2d/255.0, green: 0x30/255.0, blue: 0x3b/255.0, alpha: 1.0)
        }else {
             v.contentView.backgroundColor =  UIColor.groupTableViewBackground
        }
        
    }
    open override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int){
        let v = view as! UITableViewHeaderFooterView
        if ProxyGroupSettings.share.wwdcStyle {
            v.contentView.backgroundColor = UIColor.init(red: 0x2d/255.0, green: 0x30/255.0, blue: 0x3b/255.0, alpha: 1.0)
        }else {
             v.contentView.backgroundColor =  UIColor.groupTableViewBackground
        }
        
    }
    func alertWithTitle(_ title: String, message: String) -> UIAlertController {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        return alert
    }
    func showAlert(_ alert: UIAlertController) {
        guard self.presentedViewController != nil else {
            self.present(alert, animated: true, completion: nil)
            return
        }
    }
    func alertForRestorePurchases(_ results: RestoreResults) -> UIAlertController {
        
        if results.restoreFailedPurchases.count > 0 {
            print("Restore Failed: \(results.restoreFailedPurchases)")
            return alertWithTitle("Restore failed", message: "Unknown error. Please contact support")
        } else if results.restoredPurchases.count > 0 {
            print("Restore Success: \(results.restoredPurchases)")
            return alertWithTitle("Purchases Restored", message: "All purchases have been restored")
        } else {
            print("Nothing to Restore")
            return alertWithTitle("Nothing to restore", message: "No previous purchases were found")
        }
    }

}
