//
//  ImageViewController.swift
//  Surf
//
//  Created by 孔祥波 on 10/17/16.
//  Copyright © 2016 abigt. All rights reserved.
//

import UIKit
import SFSocket
import XRuler
class ImageViewController: UIViewController {
    @IBOutlet weak var imageView:UIImageView!
    //
    var image:UIImage!
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
        let rect = CGRect.init(x: 0, y: 0, width: 30, height: 30)
        let btn = UIButton.init(frame: rect)
        btn.titleLabel?.font = UIFont.init(name: "Ionicons", size: 20)
        btn.setTitle("\u{f3ac}", for: .normal)
        if ProxyGroupSettings.share.wwdcStyle {
           btn.titleLabel?.textColor = UIColor.white 
        }else {
            btn.titleLabel?.textColor = UIColor.black
        }
        
        btn.addTarget(self, action: #selector(ImageViewController.saveConfigToImage(_:)), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: btn)
        //UIBarButtonItem.init(barButtonSystemItem: .save, target: self, action: #selector(ImageViewController.saveConfigToImage(_:)))
        
        // Do any additional setup after loading the view.
    }
    @objc func saveConfigToImage(_ sender: AnyObject){
        //&#xf3ac;
        if let png = UIImagePNGRepresentation(image){
            let url = URL.init(fileURLWithPath: NSTemporaryDirectory()+"BarCode.png")
            try! png.write(to: url)
            let vc = UIActivityViewController(activityItems: [url], applicationActivities: [])
            vc.completionWithItemsHandler = { (type,complete,items,error) in
                do {
                    try FileManager.default.removeItem(at: url)
                }catch let e {
                    print(e.localizedDescription)
                }
                
            }
            vc.popoverPresentationController?.sourceView = self.view
            present(vc, animated: true)

        }
                //UIImageWriteToSavedPhotosAlbum(image, self, #selector(ImageViewController.imageCallBack(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func imageCallBack(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafeRawPointer) {
        if error == nil {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(ac, animated: true, completion: nil)
        } else {
            let ac = UIAlertController(title: "Save error", message: error?.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(ac, animated: true, completion: nil)
        }
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
