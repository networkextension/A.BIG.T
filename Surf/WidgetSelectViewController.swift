//
//  WidgetSelectViewController.swift
//  Surf
//
//  Created by 孔祥波 on 7/7/16.
//  Copyright © 2016 abigt. All rights reserved.
//

import UIKit
import SFSocket
import  XRuler
class WidgetSelectCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel:UILabel!
    
    @IBOutlet weak var selectedLabel:UILabel!
    /*
     // Only override drawRect: if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func drawRect(rect: CGRect) {
     // Drawing code
     }
     */
    
}
class WidgetSelectViewController: SFTableViewController {
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Today Widget Config"
        //versionLable?.text = "Version " + appVersion() + " (Build " + appBuild() + ")"
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        return "If Select 0, Widget will can\'t dial(auto remove Surfing Today profile on iOS 9). Bigger then 0, mean Widget show Proxy Count"
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
    
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        //        if section == 0 {
        //            return funcTitles.count
        //        }
        return 6
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
    
        let cell = tableView.dequeueReusableCell(withIdentifier: "widgetCell", for: indexPath as IndexPath)
        let c = cell as! WidgetSelectCell
        c.titleLabel.text = String(indexPath.row)
        cell.updateStandUI()
        
        c.selectedLabel.text =  "\u{f383}"
        
        if ProxyGroupSettings.share.widgetProxyCount == indexPath.row {
            c.selectedLabel.isHidden = false
        }else {
            c.selectedLabel.isHidden = true
        }
        //c.label?.text = list[indexPath.row]
        //Configure the cell...
        
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        ProxyGroupSettings.share.widgetProxyCount = indexPath.row
        if indexPath.row == 0 {
            ProxyGroupSettings.share.disableWidget = true
        }
        try! ProxyGroupSettings.share.save()
        tableView.reloadData()
    }
}
