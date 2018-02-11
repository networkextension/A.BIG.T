//
//  LoglevelTableViewController.swift
//  Surf
//
//  Created by abigt on 16/1/25.
//  Copyright © 2016年 abigt. All rights reserved.
//

import UIKit
import SFSocket
import XRuler
@objc  protocol LoglevelDelegate:class {
    func didSelectLogLevel(controller: LoglevelTableViewController)// file name
    
}
let lableTexts = ["Error","Warning" ,"Info","Notify","Trace"]
class LoglevelTableViewController: SFTableViewController{
    var delegate:LoglevelDelegate?
    //var general:XRuler.General!
    var loglevel:String = ""
    override func viewDidLoad() {
        //Fixme
//        if let g = general {
//            loglevel = g.loglevel
//        }
        super.viewDidLoad()
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath) as! ActionsCell
        loglevel = cell.myLabel.text!
//        if let g = general {
//            //loglevel = g.loglevel
//            if g.loglevel != loglevel {
//                g.loglevel = loglevel
//                delegate?.didSelectLogLevel(controller: self)
//            }
//        }
        _ = self.navigationController?.popViewController(animated: true)
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
         let cell = tableView.dequeueReusableCell(withIdentifier: "action") as! ActionsCell
        cell.myLabel.text = lableTexts[indexPath.row]
        if ProxyGroupSettings.share.wwdcStyle {
            cell.myLabel.textColor = UIColor.white
        }else {
            cell.myLabel.textColor = UIColor.black
        }
        return cell
    }
}
