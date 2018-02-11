//
//  ViewController.swift
//  SwiftyStoreKit
//
//  Created by Andrea Bizzotto on 03/09/2015.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit
import StoreKit
import SwiftyStoreKit
import ObjectMapper
import SFSocket

import XRuler
class PurchaseCell: UITableViewCell {
    @IBOutlet weak var purchase:UIButton!
}
class ProductCell: PurchaseCell {
    var haveInfo:Bool = false
    @IBOutlet weak var production:UILabel!
}
let buyKey = "com.yarshure.Surf.buy"

class ViewController: SFTableViewController {

   
    var receipt:Receipt?
    let purchase1Suffix = RegisteredPurchase.Pro
    //let purchase2Suffix = RegisteredPurchase.VIP// autoRenewablePurchase
    @IBOutlet var versionLable:UILabel?
    @IBOutlet weak var productInfoLabel:UILabel!
    //@IBOutlet weak var statusButton:UIButton!
    // MARK: actions
    @IBAction func getInfo1() {
        getInfo(purchase1Suffix)
    }
    @IBAction func purchase1() {
        purchase(purchase1Suffix)
    }
    @IBAction func verifyPurchase1() {
        verifyPurchase(purchase1Suffix)
    }
//    @IBAction func getInfo2() {
//        getInfo(purchase2Suffix)
//    }
//    @IBAction func purchase2() {
//        purchase(purchase2Suffix)
//    }
//    @IBAction func verifyPurchase2() {
//        verifyPurchase(purchase2Suffix)
//    }
    override func numberOfSections(in tableView: UITableView) -> Int{
        return 3
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 4
        case 1:
            return 1
        case 2:
            return 2
        default:
            return 0
            
        }
    }
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "purchase") as! PurchaseCell
            if indexPath.row == 1 {
                cell.purchase.setTitle("Restore Purchase", for: .normal)
                cell.purchase.addTarget(self, action: #selector(ViewController.restorePurchases), for: .touchUpInside)
            }else {
                cell.purchase.setTitle("Verify Purchase", for: .normal)
                cell.purchase.addTarget(self, action: #selector(ViewController.verifyPurchase1), for: .touchUpInside)
            }
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "product") as! ProductCell
            var product = RegisteredPurchase.Pro
            let features = ["Enable KCP","Enable HTTP/Socks5","Enable Customize Rules","Enable Analyze"]
            if indexPath.section == 0 {
                cell.purchase.tag = indexPath.row
                switch indexPath.row {
                case 0:
                    product = RegisteredPurchase.KCP
                    cell.production.text = features[0]
                case 1:
                    product = RegisteredPurchase.HTTP
                    cell.production.text = features[1]
                case 2:
                    product = RegisteredPurchase.Rule
                    cell.production.text = features[2]
                case 3:
                    product = RegisteredPurchase.Analyze
                    cell.production.text = features[3]
                default:
                    break
                }
            }else {
                 cell.purchase.tag = 999
            }
            if ProxyGroupSettings.share.wwdcStyle {
                cell.production.textColor  = UIColor.white
            }else {
                cell.production.textColor  = UIColor.black
            }
            if !cell.haveInfo {
                print("get product info \(product.rawValue)")
                NetworkActivityIndicatorManager.networkOperationStarted()
                SwiftyStoreKit.retrieveProductsInfo([appBundleId + "." + product.rawValue]) { result in
                    NetworkActivityIndicatorManager.networkOperationFinished()
                    cell.haveInfo = true
                    cell.production.text = self.messageForProductRetrievalInfo(result)
                    
                    //self.showAlert(self.alertForProductRetrievalInfo(result))
                }
            }
            var test:Bool = false
            if test {
                if let r = self.receipt {
                    for  ps in  r.in_app {
                        print("***** purchsed \(ps.product_id) \(product.rawValue)")
                        if ps.product_id == appBundleId + "." + product.rawValue {
                            cell.purchase.isEnabled = false
                            cell.purchase.setTitle("Purchased", for: .normal)
                            print("purchsed \(ps.product_id)")
                            break
                        }
                    }
                    
                    
                }

            }else {
                if verifyReceiptBuy(.Pro) {
                    cell.purchase.isEnabled = false
                    cell.purchase.setTitle("Purchased", for: .normal)
                }else {
                    //验证单个商品有没有买
                    if let r = self.receipt {
                        for  ps in  r.in_app {
                            print("***** purchsed \(ps.product_id) \(product.rawValue)")
                            if ps.product_id == appBundleId + "." + product.rawValue {
                                cell.purchase.isEnabled = false
                                cell.purchase.setTitle("Purchased", for: .normal)
                                print("purchsed \(ps.product_id)")
                                break
                            }
                        }
                        
                        
                    }
                }
            }
          
            
            
            
    
            if cell.purchase.allTargets.isEmpty {
                cell.purchase.addTarget(self, action: #selector(ViewController.buyProduct(_:)), for: .touchUpInside)
            }
            
           
            return cell
        }
        
    }
    @objc func buyProduct(_ sender:UIButton){
        
        switch sender.tag {
        case 999:
            purchase(RegisteredPurchase.Pro)
        case 0:
            purchase(RegisteredPurchase.KCP)
        case 1:
            purchase(RegisteredPurchase.HTTP)
        case 2:
            purchase(RegisteredPurchase.Rule)
        case 3:
            purchase(RegisteredPurchase.Analyze)
        default:
            break
        }
    }
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.title = "Purchase"
        
        if let r = ProxyGroupSettings.share.receipt {
            self.receipt = r

        }else {
            _ = verifyReceipt(.Pro)
        }
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let r = ProxyGroupSettings.share.receipt {
            if let ts = Int64(r.original_purchase_date_ms) {
                let buy_date = Date.init(timeIntervalSince1970:TimeInterval(ts/1000))
                let df = DateFormatter()
                df.dateFormat = "yyyy/MM/dd HH:mm:ss"
                df.timeZone = NSTimeZone.system
                versionLable?.text = "Version " +  String(r.original_application_version) + " \(df.string(from: buy_date))" 
            }
        }
    }
    func verifyReceiptBuy(_ product:RegisteredPurchase = RegisteredPurchase.Pro) ->Bool{
        
        if (Int(appBuild())! % 2) != 0 {
            return true
        }
        if findPurchase(product) {
            return true
        }else {
            verifyProduct(product, result: {  t in
                print("111 verifyReceiptBuy \(product.rawValue)")
                if t {
                    if product == .Pro {
                        
                        print("pro version \(product.rawValue)")
                    }
                    self.tableView.reloadData()
                }else {
                    print("not pro version \(product.rawValue)")
                }
            })
            
            return  false
        }
        
    }

    //只是Pro而已，其他独立feature 单独
     func verify(result: @escaping (Bool) ->Void)  {
            
        NetworkActivityIndicatorManager.networkOperationStarted()
        verifyReceipt { appresult in
            NetworkActivityIndicatorManager.networkOperationFinished()
            //self.showAlert(self.alertForVerifyReceipt(result))
            switch appresult {
            case .success(let receipt):
                //print("Verify receipt Success: \(receipt)")
                let r = Mapper<SFStoreReceiptResult>().map(JSON: receipt)
                if let rr = r?.receipt {
                    self.receipt = rr
                    
                    do {
                        try ProxyGroupSettings.share.saveReceipt(rr)
                    }catch let e {
                        print(" \(e.localizedDescription)")
                    }
                    
                    //按版本，不是购买时间3.2 以后免费
                    
                    let buyversion = rr.original_application_version.components(separatedBy: ".")
                    let localversion = "3.2".components(separatedBy: ".")
                    var purched = false
                    for (idx,item) in buyversion.enumerated() {
                        
                        
                        if idx < localversion.count {
                            let x = localversion[idx]
                            if Int(x)! > Int(item)! {
                                
                                purched = true
                                break
                            }else {
                                continue
                            }
                        }else {
                            
                            
                            break
                        }
                    }
                    if purched {
                        result(purched)
                    }else {
                        for inapp in  rr.in_app {
                            if inapp.product_id == "com.yarshure.Surf.Pro" {
                                print("version buy version > 3.2 ,buy \(inapp.product_id)")
                                purched = true
                                break
                            }
                        }
                    }
                    result(purched)
                }else {
                    result(false)
                }
                
            case .error(let error):
                print("Verify receipt Failed: \(error)")
                var alert:UIAlertController
                switch error {
                case .noReceiptData:
                    alert = self.alertWithTitle("Receipt verification", message: "No receipt data. Try again.")
                    
                case .networkError(let error):
                    alert = self.alertWithTitle("Receipt verification", message: "Network error while verifying receipt: \(error)")
                    
                default:
                    alert =  self.alertWithTitle("Receipt verification", message: "Receipt verification failed: \(error)")
                }
                self.showAlert(alert)
            }
            
        }
    }
    func getInfo(_ purchase: RegisteredPurchase) {

        NetworkActivityIndicatorManager.networkOperationStarted()
        SwiftyStoreKit.retrieveProductsInfo([appBundleId + "." + purchase.rawValue]) { result in
            NetworkActivityIndicatorManager.networkOperationFinished()
            self.productInfoLabel.text = self.messageForProductRetrievalInfo(result)
            //self.showAlert(self.alertForProductRetrievalInfo(result))
        }
    }

    func purchase(_ purchase: RegisteredPurchase) {

        NetworkActivityIndicatorManager.networkOperationStarted()
        SwiftyStoreKit.purchaseProduct(appBundleId + "." + purchase.rawValue, atomically: true) { result in
            NetworkActivityIndicatorManager.networkOperationFinished()

            if case .success(let purchase) = result {
                // Deliver content from server, then:
                if purchase.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
                self.verify(result: { t in
                    if t {
                         self.tableView.reloadData()
                    }
                })
               
            }
            if let alert = self.alertForPurchaseResult(result) {
                self.showAlert(alert)
            }
        }
    }

    @IBAction func restorePurchases() {

        NetworkActivityIndicatorManager.networkOperationStarted()
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            NetworkActivityIndicatorManager.networkOperationFinished()

            for purchase in results.restoredPurchases where purchase.needsFinishTransaction {
                // Deliver content from server, then:
                SwiftyStoreKit.finishTransaction(purchase.transaction)
            }
            self.showAlert(self.alertForRestorePurchases(results))
        }
    }

