//
//  LogFileViewController.swift
//  Surf
//
//  Created by abigt on 15/12/7.
//  Copyright © 2015年 abigt. All rights reserved.
//

import UIKit
import MessageUI
import DarwinCore
import SFSocket
class LogFileViewController: SFViewController,MFMailComposeViewControllerDelegate {

    var filePath:URL?
    var showRouter:Bool = false
    var queue = DispatchQueue(label:"com.abigt.route")
    @IBOutlet weak  var textView:UITextView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.test()
        //fixed a crash bug
        
       textView?.text = "loading ..."
//        let btn = UIButton.init(type: .Custom)
//        btn.addTarget(self, action: "shareLog:", forControlEvents: .TouchUpInside)
//        btn.setImage(UIImage(named: "702-share-toolbar"), forState: .Normal)
//        btn.setImage(UIImage(named: "702-share-toolbar-selected"), forState: .Highlighted)
//        btn.sizeToFit()
        if !showRouter {
            let item = UIBarButtonItem.init(image: UIImage(named: "702-share-toolbar"), style: .plain, target: self, action: #selector(LogFileViewController.newShare(_:)))
            //item.tintColor = UIColor.blueColor()
            
            self.navigationItem.rightBarButtonItem = item
        }else {
            self.title = "Route Table"
            let fontSize = fontsize()
            self.textView?.font = UIFont.init(name: "Courier", size: fontSize)
        }
        
        // Do any additional setup after loading the view.
        edgesForExtendedLayout = .all //| .Bottom
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if showRouter {
            
            let txt  = Route.currntRouterInet4(true, defaultRouter: false) 
            self.textView?.text = txt
           
        
            
        }else {
            if let u = filePath {
                if u.path.components(separatedBy: ".").last! != "log"{
                    textView?.text = "Can't Open"
                    return
                }
                do {
                    let content = try String.init(contentsOf: u)//File: filePath!, encoding: NSUTF8StringEncoding)
                    textView?.text = content as String
                } catch let  e  {
                    self.alertMessageAction("Error:\(e.localizedDescription)", complete: nil)
                }
                
            }else {
                self.alertMessageAction("Can't Find File Path", complete: nil)
            }
        }
        
    }
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients([supportEmail])
        mailComposerVC.setSubject("Surf running log file")
        let data = try! Data.init(contentsOf: filePath!) 
        let path = filePath!.path
        
        var appEnv:String = "Surfing env:\n "
        let appinfo = appInfo()
        for (k,v) in appinfo {
            appEnv += k + " " + v + "\n"
        }
        appEnv += "请输入其他说明，例如:FaceBook 不能打开等"
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

   
    @objc func newShare(_ sender:AnyObject){

        shareAirDropURL(self.filePath!,name:"abigt.log")
        
    }

    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
        print("sendmail result \(result)")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
