//
//  AppDelegate.swift
//  Surf
//
//  Created by abigt on 15/11/20.
//  Copyright © 2015年 abigt. All rights reserved.
//

import UIKit
import NetworkExtension
import Darwin
import AxLogger
import SFSocket
import SwiftyStoreKit
import Crashlytics
import Fabric
import XRuler
import Alamofire
import ObjectMapper
import AVFoundation
import Xcon
import XProxy
extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
}
//import Bugly
//public func BLogError(_ format: String, _ args: CVarArg...){
//    BLYLogv(BuglyLogLevel.error, format, getVaList(args))
//    
//}
//
//public func BLogWarn(_ format: String, _ args: CVarArg...){
//    BLYLogv(BuglyLogLevel.warn, format, getVaList(args))
//}
//
//public func BLogInfo(_ format: String, _ args: CVarArg...){
//    BLYLogv(BuglyLogLevel.info, format, getVaList(args))
//}
//
//public func BLogDebug(_ format: String, _ args: CVarArg...){
//    BLYLogv(BuglyLogLevel.debug, format, getVaList(args))
//}

public func iCloudSyncEnabled() ->Bool{
    return UserDefaults.standard.bool(forKey: "icloudsync");
}
public func saveiCloudSync(_ t:Bool) {
    UserDefaults.standard.set(t, forKey:"icloudsync" )
}

func  reportMemoryUsed() ->UInt64 {
    return 0 
}
func crashSignalHandler(signal:Int32)
{
    
    exit(Int32(signal));
}


func installSignalHandler()
{
    //NSSetUncaughtExceptionHandler(&HandleException);
    // learning
    //http://www.cocoawithlove.com/2010/05/handling-unhandled-exceptions-and.html
    //http://devmonologue.com/ios/ios/implementing-crash-reporting-for-ios/
    //#ifdef DEBUG
    signal(SIGABRT, crashSignalHandler);
    signal(SIGSEGV, crashSignalHandler);
    signal(SIGBUS, crashSignalHandler);
    signal(SIGKILL, crashSignalHandler);
    signal(SIGSYS, crashSignalHandler);
    signal(SIGTERM, crashSignalHandler);
    signal(SIGSTOP, crashSignalHandler);
    signal(SIGTSTP, crashSignalHandler);
    signal(SIGXCPU, crashSignalHandler);
    signal(SIGXFSZ, crashSignalHandler);
    signal(SIGILL, crashSignalHandler);
    signal(SIGFPE, crashSignalHandler);
    signal(SIGPIPE, crashSignalHandler);
    signal(SIGTRAP, crashSignalHandler);
    signal(SIGHUP, SIG_IGN);
    let queue: DispatchQueue  = DispatchQueue.global()
    let source  = DispatchSource.makeProcessSource(identifier: 0, eventMask: .signal, queue: queue)
    
    
    let q = DispatchQueue.init(label: "test")
    q.async {
        source.setEventHandler {
            _  = (source as! DispatchSource.ProcessEvent).rawValue
           // crashSignalHandler(signal: event)
            
        }
        source.resume()
    }
    
}

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    
    var iCloudToken:Data?
    var iCloudEnable:Bool = false
    enum ShortcutIdentifier: String {
        case First
        case Second
        case Third
        case Fourth
        
        // MARK: Initializers
        
        init?(fullType: String) {
            guard let last = fullType.components(separatedBy: ".").last else { return nil }
            
            self.init(rawValue: last)
        }
        
        // MARK: Properties
        
        var type: String {
            return Bundle.main.bundleIdentifier! + ".\(self.rawValue)"
        }
    }
