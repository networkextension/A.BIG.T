//
//  SFVerify.swift
//  Surf
//
//  Created by abigt on 2017/6/15.
//  Copyright © 2017年 abigt. All rights reserved.
//

import Foundation
import StoreKit
import SwiftyStoreKit
import ObjectMapper
import SFSocket
import XRuler
extension SFTableViewController {
    func getProductInfo(_ purchase: RegisteredPurchase,complete:@escaping ((String) -> Void)) {
        
        NetworkActivityIndicatorManager.networkOperationStarted()
        SwiftyStoreKit.retrieveProductsInfo([appBundleId + "." + purchase.rawValue]) { result in
            NetworkActivityIndicatorManager.networkOperationFinished()
            complete(self.messageForProductRetrievalInfo(result))
            //self.showAlert(self.alertForProductRetrievalInfo(result))
        }
    }
    //验证产品购买情况
    func verifyReceipt(_ product:RegisteredPurchase = RegisteredPurchase.Pro) ->Bool{
        
        if (Int(appBuild())! % 2) != 0 {
            return true
        }
        if product == .Pro {
            if findPurchase(product) {
                return true
            }else {
                verifyProduct(product, result: {  t in
                    print("222 verifyReceiptBuy \(product.rawValue)")
                    if t {
                        if product == .Pro {
                            
                            print("pro version \(t) \(product.rawValue)")
                        }
                        
                    }else {
                        print("not pro version \(product.rawValue)")
                    }
                })
                
                return  false
            }
        }else {
            return findPurchase(product)
        }
        
        
       
        
    }
    func findPurchase(_ product:RegisteredPurchase = RegisteredPurchase.Pro) ->Bool {
        
        if let receipt = ProxyGroupSettings.share.receipt {
            for inapp in  receipt.in_app {
                print("inapp buy \(inapp.product_id)")
                if inapp.product_id == "com.abigt.Surf." + product.rawValue || inapp.product_id == "com.abigt.Surf.Pro"{
                    print("version buy version > 3.2 ,buy")
                    return  true
                    //break
                }
            }
            
            if let purchase_ms = Int64(receipt.original_purchase_date_ms) {
                if purchase_ms < 1498088100000 {
                    
                    return true
                }
            }
            
            let buyversion = receipt.original_application_version.components(separatedBy: ".")
            let localversion = "3.2".components(separatedBy: ".")
            var purched = false
            for (idx,item) in buyversion.enumerated() {
                
                
                if idx < localversion.count {
                    let x = localversion[idx]
                    if Int(x)! > Int(item)! {
                        print("version buy \(x) item:\(item)")
                        purched = true
                        break
                    }else {
                        continue
                    }
                }else {
                    
                    
                    break
                }
            }
            
            return purched
            
            
            
        }
        
        
        
        return false
    }
    func verifyProduct(_ product:RegisteredPurchase = RegisteredPurchase.Pro,result: @escaping (Bool) ->Void)  {
        //    guard let u = Bundle.main.appStoreReceiptURL else {return }
        //    do {
        //        let data = try Data.init(contentsOf: u)
        //        print(" record \(data)")
        //    }catch let e {
        //        print("nobuy record")
        //    }
        NetworkActivityIndicatorManager.networkOperationStarted()
        verifyReceipt { appresult in
            NetworkActivityIndicatorManager.networkOperationFinished()
            //self.showAlert(self.alertForVerifyReceipt(result))
            switch appresult {
            case .success(let receipt):
                print("Verify receipt Success: \(receipt)")
                NSLog("%@", receipt)
                let r = Mapper<SFStoreReceiptResult>().map(JSON: receipt)
                if let rr = r?.receipt {
                    do {
                       try ProxyGroupSettings.share.saveReceipt(rr)
                    }catch let e {
                        print("\(e.localizedDescription)")
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
                        return
                    }else {
                        for inapp in  rr.in_app {
                            print("inapp buy \(inapp.product_id)")
                            if inapp.product_id == "com.abigt.Surf." + product.rawValue {
                                print("version buy version > 3.2 ,buy")
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
    func verifyReceipt(completion: @escaping (VerifyReceiptResult) -> Void) {
        
        let appleValidator = AppleReceiptValidator(service: .production)
        let password = "e09dbf3ea2454af4bb5f55c8a5d00d8c"
        SwiftyStoreKit.verifyReceipt(using: appleValidator, forceRefresh: true, completion: completion)
    }
    func changeToBuyPage() {
        let vc = UIStoryboard.init(name: "buy", bundle: nil).instantiateInitialViewController()!
        self.navigationController?.pushViewController(vc, animated: true)
    }

    
  
    
    
    
    
    func alertForProductRetrievalInfo(_ result: RetrieveResults) -> UIAlertController {
        
        if let product = result.retrievedProducts.first {
            let priceString = product.localizedPrice!
            return alertWithTitle(product.localizedTitle, message: "\(product.localizedDescription) - \(priceString)")
        } else if let invalidProductId = result.invalidProductIDs.first {
            return alertWithTitle("Could not retrieve product info", message: "Invalid product identifier: \(invalidProductId)")
        } else {
            let errorString = result.error?.localizedDescription ?? "Unknown error. Please contact support"
            return alertWithTitle("Could not retrieve product info", message: errorString)
        }
    }
    
    // swiftlint:disable cyclomatic_complexity
    func alertForPurchaseResult(_ result: PurchaseResult) -> UIAlertController? {
        switch result {
        case .success(let purchase):
            print("Purchase Success: \(purchase.productId)")
            return alertWithTitle("Thank You", message: "Purchase completed")
        case .error(let error):
            print("Purchase Failed: \(error)")
            switch error.code {
            case .unknown: return alertWithTitle("Purchase failed", message: "Unknown error. Please contact support")
            case .clientInvalid: // client is not allowed to issue the request, etc.
                return alertWithTitle("Purchase failed", message: "Not allowed to make the payment")
            case .paymentCancelled: // user cancelled the request, etc.
                return nil
            case .paymentInvalid: // purchase identifier was invalid, etc.
                return alertWithTitle("Purchase failed", message: "The purchase identifier was invalid")
            case .paymentNotAllowed: // this device is not allowed to make the payment
                return alertWithTitle("Purchase failed", message: "The device is not allowed to make the payment")
            case .storeProductNotAvailable: // Product is not available in the current storefront
                return alertWithTitle("Purchase failed", message: "The product is not available in the current storefront")
            case .cloudServicePermissionDenied: // user has not allowed access to cloud service information
                return alertWithTitle("Purchase failed", message: "Access to cloud service information is not allowed")
            case .cloudServiceNetworkConnectionFailed: // the device could not connect to the nework
                return alertWithTitle("Purchase failed", message: "Could not connect to the network")
            case .cloudServiceRevoked: // user has revoked permission to use this cloud service
                return alertWithTitle("Purchase failed", message: "Cloud service was revoked")
            }
        }
    }
    
    
    
    func alertForVerifyReceipt(_ result: VerifyReceiptResult) -> UIAlertController {
        
        switch result {
        case .success(let receipt):
            print("Verify receipt Success: \(receipt)")
            return alertWithTitle("Receipt verified", message: "Receipt verified remotely")
        case .error(let error):
            print("Verify receipt Failed: \(error)")
            switch error {
            case .noReceiptData:
                return alertWithTitle("Receipt verification", message: "No receipt data. Try again.")
            case .networkError(let error):
                return alertWithTitle("Receipt verification", message: "Network error while verifying receipt: \(error)")
            default:
                return alertWithTitle("Receipt verification", message: "Receipt verification failed: \(error)")
            }
        }
    }
    
    func alertForVerifySubscription(_ result: VerifySubscriptionResult) -> UIAlertController {
        
        switch result {
        case .purchased(let expiryDate):
            print("Product is valid until \(expiryDate)")
            return alertWithTitle("Product is purchased", message: "Product is valid until \(expiryDate)")
        case .expired(let expiryDate):
            print("Product is expired since \(expiryDate)")
            return alertWithTitle("Product expired", message: "Product is expired since \(expiryDate)")
        case .notPurchased:
            print("This product has never been purchased")
            return alertWithTitle("Not purchased", message: "This product has never been purchased")
        }
    }
    
    func alertForVerifyPurchase(_ result: VerifyPurchaseResult) -> UIAlertController {
        
        switch result {
        case .purchased:
            print("Product is purchased")
            return alertWithTitle("Product is purchased", message: "Product will not expire")
        case .notPurchased:
            print("This product has never been purchased")
            return alertWithTitle("Not purchased", message: "This product has never been purchased")
        }
    }
    
}
