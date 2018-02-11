//
//  iTunesFileTableViewController.swift
//  Surf
//
//  Created by abigt on 16/1/18.
//  Copyright © 2016年 abigt. All rights reserved.
//

import UIKit

@objc  protocol AddFileDelegate:class {
    func importFileConfig(controller: iTunesFileTableViewController, config:String)// file name
    func cancelSelect(controller: iTunesFileTableViewController)// file name
}
class iTunesFileTableViewController: UITableViewController {

    var delegate:AddFileDelegate?
    var iTunesFiles:[String] = []
    @objc func scanJsonsFile() {
        if iTunesFiles.count > 0 {
            iTunesFiles.removeAll()
        }
        let files  = try! fm.contentsOfDirectory(atPath: applicationDocumentsDirectory.path)
        for f in files {
            if let x = f.components(separatedBy: ".").last {
                if x == ".conf" {
                    iTunesFiles.append(f)
                }
                
            }
        }
        if iTunesFiles.count > 0 {
            tableView.reloadData()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Please Select config file"
        self.navigationItem.rightBarButtonItem =  UIBarButtonItem.init(barButtonSystemItem: .cancel, target: self, action: #selector(iTunesFileTableViewController.cancelAction(_:)))
        self.navigationItem.leftBarButtonItem =  UIBarButtonItem.init(title: "Refresh", style: .plain, target: self, action: #selector(iTunesFileTableViewController.scanJsonsFile))
        scanJsonsFile()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        var v:UIAlertController
        if iTunesFiles.count == 0 {
            //don't found config
            v = UIAlertController(title: "Alert", message: "Please use iTunes add Config File(\(configExt)) and Retry", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) -> Void in
            }
            v.addAction(action)
            self.present(v, animated: true) { () -> Void in
                
            }
        }

    }
    @objc func cancelAction(_ sender:AnyObject?){
        delegate?.cancelSelect(controller: self)
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return iTunesFiles.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "fileSharing")
        cell?.textLabel?.text = iTunesFiles[indexPath.row]
        return cell!
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
     
        tableView.deselectRow(at: indexPath, animated: false)
        delegate?.importFileConfig(controller: self, config: iTunesFiles[indexPath.row])
    }
}
