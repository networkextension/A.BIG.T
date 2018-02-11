//
//  iCloudViewController.swift
//  Surf
//
//  Created by 孔祥波 on 24/03/2017.
//  Copyright © 2017 abigt. All rights reserved.
//

import UIKit

class iCloudViewController: UIViewController {

    @IBOutlet weak var iswitch:UISwitch!
    override func viewDidLoad() {
        super.viewDidLoad()
        let e = UserDefaults.standard.bool(forKey: "iCloudEnable")
        iswitch.isOn = e
        if iswitch.isOn {
            sync()
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func moverToiCloud(url:URL){
        let u = applicationDocumentsDirectory
        do {
            let fs = try fm.contentsOfDirectory(atPath: (u.path))
            for fp in fs {
                if fp.hasSuffix(configExt) {
                    
                    let dest = url.appendingPathComponent(fp)
                    let src = u.appendingPathComponent(fp)
                    //                    let data = NSData.init(contentsOfURL: src)
                    //                    let doc = UIDocument.init(fileURL: dest)
                    //                    try doc.loadFromContents(data!, ofType: "public.text")
                    //                    doc.saveToURL(dest, forSaveOperation: UIDocumentSaveForOverwriting, completionHandler: { (t) in
                    //                        if t {
                    //                            print("\(fp) save ok ")
                    //                        }
                    //                    })
                    if FileManager.default.fileExists(atPath: dest.path) {
                        
                    }else {
                        try fm.copyItem(at: src, to: dest)
                        print("copy \(dest.path)")
                    }
                    
                }
                
            }
        }catch let e as NSError{
            print("\(e.localizedDescription)")
            DispatchQueue.main.async(execute: { [weak self] in
                //self!.alertMessageAction("\(e.description)", complete: nil)
                
            })
            
            
        }
        
        
    }
    @IBAction func iCloud(_ sender:UISwitch){
        if sender.isOn {
           UserDefaults.standard.set(true, forKey: "iCloudEnable")
        }
       let app =  UIApplication.shared.delegate as! AppDelegate
        app.iCloudEnable = sender.isOn
        if sender.isOn {
            sync()
        }
        
        
        
    }

    func sync() {
        DispatchQueue.global().async(execute: { [weak self] in
            let countainer = FileManager.default.url(forUbiquityContainerIdentifier: nil)
            print("countainer:url \(String(describing: countainer))")
            let  documentsDirectory = countainer!.appendingPathComponent("Documents");
            if !FileManager.default.fileExists(atPath: documentsDirectory.path){
                try! FileManager.default.createDirectory(atPath: documentsDirectory.path, withIntermediateDirectories: false, attributes: nil)
            }
            self!.moverToiCloud(url: documentsDirectory)
            if (countainer != nil) {
                DispatchQueue.main.async(execute: {
                    //self?.alertMessageAction("icloud sync ok", complete: nil)
                })
                
            }
        })
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
