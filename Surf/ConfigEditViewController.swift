//
//  ConfigEditViewController.swift
//  Surf
//
//  Created by 孔祥波 on 7/20/16.
//  Copyright © 2016 abigt. All rights reserved.
//

import UIKit
import SFSocket
import XRuler
class ConfigEditViewController: UIViewController {
    //@IBOutlet  var textViewBottomConst:NSLayoutConstraint!
    var url:URL!
    var titleView:TitleView?
    @IBOutlet var textView:UITextView!
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
        alert.addAction(action)
        self.present(alert, animated: true) { () -> Void in
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let config = SFConfigManager.manager.selectConfig else {return}
        self.url = SFConfigManager.manager.urlForConfig(config)
        let string = try! String.init(contentsOf: url, encoding: .utf8)
            //NSString.init(contentsOfURL: url, usedEncoding: NSUTF8StringEncoding)
        self.textView.text = string
        titleView = TitleView.init(frame: CGRect(x:0, y:0, width:240,height: 60));
        //titleView?.backgroundColor = UIColor.cyanColor()
        navigationItem.titleView = titleView
        
        let btn = UIButton.init(type: .system)
        btn.frame = CGRect(x:0, y:0, width: 22, height:22)
        //btn.tintColor = UIColor.blueColor()
        
        btn.setImage(UIImage.init(named: "done"), for: .highlighted)
        btn.setImage(UIImage.init(named: "done"), for: .normal)
        btn.addTarget(self, action: #selector(ConfigEditViewController.doneAction(_:)), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: btn)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ConfigEditViewController.keyboardShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ConfigEditViewController.keyboardHiden(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        // Do any additional setup after loading the view.
    }
    @objc func keyboardShow(_ noti:NSNotification){
        guard let info = noti.userInfo else {return}
        let keyboardFrameValue:NSValue = info[UIKeyboardFrameEndUserInfoKey] as! NSValue
        let keyboardFrame = keyboardFrameValue.cgRectValue
        var  contentInsets: UIEdgeInsets  = self.textView.contentInset;
        contentInsets.bottom = keyboardFrame.height;
        self.textView.contentInset = contentInsets;
        self.textView.scrollIndicatorInsets = contentInsets;
    }
    @objc func keyboardHiden(_ noti:NSNotification){
        var contentInsets:UIEdgeInsets = self.textView.contentInset;
        contentInsets.bottom = 0.0;
        
        self.textView.contentInset = contentInsets;
        self.textView.scrollIndicatorInsets = contentInsets;
    }
    
    @objc func doneAction(_ sender:AnyObject){
        let content = textView.text
        var c = ProxyGroupSettings.share.config
        if c.hasSuffix(".conf"){
            c = c.components(separatedBy: ".conf").first!
        }
        if !removeFile(url){
            return
        }
        do {
            try content?.write(to: url, atomically:true, encoding: String.Encoding.utf8)
            
        }catch let e as NSError{
            alertMessageAction("Save Config Error \(e.localizedDescription)", complete: nil)
            return
        }
        if let s = SFConfigManager.manager.selectConfig {
            SFConfigManager.manager.reloadConfig(s.configName)
        }
        SFConfigManager.manager.writeToGroup(c)
        
        _ =  self.navigationController?.popViewController(animated: true)
    }
    func removeFile(_ u:URL) ->Bool {
        if fm.fileExists(atPath: u.path){
            do {
                try fm.removeItem(at: u)
                return true
                
            }catch let e as NSError {
                alertMessageAction("Save Config Error \(e.localizedDescription)", complete: nil)
                return false

            }
        }
        return true
    }
    func updateTitleView(_ config:String){
        let x = config.components(separatedBy:".").first!
         let url = applicationDocumentsDirectory.appendingPathComponent(config)
        if fm.fileExists(atPath: url.path){
            let config = SFConfig.init(path: url.path, loadRule: true)
            self.titleView?.subLabel.text = config.description()
        }else {
            self.titleView?.subLabel.text = "Config not Found,Please Add"
            
        }
        
        
        self.titleView?.titleLabel.text =   x
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       let c = ProxyGroupSettings.share.config
       updateTitleView(c)
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