//    func testAES() {
//        
//        let password = "xxXxab12lkdjflksjd" // Humans are terrible at picking passwords
//        let message = "Attack at dawn".dataUsingEncoding(NSUTF8StringEncoding)!
//        
//        // Encrypting
//        let ciphertext: NSData = {
//            func randomSaltAndKeyForPassword(password: String) -> (salt: NSData, key: NSData) {
//                let salt = RNCryptor.randomDataOfLength(RNCryptor.FormatV3.saltSize)
//                let key = RNCryptor.FormatV3.keyForPassword(password, salt: salt)
//                return (salt, key)
//            }
//            
//            let (encryptionSalt, encryptionKey) = randomSaltAndKeyForPassword(password)
//            let (hmacSalt, hmacKey) = randomSaltAndKeyForPassword(password)
//            let encryptor = RNCryptor.EncryptorV3(encryptionKey: encryptionKey, hmacKey: hmacKey)
//            
//            let ciphertext = NSMutableData(data: encryptionSalt)
//            ciphertext.appendData(hmacSalt)
//            ciphertext.appendData(encryptor.encryptData(message))
//            return ciphertext
//        }()
//        
//        // Decrypting
//        let plaintext: NSData = {
//            let encryptionSaltRange = NSRange(location: 0, length: RNCryptor.FormatV3.saltSize)
//            let hmacSaltRange = NSRange(location: NSMaxRange(encryptionSaltRange), length: RNCryptor.FormatV3.saltSize)
//            let bodyRange = NSRange(NSMaxRange(hmacSaltRange)..<ciphertext.length)
//            
//            let encryptionSalt = ciphertext.subdataWithRange(encryptionSaltRange)
//            let hmacSalt = ciphertext.subdataWithRange(hmacSaltRange)
//            let body = ciphertext.subdataWithRange(bodyRange)
//            
//            let encryptionKey = RNCryptor.FormatV3.keyForPassword(password, salt: encryptionSalt)
//            let hmacKey = RNCryptor.FormatV3.keyForPassword(password, salt: hmacSalt)
//            
//            return try! RNCryptor.DecryptorV3(encryptionKey: encryptionKey, hmacKey: hmacKey)
//                .decryptData(body)
//        }()
//        
//        // Did it work? Should be true
//        plaintext == message
//
//        
////        let w = SecKeyWrapper.sharedWrapper()
////        for i in 0 ..< 5 {
////            w.generateSymmetricKey()
////            print(w.getSymmetricKeyBytes())
////        }
//        
//    }
    static let applicationShortcutUserInfoIconKey = "applicationShortcutUserInfoIconKey"
    var launchedShortcutItem: UIApplicationShortcutItem?
    
    func icloudPrepare(){
        
        let fm = FileManager.default
        if  let  currentiCloudToken = fm.ubiquityIdentityToken{
            let  newTokenData:NSData = NSKeyedArchiver.archivedData(withRootObject: currentiCloudToken) as NSData
            print("token \(newTokenData)")
            UserDefaults.standard.set(newTokenData, forKey: "com.yarshure.surf.UbiquityIdentityToken")
            iCloudToken = NSKeyedArchiver.archivedData(withRootObject: currentiCloudToken)
            //setObject: newTokenData
            //forKey: @"com.apple.MyAppName.UbiquityIdentityToken"];
        }else {
            UserDefaults.standard
                .removeObject(forKey: "com.yarshure.surf.UbiquityIdentityToken")
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSUbiquityIdentityDidChange, object: nil, queue: OperationQueue.main) { (noti:Notification) in
            print("NSUbiquityIdentityDidChangeNotification")
        }
        iCloudEnable = UserDefaults.standard.bool(forKey: "iCloudEnable")
    }
    func icloudNoti(){
        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSUbiquityIdentityDidChange, object: nil, queue: OperationQueue.main) { (t) in
            print("NSUbiquityIdentityDidChangeNotification incoming")
        }
    }
    func handleShortCutItem(shortcutItem: UIApplicationShortcutItem) -> Bool {
        var handled = false
        
        // Verify that the provided `shortcutItem`'s `type` is one handled by the application.
        guard ShortcutIdentifier(fullType: shortcutItem.type) != nil else { return false }
        
        guard let shortCutType = shortcutItem.type as String? else { return false }
        let config = ProxyGroupSettings.share.config
        switch (shortCutType) {
        case ShortcutIdentifier.First.type:
            // Handle shortcut 1 (static).
            handled = true
            break
        case ShortcutIdentifier.Second.type:
            // Handle shortcut 2 (static).
            handled = true
            break
        case ShortcutIdentifier.Third.type:
            // Handle shortcut 3 (dynamic).
            if let info = shortcutItem.userInfo {
                let x = info[AppDelegate.applicationShortcutUserInfoIconKey] as! NSNumber
                
                ProxyGroupSettings.share.selectIndex = x.intValue
                try! ProxyGroupSettings.share.save()
                //self.window?.rootViewController
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ProxyIndexChanged"), object: nil)
                print("\(x)")
            }
            
            handled = true
            break
        case ShortcutIdentifier.Fourth.type:
            // Handle shortcut 4 (dynamic).
            
            _ = try! SFVPNManager.shared.startStopToggled(config)
            handled = true
            break
        default:
            break
        }
        
        // Construct an alert using the details of the shortcut used to open the application.
//        let alertController = UIAlertController(title: "Shortcut Handled", message: "\"\(shortcutItem.localizedTitle)\"", preferredStyle: .alert)
//        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
//        alertController.addAction(okAction)
//        
//        // Display an alert indicating the shortcut selected from the home screen.
//        window!.rootViewController?.present(alertController, animated: true, completion: nil)
        
        return handled
    }
    
    var window: UIWindow?

    
    func appAppearance(_ blackStyle:Bool ){
        
       
        if blackStyle {
            let color = UIColor.init(red: 0x29/255.0, green: 0x2d/255.0, blue: 0x36/255.0, alpha: 1.0)
            
            //UIApplication.sharedApplication().statusBarStyle = .LightContent
            UINavigationBar.appearance().barTintColor = color
            UINavigationBar.appearance().tintColor = UIColor.white
            UINavigationBar.appearance().isTranslucent = false
            UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white,
                                                                NSAttributedStringKey.font:UIFont.systemFont(ofSize: 21.0)
            ]
            UITableViewCell.appearance().backgroundColor = UIColor.init(red: 0x26/255.0, green: 0x28/255.0, blue: 0x32/255.0, alpha: 1.0)
            
            let color2 = UIColor.init(red: 0x2A/255.0, green: 0x2d/255.0, blue: 0x36/255.0, alpha: 1.0)
            UITabBar.appearance().barTintColor = color2
            
            let color4 = UIColor.init(red: 0x91/255.0, green: 0xAC/255.0, blue: 0xF3/255.0, alpha: 1.0)
            UITabBar.appearance().tintColor = color4
            if #available(iOS 10.0, *) {
                UITabBar.appearance().unselectedItemTintColor = UIColor.gray
            } else {
                // Fallback on earlier versions
            }
            UILabel.appearance(whenContainedInInstancesOf: [UITableViewCell.self]).backgroundColor =  UIColor.clear
           // UILabel.appearance().backgroundColor = UIColor.clear
           // UITableViewCell.appearance().textLabel?.backgroundColor = UIColor.clear
            UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor:UIColor.gray], for: .normal)
            UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor:color4], for: .selected)
            let color3 = UIColor.init(red: 0x26/255.0, green: 0x28/255.0, blue: 0x32/255.0, alpha: 1.0)
            
            UITableView.appearance().backgroundColor = color3
            UITableView.appearance().separatorColor = UIColor.init(red: 0x44/255.0, green: 0x45/255.0, blue: 0x4c/255.0, alpha: 1.0)
            
            UISwitch.appearance().onTintColor = UIColor.cyan// color //UIColor.init(red: 0x91/255.0, green: 0xAC/255.0, blue: 0xF3/255.0, alpha: 1.0)
            UISwitch.appearance().tintColor = color4
            UISwitch.appearance().thumbTintColor = UIColor.init(red: 0x91/255.0, green: 0xAC/255.0, blue: 0xF3/255.0, alpha: 1.0)
            
            UISegmentedControl.appearance().tintColor = color4
            
            UITextView.appearance().backgroundColor = color3
            UITextView.appearance().textColor = UIColor.white
        }else {
            let color = UIColor.init(red: 0x0b/255.0, green: 0x60/255.0, blue: 0xb1/255.0, alpha: 1.0)
            //UIApplication.sharedApplication().statusBarStyle = .LightContent
            UINavigationBar.appearance().barTintColor = color
            UINavigationBar.appearance().tintColor = UIColor.white
            UINavigationBar.appearance().isTranslucent = false
            UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white,
                                                                NSAttributedStringKey.font:UIFont.systemFont(ofSize: 21.0)
            ]
           
            UITableView.appearance().backgroundColor = UIColor.groupTableViewBackground
            UITableView.appearance().separatorColor = UIColor.lightGray
            
            UITableViewCell.appearance().backgroundColor = UIColor.white
            
            let color2 = UIColor.init(red: 0x1/255.0, green: 0x2d/255.0, blue: 0x36/255.0, alpha: 1.0)
            UITabBar.appearance().barTintColor = nil
            
            let color4 = UIColor.init(red: 0x91/255.0, green: 0xAC/255.0, blue: 0xF3/255.0, alpha: 1.0)
            UITabBar.appearance().tintColor = color4
            if #available(iOS 10.0, *) {
                UITabBar.appearance().unselectedItemTintColor = UIColor.gray
            } else {
                // Fallback on earlier versions
            }
            UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor:UIColor.gray], for: .normal)
            UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor:color4], for: .selected)
            let color3 = UIColor.init(red: 0x26/255.0, green: 0x28/255.0, blue: 0x32/255.0, alpha: 1.0)
            
            
            
            
            
            
            UISwitch.appearance().onTintColor = nil // color //UIColor.init(red: 0x91/255.0, green: 0xAC/255.0, blue: 0xF3/255.0, alpha: 1.0)
            UISwitch.appearance().tintColor = nil
            UISwitch.appearance().thumbTintColor = nil
            
            UISegmentedControl.appearance().tintColor = nil
            
            UITextView.appearance().backgroundColor = UIColor.white
            UITextView.appearance().textColor = UIColor.black
            UILabel.appearance(whenContainedInInstancesOf: [UITableViewCell.self]).textColor = nil
        }
        
        if let rootview = window?.rootViewController {
            let x = rootview as! UITabBarController
            let nv = x.viewControllers?.first! as! UINavigationController
            let vc = nv.viewControllers.first! as! ProxyGroupViewController
   
            vc.alertMessageAction("Theme Changed")
        }
        self.window?.subviews.forEach({ (view: UIView) in
            view.removeFromSuperview()
            self.window?.addSubview(view)
        })
    }
    func testIcon()  {
        if #available(iOS 10.3, *) {
            UIApplication.shared.setAlternateIconName("", completionHandler: { (error) in
                
            })
        } else {
            // Fallback on earlier versions
        }
    }
    func testload(){
        let x = ProxyGroupSettings.share
        print(x.selectIndex)
        let _ = x.proxys
    }
  
    func completeIAPTransactions() {
        
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            
            for purchase in purchases {
                // swiftlint:disable:next for_where
                if purchase.transaction.transactionState == .purchased || purchase.transaction.transactionState == .restored {
                    
                    if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    print("purchased: \(purchase.productId)")
                }
            }
        }
    }
    func verify(){
        guard let u = Bundle.main.appStoreReceiptURL else {return }
        do {
            let data = try Data.init(contentsOf: u)
            print(" record \(data)")
            let rr = data.base64EncodedString()
            uploadReceipt(rr)
        
        }catch let e {
            print("nobuy record \(e.localizedDescription)")
        }
    }
    func uploadReceipt(_ re:String)  {
        let p = ["receipt":re]
        Alamofire.request("http://35.189.177.19:5888/verify", method: .post, parameters: p, encoding: URLEncoding.default, headers: nil)
        .responseJSON { (JSON) in
            switch JSON.result{
            case .success(let resp):
                
                if let m  = Mapper<Receipt>().map(JSONObject:resp) {
                    print(m)
                }
                
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    

    }
    func test() {
        SKit.proxyIpAddr = "240.7.1.10"
        
        SKit.dnsAddr = "218.75.4.130"
        SKit.proxyHTTPSIpAddr = "240.7.1.11"
        SKit.xxIpAddr = "240.7.1.12"
        SKit.tunIP = "240.7.1.9"
        Xcon.debugEnable = true
        XRuler.groupIdentifier = "group.com.yarshure.Surf"
        var url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: XRuler.groupIdentifier)!
        url.appendPathComponent("abigt.conf")

        
    }
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool{
        
    
        verify()
        
        Fabric.with([Crashlytics.self])
 //       Fabric.with([Answers.self])

//        let config = BuglyConfig()
//        
//        config.debugMode = true
//        
//        config.viewControllerTrackingEnable = true
//        
//        config.reportLogLevel = BuglyLogLevel.warn
//        
//        Bugly.start(withAppId: "44950d891c", config: config)
//        BLogError("Swift Log Print %@", "Test")
//        BLogWarn("Swift Log Print %@", "Test")

        
        completeIAPTransactions()
       
        
        
        //_ = NEHotspotHelper.supportedNetworkInterfaces()

     
   
      
        prepareApp()
        
        SFConfigManager.manager.copyConfig()
        SFConfigManager.manager.loadConfigs()
        
        // Override point for customization after application launch.
        let shouldPerformAdditionalDelegateHandling = true


        // Install initial verstions of our two extra dynamic shortcuts.
        if application.shortcutItems != nil  {//where shortcutItems.isEmpty
            application.shortcutItems?.removeAll()
            // Construct the items.
            //MARK: disable this feature
//            if let p = ProxyGroupSettings.share.findProxy("Proxy"){
//                let showName = p.showString()
//                var icon = UIApplicationShortcutIcon(type: .play)
//                var value  = UIApplicationShortcutIconType.play.rawValue
//                var title = "Connect"
//                if let m = SFVPNManager.shared.manager {
//                    if m.connection.status == .connected{
//                        //connect = true
//                        icon = UIApplicationShortcutIcon(type: .pause)
//                        value = UIApplicationShortcutIconType.pause.rawValue
//                        title = "Disconnect"
//                    }
//                }
//
//                let shortcut4 = UIMutableApplicationShortcutItem(type: ShortcutIdentifier.Fourth.type, localizedTitle:title , localizedSubtitle: "Proxy  \(showName)", icon:icon, userInfo: [
//                    AppDelegate.applicationShortcutUserInfoIconKey:value]
//                )
//
//                // Update the application providing the initial 'dynamic' shortcut items.
//                application.shortcutItems?.append(shortcut4)
//            }
//
//            for index in 0 ..< ProxyGroupSettings.share.cutCount() {
//                let proxy = ProxyGroupSettings.share.proxys[index]
//                let shortcut3 = UIMutableApplicationShortcutItem(type: ShortcutIdentifier.Third.type, localizedTitle: proxy.showString(), localizedSubtitle: nil, icon: nil, userInfo: [
//                    AppDelegate.applicationShortcutUserInfoIconKey: index//UIApplicationShortcutIconType.Play.rawValue
//                    ]
//                )
//                print("\(proxy.serverAddress):\(proxy.serverPort)")
//                 application.shortcutItems?.append(shortcut3)
//            }




        }

        icloudPrepare()
        icloudNoti()
  
        appAppearance(ProxyGroupSettings.share.wwdcStyle )
        return shouldPerformAdditionalDelegateHandling //true
    }

    /*
     Called when the user activates your application by selecting a shortcut on the home screen, except when
     application(_:,willFinishLaunchingWithOptions:) or application(_:didFinishLaunchingWithOptions) returns `false`.
     You should handle the shortcut in those callbacks and return `false` if possible. In that case, this
     callback is used if your application is already launched in the background.
     */
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler:@escaping (Bool) -> Void) {
        _ = handleShortCutItem(shortcutItem: shortcutItem)
        
        
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        
        return true
    }
    private func application(app: UIApplication, openURL url: URL, options: [String : AnyObject]) -> Bool {
        if url.isFileURL == true {
            let info = ["url":url]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "shouldSaveConfNotification"), object: self, userInfo: info)
            
        }else {
            if let host = url.host {
                var start = false
                if host == "start"{
                    start = true
                }
                var status = false
                if let m = SFVPNManager.shared.manager{
                    
                    if m.connection.status == .connected || m.connection.status == .connecting{
                        status = true
                    }
                    
                    if start && status == false {
                        let s = ProxyGroupSettings.share.config
                        _ = try! SFVPNManager.shared.startStopToggled(s)
                    }
                    if status == false && status {
                        let s = ProxyGroupSettings.share.config
                        _ = try! SFVPNManager.shared.startStopToggled(s)
                    }
                    
                }else {
                    let s = ProxyGroupSettings.share.config
                    _ = try! SFVPNManager.shared.startStopToggled(s)
                }
            }

        }
        
        return true

    }
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "applicationDidBecomeActive"), object: application)
        guard let shortcut = launchedShortcutItem else { return }
        
        
        _ = handleShortCutItem(shortcutItem: shortcut)
        
        launchedShortcutItem = nil
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

