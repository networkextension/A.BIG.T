//
//  FlyViewController.swift
//  Surf
//
//  Created by 孔祥波 on 8/3/16.
//  Copyright © 2016 abigt. All rights reserved.
//

import UIKit
import SFSocket
import XRuler
class FlyViewController: UIViewController {

    var oriPoint:CGPoint?
    @IBOutlet var plane:PlaneView!
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
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if touch.view === plane {
                oriPoint = touch.location(in: self.view)
                plane.center = oriPoint!
            }
            
            
        }
        
    }
    override func touchesMoved(_ touches: Set<UITouch>, with  event: UIEvent?) {
        if let touch = touches.first {
           
            if let _ = oriPoint{
                oriPoint = touch.location(in: self.view)
                plane.center = oriPoint!
            }
            
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
       
        if let touch = touches.first {
            if let _ = oriPoint{
                oriPoint = touch.previousLocation(in: self.view)
                plane.center = oriPoint!
                goWith(t: touch)
                
            }
            
        }
    }
    func goWith(t:UITouch) {
        let p = t.location(in: self.view)
        if  p.y < oriPoint!.y{
            print("ok")
            let  dx =  p.x - oriPoint!.x
            let  dy = p.y  - oriPoint!.y
            let tt = dx / dy
          
            
            
            let dest = CGPoint.init(x: p.x - 800 * tt, y: p.y - 800)
            UIView.animate(withDuration: 1.0, animations: { [weak self] in
                self?.plane.center = dest
            }, completion: { [weak self ](fin) in
                if let s = self {
                    s.dail()
                }
            })
        }else {
            print("failure")
        }
    }
    func dail(){
        if let m = SFVPNManager.shared.manager {
            if m.isEnabled {
                let selectConf = ProxyGroupSettings.share.config
                let _ = try! SFVPNManager.shared.startStopToggled(selectConf)
                
            }else {
                m.isEnabled = true
                SFVPNManager.shared.saveVPNManger({ (e) in
                    print("enabled save done")
                })
            }
        }else {
            let vpnmanager = SFVPNManager.shared
            if !vpnmanager.loading {
                vpnmanager.loadManager() {
                    (manager, error) -> Void in
                    if let _ = manager {
                        //self!.tableView.reloadData()
                        //self!.registerStatus()
                        vpnmanager.xpc()
                    }
                }
            }else {
               // mylog("vpnmanager loading")
            }

        }
        Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(FlyViewController.reset(_:)) , userInfo: nil, repeats: false)
    }
    @objc func reset(_ t:Timer){
        var x = true
        if let m = SFVPNManager.shared.manager {
            if m.connection.status == .connected {
                x = false
            }
        }
        if x{
           plane.center = self.view.center
        }
    }
}
