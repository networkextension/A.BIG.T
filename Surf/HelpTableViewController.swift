//
//  HelpTableViewController.swift
//  Surf
//
//  Created by abigt on 15/12/3.
//  Copyright © 2015年 abigt. All rights reserved.
//

import UIKit
import StoreKit
import SFSocket
import IoniconsSwift
import XRuler
import XFoundation
class HelpTableViewController: SFTableViewController {

    let listmain:[String] = ["\u{f37a}iCloud sync","\u{f37b}Theme","\u{f36c}Advance","\u{f37f}Clean Cache"]//"⌘Proxy Chain",
        
    let list:[String] = ["\u{f12f}Config Sample View","\u{f12e}Config Manual Chinese Edition","\u{f243}Follow us on Twitter","\u{f388}Rate/Review On AppStore","\u{f141}Acknowledge"]
    let funcTitles:[String] = ["Ad Block"]
    
    @IBOutlet var versionLable:UILabel?
    @IBOutlet var  logo:UIImageView?
    @IBOutlet var  logoBackgroundView:UIView?
    func tURL() ->URL {
        let tURL = "twitter://user?screen_name=Network_ext"
        var u = URL.init(string: tURL)!
        if UIApplication.shared.canOpenURL(u){
            return u
        }else {
            u = URL.init(string: "tweetbot://Network_ext/user_profile/Network_ext")!
            if UIApplication.shared.canOpenURL(u) {
                return u
            }else {
                let u = URL(string: "http://www.twitter.com/Network_ext")!
                return u
            }
            

        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorInset=UIEdgeInsetsMake(0,50, 0, 0);
        self.title = "Help".localized
        logo?.layer.cornerRadius = 12.0
        logo?.layer.masksToBounds = true
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func refreshTheme(){
        super.refreshTheme()
        if ProxyGroupSettings.share.wwdcStyle {
            self.logoBackgroundView?.backgroundColor = UIColor.init(red: 0x2d/255.0, green: 0x30/255.0, blue: 0x3b/255.0, alpha: 1.0)
            
        }else {
            self.logoBackgroundView?.backgroundColor = UIColor.groupTableViewBackground
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if UserDefaults.standard.bool(forKey: "iCloudEnable") {
            sync()
        }
        
       
        versionLable?.text = "Version ".localized + appVersion() + " (Build ".localized + appBuild() + ")"
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
    
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return listmain.count
        }
        return list.count
    }

    @IBAction func proxyChainChanged(_ myswitch:UISwitch){
        if let msg = ProxyGroupSettings.share.updateProxyChain(myswitch.isOn){
            alertMessageAction(msg, complete: nil)
            myswitch.isOn = false
            return
        }
        
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     
        
        if indexPath.section == 0 {
            // let e = UserDefaults.standard.bool(forKey: "iCloudEnable")
            let cell = tableView.dequeueReusableCell(withIdentifier: "commonSwitch", for: indexPath) as! SampleSwitchCell
            
            let txt =  listmain[indexPath.row]
            
            cell.iconlabel?.font = UIFont.init(name: "Ionicons", size: 17)!
            cell.iconlabel?.text =  txt.to(index: 1)
            
            let new = txt.from(index: 1)
            cell.label?.text = new.localized
            //Configure the cell...
            cell.updateUI()
           
           
            if indexPath.row == 1 {
                cell.sfSwitch?.isHidden = false
                cell.sfSwitch?.isOn = ProxyGroupSettings.share.wwdcStyle 
                cell.sfSwitch?.addTarget(self, action: #selector( HelpTableViewController.iTheme(_:)), for: .valueChanged)
            }else if indexPath.row == 0 {
                cell.sfSwitch?.isOn = UserDefaults.standard.bool(forKey: "iCloudEnable")
                cell.sfSwitch?.addTarget(self, action: #selector( HelpTableViewController.iCloud(_:)), for: .valueChanged)
            }else if indexPath.row == 100 {
                cell.sfSwitch?.isOn = ProxyGroupSettings.share.proxyChain
                cell.sfSwitch?.addTarget(self, action: #selector( HelpTableViewController.proxyChainChanged(_:)), for: .valueChanged)
            }else {
                cell.sfSwitch?.isHidden = true
            }
            return cell

        }else {
            return configCell(indexPath: indexPath)
        }

        
        

        
    }
    @IBAction func iCloud(_ sender:UISwitch){
        if sender.isOn {
            UserDefaults.standard.set(true, forKey: "iCloudEnable")
        }
        let app =  UIApplication.shared.delegate as! AppDelegate
        app.iCloudEnable = sender.isOn
        if sender.isOn {
            sync()
        }
        
        
        
    }
    @IBAction func iTheme(_ sender:UISwitch){
      
        ProxyGroupSettings.share.updateStyle(sender.isOn)
        
        let app =  UIApplication.shared.delegate as! AppDelegate
        app.appAppearance(sender.isOn)
        
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "themeChanged"), object: nil)
        
    }
    func moverToiCloud(url:URL)  throws{
        let u = applicationDocumentsDirectory
        do {
            let fs = try fm.contentsOfDirectory(atPath: (u.path))
            for fp in fs {
                if fp.hasSuffix(configExt) {
                    
                    let dest = url.appendingPathComponent(fp)
                    let src = u.appendingPathComponent(fp)
                    
                    if FileManager.default.fileExists(atPath: dest.path) {
                        
                    }else {
                        try fm.copyItem(at: src, to: dest)
                        print("copy \(dest.path)")
                    }
                    
                }
                
            }
            let sp  = groupContainerURL().appendingPathComponent(kProxyGroupFile)
            let dp = url.appendingPathComponent("ProxyGroup.json")
            if FileManager.default.fileExists(atPath: dp.path) {
                try fm.removeItem(at: dp)
            }
            try fm.copyItem(at: sp, to: dp)
            
        }catch let e as NSError{
           throw e
            
        }
        
        
    }
    func sync() {
        let app = UIApplication.shared.delegate as! AppDelegate
        guard app.iCloudToken != nil else {
            
            alertMessageAction("iCloud Token invalid", complete: nil)
            return
        }
        DispatchQueue.global().async(execute: { [weak self] in
            guard let countainer = FileManager.default.url(forUbiquityContainerIdentifier: nil) else {
                DispatchQueue.main.async(execute: {
                    self?.alertMessageAction("Error Enable iCloud sysnc")
                })
                return
            }
            print("countainer:url \(String(describing: countainer))")
            
            let  documentsDirectory = countainer.appendingPathComponent("Documents");
            if !FileManager.default.fileExists(atPath: documentsDirectory.path){
                try! FileManager.default.createDirectory(atPath: documentsDirectory.path, withIntermediateDirectories: false, attributes: nil)
            }
            do {
                try self!.moverToiCloud(url: documentsDirectory)
            }catch let  e  {
                DispatchQueue.main.async(execute: {
                    self?.alertMessageAction("icloud sync:\(e.localizedDescription)")
                })
                
            }
            
           
        })
    }
    func configCell(indexPath:IndexPath) -> UITableViewCell {
        print("help configCell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "common", for: indexPath as IndexPath)
        let c = cell as! SampleCell
        let txt =  list[indexPath.row]
        
        
        c.iconlabel?.font = UIFont.init(name: "Ionicons", size: 17)!
        c.iconlabel?.text =  txt.to(index: 1)
        c.label?.text = txt.from(index: 1).localized
        
        c.updateUI()
       
        
        return cell

    }


    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
//        if indexPath.section == 0 {
//            return nil
//        }
        return indexPath
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) ->CGFloat{
        return 48
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        if indexPath.section == 0 {
            if indexPath.row == 3 {
                
                self.performSegue(withIdentifier: "showAdavnce", sender: cell)
            }else if indexPath.row == 4 {
                self.alertMessageAction("Do you want to clean Proxy Cache?", complete: { 
                    ProxyGroupSettings.share.cleanDeleteProxy()
                })
            }
        }else {
            switch indexPath.row{
                
            case 0:
                self.performSegue(withIdentifier: "showURL", sender: cell)
            case 1:
                self.performSegue(withIdentifier: "showURL", sender: cell)
            case 2:
                let u = tURL()
                self.openURL(u)
              
            //self.performSegue(withIdentifier:"showAcknowledge", sender: cell)
            case 3:
                //self.performSegue(withIdentifier:"showAcknowledge", sender: cell)
                if #available(iOS 10.3, *) {
                    SKStoreReviewController.requestReview()
                } else {
                   
                   self.openURL(URL.init(string: "itms-apps://itunes.apple.com/cn/app/a.big.t/id1051326718?l=en&mt=8")!)
                }
                
            case 4:
                self.performSegue(withIdentifier: "showAcknowledge", sender: cell)
            default:
                //self.performSegue(withIdentifier: "showProeDition", sender: cell)
                break
            }
        }
        
    }
    func openURL(_ url:URL)  {
        UIApplication.shared.open(url, options: [:], completionHandler: { fin in
            if fin {
                print("open finished")
            }
        })
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
        guard let indexpath = self.tableView.indexPath(for: sender as! UITableViewCell)  else {return }
         if segue.identifier == "showURL"{
            guard let destController = segue.destination as? SFWebViewController else{return}
            if indexpath.row == 0 {
                let path = Bundle.main.path(forResource: "surf.conf", ofType: nil)
                destController.url = URL.init(fileURLWithPath: path!)
                destController.headerInfo = "Config Sample View"
                
                
            }else if indexpath.row == 1 {
                
                destController.url = URL.init(string: "https://gist.githubusercontent.com/networkextension/069590ba0e95e2fc322f8d10c4212731/raw/d1e34fecb2caaa8704b9aeb789735ad869871415/surf.conf")
                destController.headerInfo = "Config Manual Chinese Edition"
            }else {
                let path = Bundle.main.path(forResource: "ReleaseNote.txt", ofType: nil)
                destController.url = URL.init(string: path!)
                destController.headerInfo = "Release Note"
            }
            
        }else if segue.identifier == "showProeDition"{
            
        }else if segue.identifier == "showAcknowledge"{
            
        }else if segue.identifier == "showReleaseNote"{
            
        }else if segue.identifier == "showAdavnce"{
        }
    }


}
