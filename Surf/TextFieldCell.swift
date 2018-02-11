//
//  TextFieldCell.swift
//  Surf
//
//  Created by kiwi on 15/11/23.
//  Copyright © 2015年 abigt. All rights reserved.
//

import UIKit
import SFSocket
import XRuler
class TextFieldCell: UITableViewCell,UITextFieldDelegate {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var cellLabel: UILabel?
    
    
    var valueChanged: ((UITextField) -> Void)?
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        valueChanged?(textField)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        valueChanged?(textField)
        return true
    }
    deinit{
    
    }
    func wwdcStyle(){
        let style = ProxyGroupSettings.share.wwdcStyle
        if style {
            textField.textColor = UIColor.white
            cellLabel?.textColor = UIColor.white
        }else {
            textField.textColor = UIColor.black
            cellLabel?.textColor = UIColor.black
        }
        
    }
}
