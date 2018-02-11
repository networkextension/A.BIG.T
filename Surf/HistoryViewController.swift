//
//  HistoryViewController.swift
//  Surf
//
//  Created by 孔祥波 on 21/03/2017.
//  Copyright © 2017 abigt. All rights reserved.
//

import UIKit
import MessageUI
import SFSocket
import XProxy
import XRuler
class HistoryViewController: SFTableViewController,MFMailComposeViewControllerDelegate {
    
    var resultsFin:[SFRequestInfo] = []
    var dbURL:URL?
    var session:String = ""
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
        print("sendmail result \(result)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Requests".localized
        
        requests()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        //let item = UIBarButtonItem.init(image: UIImage.init(named: "760-refresh-3-toolbar"), style: .plain, target: self, action: #selector(RecenetReqViewController.refreshAction(_:)))
        
        
        //self.navigationItem.setRightBarButtonItems([item], animated: false)
        let item = UIBarButtonItem.init(image: UIImage(named: "702-share-toolbar"), style: .plain, target: self, action: #selector(HistoryViewController.newShare(_:)))
        //item.tintColor = UIColor.blueColor()
        
        self.navigationItem.rightBarButtonItem = item
    }
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients([supportEmail])
        mailComposerVC.setSubject("Session log file")
        let data = try! Data.init(contentsOf: self.dbURL!, options: .alwaysMapped)
        let path = self.dbURL!.path
        
        var appEnv:String = "Surfing env:\n "
        let appinfo = appInfo()
        for (k,v) in appinfo {
            appEnv += k + " " + v + "\n"
        }
        appEnv += "请输入其他说明"
        mailComposerVC.setMessageBody(appEnv, isHTML: false)
        let fn = path.components(separatedBy: "/").last
        mailComposerVC.addAttachmentData(data, mimeType: "text/plain", fileName: fn!)
        return mailComposerVC
    }
    func showSendMailErrorAlert() {
        //UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Alert" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        let alert = UIAlertController.init(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", preferredStyle: .alert)
        let action = UIAlertAction.init(title: "OK", style: .default) { (action:UIAlertAction) -> Void in
            
        }
        alert.addAction(action)
        self.present(alert, animated: true) { () -> Void in
            
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !verifyReceipt(.Analyze) {
            changeToBuyPage()
            return
        }
    }
    @objc func newShare(_ sender:AnyObject){
        shareAirDropURL(self.dbURL!, name: self.session+"_db.zip")
    }

    func requests() {
        //resultsFin.removeAll()
        if !session.isEmpty {
            dbURL = RequestHelper.shared.openForApp(session)
            dbURL = dbURL?.appendingPathComponent("db.zip")
        }
        resultsFin = RequestHelper.shared.fetchAll()
        tableView.reloadData()
    }
    func test() {
        let path = Bundle.main.path(forResource: "1.txt", ofType: nil)
        if let _ = NSData.init(contentsOfFile: path!) {
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        
        
        return 1
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return "HISTORY REQUESTS"
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return resultsFin.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "recent", for: indexPath)
        cell.updateStandUI()
        
        // Configure the cell...
        
        var  request:SFRequestInfo?
        
        
        request = resultsFin[indexPath.row]
        
        if let request = request{
            cell.detailTextLabel?.textColor = UIColor.lightGray
            
            cell.textLabel?.text = request.url //+   " " + String(request.reqID) + " "  + String(request.subID)
            
            cell.detailTextLabel?.attributedText = request.detailString()
        }else {
            cell.textLabel?.text = "Session Not Start".localized
            if let m = SFVPNManager.shared.manager {
                if m.connection.status == .connected {
                    cell.textLabel?.text = "Session Running".localized
                }
            }
            
            cell.detailTextLabel?.text = ""
        }
        
        
        return cell
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "requestDetail" {
            guard let detail = segue.destination as? RequestDetailViewController else{return}
            guard let indexPath = self.tableView.indexPath(for: sender as! UITableViewCell) else {return }
            var  request:SFRequestInfo
            
            request = resultsFin[indexPath.row]
            if request.url.isEmpty {
                alertMessageAction("Request url empty", complete: nil)
            }else {
                detail.request = request
            }
            
        }
        
    }
    
}