//    @IBAction func verifyReceipt() {
//
//        NetworkActivityIndicatorManager.networkOperationStarted()
//        verifyReceipt { result in
//            NetworkActivityIndicatorManager.networkOperationFinished()
//            self.showAlert(self.alertForVerifyReceipt(result))
//        }
//    }
    
//    func verifyReceipt(completion: @escaping (VerifyReceiptResult) -> Void) {
//        
//        let appleValidator = AppleReceiptValidator(service: .production)
//        let password = "e09dbf3ea2454af4bb5f55c8a5d00d8c"
//        SwiftyStoreKit.verifyReceipt(using: appleValidator, password: password, completion: completion)
//    }

    func verifyPurchase(_ purchase: RegisteredPurchase) {

        NetworkActivityIndicatorManager.networkOperationStarted()
        verifyReceipt { result in
            NetworkActivityIndicatorManager.networkOperationFinished()

            switch result {
            case .success(let receipt):

                let productId = self.appBundleId + "." + purchase.rawValue

                switch purchase {
                case .autoRenewablePurchase:
                    let purchaseResult = SwiftyStoreKit.verifySubscription(
                        ofType: .autoRenewable,
                        productId: productId,
                        inReceipt: receipt,
                        validUntil: Date()
                    )
                    self.showAlert(self.alertForVerifySubscription(purchaseResult))
                case .nonRenewingPurchase:
                    let purchaseResult = SwiftyStoreKit.verifySubscription(
                        ofType: .nonRenewing(validDuration: 60),
                        productId: productId,
                        inReceipt: receipt,
                        validUntil: Date()
                    )
                    self.showAlert(self.alertForVerifySubscription(purchaseResult))
                default:
                    let purchaseResult = SwiftyStoreKit.verifyPurchase(
                        productId: productId,
                        inReceipt: receipt
                    )
                    self.showAlert(self.alertForVerifyPurchase(purchaseResult))
                }

            case .error:
                self.showAlert(self.alertForVerifyReceipt(result))
            }
        }
    }

#if os(iOS)
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
#endif
    override func alertForRestorePurchases(_ results: RestoreResults) -> UIAlertController {
        
        if results.restoreFailedPurchases.count > 0 {
            print("Restore Failed: \(results.restoreFailedPurchases)")
            return alertWithTitle("Restore failed", message: "Unknown error. Please contact support")
        } else if results.restoredPurchases.count > 0 {
            print("Restore Success: \(results.restoredPurchases)")
            //statusButton.setTitle("Not Purchased", for: .normal)
            UserDefaults.standard.set("", forKey: buyKey)
            UserDefaults.standard.synchronize()
            
            return alertWithTitle("Purchases Restored", message: "All purchases have been restored")
        } else {
            print("Nothing to Restore")
            return alertWithTitle("Nothing to restore", message: "No previous purchases were found")
        }
    }
}

// MARK: User facing alerts
extension ViewController {

    
}
