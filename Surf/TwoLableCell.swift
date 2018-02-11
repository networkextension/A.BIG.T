//
//  TwoLableCell.swift
//  Surf
//
//  Created by abigt on 16/1/25.
//  Copyright © 2016年 abigt. All rights reserved.
//

import Foundation
import UIKit
import SFSocket
import XRuler
class TwoLableCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var cellLabel: UILabel!
    func wwdcStyle(){
        let style = ProxyGroupSettings.share.wwdcStyle
        if style {
            label.textColor = UIColor.white
            cellLabel.textColor = UIColor.white
        }else {
            label.textColor = UIColor.black
            cellLabel.textColor = UIColor.black
        }
       
    }

}
