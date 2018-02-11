//
//  SFWebViewController.swift
//  Surf
//
//  Created by abigt on 16/1/18.
//  Copyright © 2016年 abigt. All rights reserved.
//

import UIKit


class SFWebViewController: UIViewController,UIWebViewDelegate{

    var url:URL?
    var headerInfo:String!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var textView:UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = headerInfo
        
        textView.text = "loading"
        
        edgesForExtendedLayout = .all
        
        guard let url = url else {return}
        guard let  scheme =  url.scheme else {return}
        if  scheme.hasPrefix("file") {
            let content  = try! String.init(contentsOf: url)
            textView.text = content
            webView.removeFromSuperview()
        }else {
           webView.frame = self.view.frame
            webView.isOpaque = false;
            
           webView.backgroundColor = UIColor.clear
            textView.removeFromSuperview()
            //            let v = UIWebView.init(frame: self.view.frame)
            //            self.view.addSubview(v)
            
        }

    }
    func loadContent() {
        guard let url = url else {return}
        guard let  scheme =  url.scheme else {return}
        if  scheme.hasPrefix("file") {
            let content  = try! String.init(contentsOf: url)
            textView.text = content
            
        }else {
            let req = NSURLRequest.init(url: url)
           
            //            let v = UIWebView.init(frame: self.view.frame)
            //            self.view.addSubview(v)
            webView.loadRequest(req as URLRequest)
            webView.delegate = self
        }

        
       
        //let data = try! NSData.init(contentsOfURL: url!)
        //
        //webView.loadHTMLString(content, baseURL: url)
       
        //webView.loadData(data!, MIMEType: "application/txt", textEncodingName: "UTF-8", baseURL: NSURL.init(string: "http://abigt.net")!)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadContent()
    }
      func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool{
        return true
    }
    
    func webViewDidStartLoad(_ webView: UIWebView){
        
    }
  
    func webViewDidFinishLoad(_ webView: UIWebView){
        
        let string = "addCSSRule('body', '-webkit-text-size-adjust: 10;')"
        webView.stringByEvaluatingJavaScript(from: string)
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error){
        print(error)
    }
    
    
}
