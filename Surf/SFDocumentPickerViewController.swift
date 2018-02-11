//
//  File.swift
//  Surf
//
//  Created by abigt on 16/2/5.
//  Copyright © 2016年 abigt. All rights reserved.
//

import Foundation
import UIKit
class SFDocumentPickerViewController:UIDocumentPickerViewController {
    override init(documentTypes allowedUTIs: [String], in mode: UIDocumentPickerMode) {
        super.init(documentTypes: allowedUTIs, in: mode)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
    }
}
