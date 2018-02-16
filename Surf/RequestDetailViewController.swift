//
//  RequestDetailViewController.swift
//  Surf
//
//  Created by abigt on 16/2/15.
//  Copyright © 2016年 abigt. All rights reserved.
//

import UIKit

import SFSocket
import XRuler
import Xcon
import XProxy
extension UITableViewCell {
    func updateStandUI(){
        if ProxyGroupSettings.share.wwdcStyle {
            textLabel?.textColor = UIColor.white
            detailTextLabel?.textColor = UIColor.white
        }else {
            textLabel?.textColor = UIColor.black
            detailTextLabel?.textColor = UIColor.black
        }
    }
}
class HeaderCell: UITableViewCell {
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var headerLabel:UILabel!
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    func wwdcStyle(){
        let  style = ProxyGroupSettings.share.wwdcStyle
        if style {
            titleLabel.textColor = UIColor.white
            headerLabel.textColor = UIColor.white
        }else {
            titleLabel.textColor = UIColor.black
            headerLabel.textColor = UIColor.black
        }
        
        
    }
}
class TrafficCell: UITableViewCell {
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var rxLabel:UILabel!
    @IBOutlet weak var txLabel:UILabel!
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    func wwdcStyle(){
        let style = ProxyGroupSettings.share.wwdcStyle
        if style {
            rxLabel.textColor = UIColor.white
            txLabel.textColor = UIColor.white
            titleLabel.textColor = UIColor.init(red: 0.36, green: 0.65, blue: 0.76, alpha: 1.0)
        }else {
            rxLabel.textColor = UIColor.black
            txLabel.textColor = UIColor.black
            titleLabel.textColor = UIColor.init(red: 0.36, green: 0.65, blue: 0.76, alpha: 1.0)
        }
        
    }
}
class TimingCell: UITableViewCell {
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var ruleLabel:UILabel!
    @IBOutlet weak var estLabel:UILabel!
    @IBOutlet weak var transferLabel:UILabel!
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    func wwdcStyle(){
        
        let style = ProxyGroupSettings.share.wwdcStyle
        if style {
            titleLabel.textColor = UIColor.init(red: 0.36, green: 0.65, blue: 0.76, alpha: 1.0)
            ruleLabel.textColor = UIColor.white
            estLabel.textColor = UIColor.white
            transferLabel.textColor = UIColor.white
        }else {
            titleLabel.textColor = UIColor.init(red: 0.36, green: 0.65, blue: 0.76, alpha: 1.0)
            ruleLabel.textColor = UIColor.black
            estLabel.textColor = UIColor.black
            transferLabel.textColor = UIColor.black
        }
        
        
    }
}
//class TimingCell: UITableViewCell {
//    @IBOutlet weak var ruleLabel:UILabel!
//    @IBOutlet weak var estLabel:UILabel!
//    @IBOutlet weak var transferLabel:UILabel!
//    override func setSelected(selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//        
//    }
//}
class RequestDetailViewController: SFTableViewController {

