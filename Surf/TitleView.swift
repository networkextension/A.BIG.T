//
//  TitleView.swift
//  Surf
//
//  Created by abigt on 16/5/25.
//  Copyright © 2016年 abigt. All rights reserved.
//

import UIKit

class TitleView: UIView {
    var titleLabel:UILabel
    var subLabel:UILabel
    override init(frame: CGRect) {
        var y0:CGFloat = 10.0
        var y1:CGFloat = 32.0
        let os = ProcessInfo().operatingSystemVersion
        switch (os.majorVersion, os.minorVersion, os.patchVersion) {
        case (8, 0, _):
            print("iOS >= 8.0.0, < 8.1.0")
        case (8, _, _):
            print("iOS >= 8.1.0, < 9.0")
        case (11, _, _):
            y0 = y0 - 6
            y1 = y1 - 6
        default:
            // this code will have already crashed on iOS 7, so >= iOS 10.0
            print("iOS >= 9.0.0")
        }
        
        titleLabel = UILabel.init(frame: CGRect(x:0,y: y0,width: frame.size.width,height: 20))
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        //titleLabel?.sizeToFit()
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.white
        
        subLabel = UILabel.init(frame: CGRect(x:0, y:y1, width:frame.size.width, height:15))
        subLabel.font = UIFont.systemFont(ofSize: 12)
        //titleLabel?.sizeToFit()
        subLabel.textAlignment = .center
        subLabel.textColor = UIColor.lightGray
        //subLabel.backgroundColor = UIColor.cyanColor()
        
        super.init(frame: frame)
        self.addSubview(titleLabel)
        self.addSubview(subLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
