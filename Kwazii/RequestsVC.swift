//
//  RequestsVC.swift
//  Kwazii
//
//  Created by abigt on 2018/1/17.
//  Copyright © 2018年 A.BIG.T. All rights reserved.
//

import Cocoa
import XDataService
import SFSocket
import AxLogger
import XRuler
import XProxy
final class RequestsVC: RequestsBasic {
    @IBOutlet weak var  detail:NSView!
    
    var refreshTime =  DispatchSource.makeTimerSource(flags: DispatchSource.TimerFlags(rawValue: 0), queue: DispatchQueue.main)
    func startProxy(){
        SKit.startGCDProxy(port: 10081, dispatchQueue: DispatchQueue.init(label: "Kwazii.dispatch"), socketQueue: DispatchQueue.init(label: "Kwazii.dispatch.socket"))
    }
    
    public override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        print("load....")
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    override func loadView() {
        super.loadView()
    }
    func installTimer(){
        refreshTime.schedule(deadline: .now(), repeating: DispatchTimeInterval.seconds(1), leeway: DispatchTimeInterval.seconds(1))
        refreshTime.setEventHandler {
            [weak self] in
            let data =  SFTCPConnectionManager.shared.recentRequestData()
            self?.processData(data: data)
            //self?.reportTask()
           
        }
        refreshTime.setCancelHandler {
            print("timer cancel......")
        }
        refreshTime.resume()
    }
    @objc required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        startProxy()
        print("load coder....")
        installTimer()
    }
    
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        super.viewDidLoad()
        
        // Do view setup here.
    }
    
}
