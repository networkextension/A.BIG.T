//
//  SFNavigationController.swift
//  Surf
//
//  Created by 孔祥波 on 21/02/2017.
//  Copyright © 2017 abigt. All rights reserved.
//

import UIKit

class SFNavigationController: UINavigationController {
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return  .lightContent
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
