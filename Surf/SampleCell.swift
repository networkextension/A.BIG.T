//
//  SampleCell.swift
//  Surf
//
//  Created by abigt on 16/1/18.
//  Copyright © 2016年 abigt. All rights reserved.
//

import UIKit
import XRuler
class SampleCell: UITableViewCell {
     @IBOutlet weak var label:UILabel?
     @IBOutlet weak var iconlabel:UILabel?
     func updateUI(){
        //c.label?.attributedText = s
        //Configure the cell...
        if ProxyGroupSettings.share.wwdcStyle {
            label?.textColor = SFTableViewCell.textcolor
            iconlabel?.textColor = SFTableViewCell.textcolor
        }else {
            label?.textColor = SFTableViewCell.textcolorW
            iconlabel?.textColor = SFTableViewCell.textcolorW
        }
    }
}

class SampleSwitchCell: SampleCell {
    @IBOutlet weak var statuslabel:UILabel?
    @IBOutlet weak var sfSwitch:UISwitch?
    var valueChanged: ((UISwitch) -> Void)?
    @IBAction func enableAction(_ sender:UISwitch){
        valueChanged?(sfSwitch!)
    }
    override func updateUI(){
        super.updateUI()
        if ProxyGroupSettings.share.wwdcStyle {
            statuslabel?.textColor = UIColor.white
            iconlabel?.textColor = SFTableViewCell.textcolor
        }else {
            statuslabel?.textColor = UIColor.darkText
            iconlabel?.textColor = SFTableViewCell.textcolorW
        }
    }
}