    var request:SFRequestInfo!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if request == nil {
            return
        }
        self.title = request.url
        //_;Int = -1
        let items = UIBarButtonItem.init(image: UIImage(named: "702-share-toolbar"), style: .plain, target: self, action: #selector(RequestDetailViewController.shareRequestAction(_:)))
        self.navigationItem.rightBarButtonItem = items
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    @objc func shareRequestAction(_ sender:AnyObject){
        
        var style:UIAlertControllerStyle = .actionSheet
        let deviceIdiom = UIScreen.main.traitCollection.userInterfaceIdiom
        switch deviceIdiom {
        case .pad:
            style = .alert
        default:
            break
            
        }
        let alert = UIAlertController.init(title: "Share Request", message: "share request", preferredStyle: style)
        if request.mode == .HTTP {
            
            let action = UIAlertAction.init(title: "Share curl command", style: .default) { [unowned self] (action:UIAlertAction) -> Void in
                self.shareRequest(true,copy:false)
            }
            alert.addAction(action)
        }
        
        let action3 = UIAlertAction.init(title: "Share", style: .default) {[unowned self] (action:UIAlertAction) -> Void in
            //let srcPath = self.filePath?
            //
            
            self.shareRequest(false,copy:false)
        }
        let actionCopy = UIAlertAction.init(title: "Copy as curl command", style: .default) {[unowned self] (action:UIAlertAction) -> Void in
            //let srcPath = self.filePath?
            //
            
            self.shareRequest(true, copy: true)
        }
        alert.addAction(actionCopy)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction) -> Void in
            
        }
        
        
        alert.addAction(action3)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true) { () -> Void in
            
        }
    }
    
    func shareRequest(_ curl:Bool,copy:Bool){
        
        var str:String = ""
        if curl{
            guard let h = request.reqHeader else {return}
            str += "curl  '\(request.url)' "
            for (k,v) in h.parmas() {
                str += " --header '\(k):\(v)' "
            }
            if copy {
                let p = UIPasteboard.general
                p.string = str
                alertMessageAction("Info copyed as curl command", complete: nil)
            }
        }else {
            let result   = request.respObj()
            let j = JSON(result)
            do {
                let  data = try j.rawData()
                //let obj = SFData()
                //obj.data = data
                if   let x = String.init(data: data, encoding: .utf8){
                    str = x
                }

            }catch let error as NSError {
                //AxLogger.log("ruleResultData error \(error.localizedDescription)")
                //let x = error.localizedDescription
                alertMessageAction("JSON error: \(error.localizedDescription)", complete:nil)
                return
            }

        }
        
        if !str.isEmpty{
            let url = URL.init(fileURLWithPath: NSTemporaryDirectory()+"curl.sh")
            try! str.write(to: url, atomically: false, encoding: .utf8)
            let controller = UIActivityViewController(activityItems: [str],applicationActivities:nil)
            
            if let actv = controller.popoverPresentationController {
                actv.barButtonItem = self.navigationItem.rightBarButtonItem // if it is a UIBarButtonItem
                
                // Or if it is a view you can get the view rect
                actv.sourceView = self.view
                // actv.sourceRect = someView.frame // you can also specify the CGRect
            }

            
            controller.completionWithItemsHandler = { (type,complete,items,error) in
                do {
                    try FileManager.default.removeItem(at: url)
                }catch let e {
                    print(e.localizedDescription)
                }
                
            }
            self.present(controller, animated: true, completion: { 
                
            })
            
        }
        
            
        

        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
    
    
        // #warning Incomplete implementation, return the number of sections
        if request == nil {
            return 0
        }
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        //head, status ,req ,policy, resp,timing,traffic
        return 8
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.row {
        case 0,1,3:
            return 44.0
        case 2,4:
            if request.mode == .TCP {
                return 44.0
            }else {
                let font = UIFont(name: "Helvetica", size: 11.0)
                var x:CGFloat = 10
                
                var headerString:String
                if indexPath.row == 2{
                    if let req = request.reqHeader {
                        headerString = req.headerString(nil)
                         x = 30
                    }else {
                        headerString = "HTTP Request Header Error"
                    }
                    
                   
                }else {
                    if let req = request.respHeader {
                        headerString = req.headerString(nil)
                    }else {
                        headerString = "HTTP Response Header Error"
                    }
                    
                    
                }
                if headerString.isEmpty {
                    return 44
                }else {
                    let result = x + heightForView(text: headerString, font: font!, width: self.view.frame.size.width-20)
                    if result < 44.0 {
                        return 44
                    }else {
                        return result
                    }
                }
                
            }
            
    
        case 5:
            return 90
        case 6,7:
            return 70
        default:
            return 44.0
        }
        
    }
    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x:0, y:0, width:width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return label.frame.height
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                //let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...
        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "subTitle", for: indexPath)
            cell.textLabel?.text = request.url
            cell.updateStandUI()
            let t = request.dataDesc(request.sTime)
            let agent = SFAppIden.shared.appDesc(agent: request.app)
            if request.mode == .TCP{
                cell.detailTextLabel?.text = "[TCP] \(t)"
            }else {
                cell.detailTextLabel?.text = "[\(agent)] \(t)"
            }
            
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "subTitle", for: indexPath)
            cell.textLabel?.text = "Status \(request.reqID): \(request.subID)"
            cell.updateStandUI()
            if request.closereason == .noError {
                 cell.detailTextLabel?.text = request.status.description 
            }else {
                 cell.detailTextLabel?.text = request.status.description + " " + request.closereason.description
            }
           
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "subTitle", for: indexPath)
            cell.textLabel?.text = "Policy"
            cell.updateStandUI()
            
            let rule = request.rule
     
            cell.detailTextLabel?.text = "\(rule.policy.description) (\(rule.type.description):\(rule.name)  ProxyName:\(rule.proxyName))"
            return cell
        case 2,4:
            let cell:HeaderCell = tableView.dequeueReusableCell(withIdentifier: "req", for: indexPath) as! HeaderCell
            if indexPath.row == 2 {
                cell.titleLabel.text = "Request Header"
                if request.mode == .TCP {
                    cell.headerLabel.text = "TCP Connection no header"
                }else {
                    if let req = request.reqHeader{
                        let result = req.headerString(nil)
                        cell.headerLabel.text =   result
                        print(result)
                    }else {
                        cell.headerLabel.text =  "HTTP Request Header Error\r\n"
                    }
                }
                
                
            }else {
                cell.titleLabel.text = "Response Header"
                if request.mode == .TCP {
                    cell.headerLabel.text = "TCP Connection no header"
                }else {
                    if let resp = request.respHeader{
                        let result = resp.headerString(nil)
                        cell.headerLabel.text = result
                        //print(result)
                    }else {
                        cell.headerLabel.text =  "HTTP Response Header Error\r\n"
                    }
                    
                }
                
            }
            cell.wwdcStyle()
            return cell
        case 5:
            let cell:TimingCell = tableView.dequeueReusableCell(withIdentifier: "timing", for: indexPath)  as! TimingCell
            cell.ruleLabel.text = "Rule Testing   (\(Int(request.rule.timming*1000)) ms)"
            
            cell.estLabel.text = "Establish  (\(Int(request.connectionTiming*1000)) ms)"
            cell.transferLabel.text = "Transfer  (\(Int(request.transferTiming*1000)) ms)"
            cell.wwdcStyle()
            return cell
        case 6:
            let cell:TrafficCell = tableView.dequeueReusableCell(withIdentifier: "traffic", for: indexPath) as! TrafficCell
            cell.txLabel.text = request.traffice.txString()
            cell.rxLabel.text = request.traffice.rxString()
            cell.wwdcStyle()
            return cell
        case 7:
            let cell:TrafficCell = tableView.dequeueReusableCell(withIdentifier: "ipCell", for: indexPath) as! TrafficCell
            if request.interfaceCell == 1 {
                cell.txLabel.text = "Local WWAN " + request.localIPaddress
            }else {
                cell.txLabel.text = "Local WI-FI " + request.localIPaddress
            }
            cell.wwdcStyle()
            cell.rxLabel.text = "Remote " + request.remoteIPaddress
            return cell
        default:
            return UITableViewCell()
        }
        
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        


        tableView.deselectRow(at: indexPath , animated: true)
        if indexPath.row == 0{
            let ux =  request.url
            var host = ""
            if let u = URL(string:ux),let h = u.host{
                host = h
            }else {
                host = ux
            }
            alertMessageAction("\(host) copyed ", complete: {
                let p = UIPasteboard.general
                p.string = host
            })
            
        }
        _ = UIMenuController.shared

    }
    func copyAction(sender:AnyObject){
        
    }

}
