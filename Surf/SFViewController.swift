//
//  SFViewController.swift
//  Surf
//
//  Created by 孔祥波 on 9/2/16.
//  Copyright © 2016 abigt. All rights reserved.
//

import UIKit

class SFViewController: UIViewController {

    func dataForShare(filePath:URL?) ->Data? {
        guard let u = filePath else  {
            return nil
        }
        do {
            let  data = try  Data.init(contentsOf: u)
            return data
        }catch let e {
            print(e.localizedDescription)
        }
        return nil
    }
    func fontsize() ->CGFloat {
        var size:CGFloat = 12.0;
        let deviceIdiom = UIScreen.main.traitCollection.userInterfaceIdiom
        switch deviceIdiom {
        case .pad:
            size = 14
        default:
            size = 8
            break
            
        }
        return size
    }
    func alertMessageAction(_ message:String,complete:(() -> Void)?) {
        var style:UIAlertControllerStyle = .alert
        let deviceIdiom = UIScreen.main.traitCollection.userInterfaceIdiom
        switch deviceIdiom {
        case .pad:
            style = .alert
        default:
            break
            
        }
        let alert = UIAlertController.init(title: "Alert", message: message, preferredStyle: style)
        let action = UIAlertAction.init(title: "OK", style: .default) { (action:UIAlertAction) -> Void in
            if let callback = complete {
                callback()
            }
        }
        alert.addAction(action)
        self.present(alert, animated: true) { () -> Void in
            
        }
    }
    
    func shareAirDropURL(_ u:URL,name:String) {
        if !FileManager.default.fileExists(atPath: u.path) {
            return
        }
        let dest = URL.init(fileURLWithPath: NSTemporaryDirectory()+name)
        do {
            try FileManager.default.copyItem(at: u, to: dest)
        }catch let e {
            print(e.localizedDescription)
        }
        let controller = UIActivityViewController(activityItems: [u],applicationActivities:nil)
        if let actv = controller.popoverPresentationController {
            actv.barButtonItem = self.navigationItem.rightBarButtonItem
            actv.sourceView = self.view
        }
        controller.completionWithItemsHandler = { (type,complete,items,error) in
            do {
                try FileManager.default.removeItem(at: u)
            }catch let e {
                print(e.localizedDescription)
            }
            
        }
        
        self.present(controller, animated: true) { () -> Void in
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //automaticallyAdjustsScrollViewInsets = true
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
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
