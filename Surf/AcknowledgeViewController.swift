//
//  AcknowledgeViewController.swift
//  Surf
//
//  Created by abigt on 15/12/3.
//  Copyright © 2015年 abigt. All rights reserved.
//

import UIKit

class AcknowledgeViewController: UIViewController {

    var headers: [String: String] = [:]
    var body: String?
    var elapsedTime: TimeInterval?
    var segueIdentifier: String?
    @IBOutlet weak var textView:UITextView?
//    var request: Request? {
//        didSet {
//            oldValue?.cancel()
//            
//            title = request?.description
//            //refreshControl?.endRefreshing()
//            headers.removeAll()
//            body = nil
//            elapsedTime = nil
//        }
//    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Acknowledge"
        
        
        
//        let destination = Request.suggestedDownloadDestination(
//            directory: .CachesDirectory,
//            domain: .UserDomainMask
//        )
        //self.request = download(.GET, "http://baike.baidu.com", destination: destination)
        
        //let req = request(.GET, "http://baike.baidu.com", parameters: nil)
        // Do any additional setup after loading the view.
        //edgesForExtendedLayout = .All
        //preferredContentSize = CGSize.init(width: 0, height: 64)
        //textView?.contentInset = UIEdgeInsetsMake(64.0,0.0,0,0.0);
    }
    override func viewDidAppear(_ animated: Bool) {
       super.viewDidAppear(animated)
        let path = Bundle.main.path(forResource: "thanks.txt", ofType: nil)
        guard let p = path else {return}
        let str =  try!   NSString.init(contentsOfFile: p, encoding: String.Encoding.utf8.rawValue)
        self.textView?.text = str as String
    }
    private func downloadedBodyString() -> String {
        let fileManager = FileManager.default
        let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        
        do {
            let contents = try fileManager.contentsOfDirectory(
                at: cachesDirectory,
                includingPropertiesForKeys: nil,
                options: .skipsHiddenFiles
            )
            
            if let
                fileURL = contents.first,
                let data = NSData(contentsOf: fileURL)
            {
                print(data)
                let json = try JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions())
                let prettyData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
                
                if let prettyString = NSString(data: prettyData, encoding: String.Encoding.utf8.rawValue) as String? {
                    try FileManager.default.removeItem(at: fileURL)
                    return prettyString
                }
            }
        } catch {
            // No-op
        }
        
        return ""
    }
    @IBAction func refresh() {
//        guard let request = request else {
//            return
//        }
//        
//        //refreshControl?.beginRefreshing()
//        
//        let start = CACurrentMediaTime()
//        request.responseString { response in
//            let end = CACurrentMediaTime()
//            self.elapsedTime = end - start
//            
//            if let response = response.response {
//                for (field, value) in response.allHeaderFields {
//                    self.headers["\(field)"] = "\(value)"
//                }
//            }
//            
//            if let segueIdentifier = self.segueIdentifier {
//                switch segueIdentifier {
//                case "GET", "POST", "PUT", "DELETE":
//                    self.body = response.result.value
//                case "DOWNLOAD":
//                    self.body = self.downloadedBodyString()
//                default:
//                    break
//                }
//            }
//            
//           
//        }
    }
//    override func viewDidAppear(animated: Bool) {
//        super.viewDidAppear(animated)
//        
//        refresh()
//    }
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
