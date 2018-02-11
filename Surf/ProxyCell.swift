//
//  ProxyCell.swift
//  Surf
//
//  Created by 孔祥波 on 16/4/1.
//  Copyright © 2016年 abigt. All rights reserved.
//

import UIKit
import XRuler
class ProxyCell: CountryCustomProxyCell {

    @IBOutlet weak var enableSwitch:UISwitch!
    var valueChanged: ((UISwitch) -> Void)?
    @IBOutlet weak var starImageView:UIImageView!
    @IBAction func enableAction(sender:UISwitch){
        valueChanged?(enableSwitch)
    }
    func updateUI(){
        super.wwdcStyle()
        if ProxyGroupSettings.share.wwdcStyle {
            proxyLabel.textColor = UIColor.white
            countryLabel.textColor = UIColor.white
        }else {
            proxyLabel.textColor = UIColor.darkText
            countryLabel.textColor = UIColor.darkText
            countryLabel.textColor = UIColor.init(red: 0x0b/255.0, green: 0x60/255.0, blue: 0xb1/255.0, alpha: 1.0)
        }
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
