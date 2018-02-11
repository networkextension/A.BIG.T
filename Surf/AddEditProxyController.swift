//
//  AddEditController.swift
//  Surf
//
//  Created by kiwi on 15/11/20.
//  Copyright © 2015年 abigt. All rights reserved.
//

import Foundation
import UIKit
import SFSocket
import Photos
import AssetsLibrary
import XRuler
enum UIUserInterfaceIdiom : Int {
    case Unspecified
    
    case Phone // iPhone and iPod touch style UI
    case Pad // iPad style UI
}
class MiscCell: UITableViewCell {
    @IBOutlet weak var button:UIButton?
}
/// The tunnel delegate protocol.
protocol AddEditProxyDelegate:class {
    func addProxyConfig(_ controller: AddEditProxyController, proxy:SFProxy)//
    func editProxyConfig(_ controller: AddEditProxyController, proxy:SFProxy)//
}
let label:[String] = ["Server","Port","Username","Password","TLS","KCPTUN","KCPTUN parameter"]
let tlsAlert = "Note:if enable TLS,Server value must domain name".localized
let  supported_ciphers = [
    "rc4",
    "rc4-md5",
    "aes-128-cfb",
    "aes-192-cfb",
    "aes-256-cfb",
    "bf-cfb",
    "cast5-cfb",
    "des-cfb",
    "rc2-cfb",
    "salsa20",
    "chacha20",
    "chacha20-ietf"
]
let  supported_ciphers_press = "aes"
class SegmentCell:UITableViewCell {
    @IBOutlet weak var segement:UISegmentedControl!
}
import Xcon
public class AddEditProxyController: SFTableViewController ,BarcodeScanDelegate,SFMethodDelegate
 //UIImagePickerControllerDelegate,UINavigationControllerDelegate
{
    var numberOfSetting: Int = 0
    var useCamera:Bool = true
    var proxy:SFProxy!
    var qrImage:UIImage?
    var chain:Bool = false
    //var config:String = "" //fn
    weak var delegate:AddEditProxyDelegate?
    
    var add:Bool = false
    var textFields = NSMutableArray()
    var firstLoad:Bool = true
    
    var addressField:UITextField?
    var portField:UITextField?
    var usernameField:UITextField?
    var passwordField:UITextField?
    var kcpparamterField:UITextField?
    var proxyNameField:UITextField?
    //@IBOutlet weak var contro:UISegmentedControl!

    override public func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Proxy Config".localized
        //NSTimer.scheduledTimerWithTimeInterval(1.0, target: self.tableView, selector: "reloadData", userInfo: nil, repeats: false)
        //config.proxyName = "Surf"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action:#selector(AddEditProxyController.saveConfig(_:)))
        
        if proxy == nil {
            proxy = SFProxy.create(name: "PROXY", type: .SS, address: "", port: "", passwd: "", method: "aes-256-cfb",tls: false)
            add = true
        }
        
    }

    @IBAction func valueChanged(sender:UISegmentedControl){
        let index = sender.selectedSegmentIndex
        //AxLogger.log("\(sender.titleForSegmentAtIndex(index))")
        print(index)
        if firstLoad {
            var indext = 0
            if proxy.type == .HTTPS || proxy.type == .HTTP{
                indext = 0
            }else {
                indext = 1
            }
            sender.selectedSegmentIndex = indext
            firstLoad = false
            return
        }
        if proxy.method == supported_ciphers_press {
            proxy.type = .HTTPAES
        }
        if index == 0 {
            proxy.type = .HTTP
        }else if index == 1{
            proxy.type = .SOCKS5
            for method in  supported_ciphers {
                if method == proxy.method {
                    proxy.type = .SS
                    return
                }
            }
        }
       
 

    }
    func saveConfigTemp(){
        proxy.serverAddress = self.addressField!.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        proxy.proxyName = self.proxyNameField!.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        proxy.serverPort = self.portField!.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        proxy.method = self.usernameField!.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        proxy.password = self.passwordField!.text!.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    @IBAction func saveConfig(_ sender: AnyObject){
        //guard let d = self.delegate else{ return }
        
        if proxy.kcptun {
            if !verifyReceipt(.KCP) {
                
                changeToBuyPage()
                return
            }
        }
        proxy.serverAddress = self.addressField!.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        proxy.proxyName = self.proxyNameField!.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        proxy.serverPort = self.portField!.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        proxy.method = self.usernameField!.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        proxy.password = self.passwordField!.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        //proxy.mode = self.kcpparamterField!.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if proxy.proxyName.isEmpty || proxy.serverAddress.isEmpty || proxy.serverPort.isEmpty {
            alertMessageAction("Config Invalid!".localized,complete: nil)
        }
        
        
        
        if  proxy.type == .SS {
            var found = false
            for method in  supported_ciphers {
                if method == proxy.method {
                    found = true
                    
                    break
                }
                            }
            if found == false {
                alertMessageAction("Method Invalid".localized, complete: nil)
                return
            }
            if proxy.password.isEmpty {
                alertMessageAction("Empty Password".localized, complete: nil)
                return
            }
        }
        
        
        if proxy.tlsEnable {

        }
        
        if  let port = Int(proxy.serverPort)   {
            if port == 0 || port > 65535 {
                alertMessageAction("\(proxy.serverPort) invalid ",complete: nil)
                return
            }

        }else {
            //crash here
            alertMessageAction("\(proxy.serverPort) invalid  ",complete: nil)
            return
        }
        
        if let d = delegate {
            if add {
                d.addProxyConfig(self, proxy: proxy)
            }else {
                d.editProxyConfig(self, proxy: proxy)
            }
        }else {
            _ = ProxyGroupSettings.share.addProxy(proxy)
        }
        

        
        _ = self.navigationController?.popViewController(animated: true)
    }
    @IBAction func useBarcode(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "showBarCode", sender: sender)
        
        

    }

    func convertConfigString(configString: String){
        let r = SFProxy.createProxyWithURL(configString)
        if let proxy = r.proxy {
            self.proxy = proxy
            tableView.reloadData()
        }else {
            alertMessageAction(r.message, complete: nil)
        }
        
        
        

    }
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //self.tableView.reloadData()
    }
    public func barcodeScanDidScan(controller: BarcodeScanViewController, configString:String){
        
        if self.presentedViewController == controller {
            self.dismiss(animated: true, completion: { () -> Void in
                
            })
            
        }
        
        self.convertConfigString(configString: configString)
        
    }
    public func barcodeScanCancelScan(controller: BarcodeScanViewController){
        if self.presentedViewController == controller {
            self.dismiss(animated: true, completion: { () -> Void in
                
            })
            
        }

    }
    override public  func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
        if segue.identifier == "showBarCode"{
            guard let barCodeController = segue.destination as? BarcodeScanViewController  else{return}
            //barCodeController.useCamera = self.useCamera
            barCodeController.delegate = self
            //barCodeController.navigationItem.title = "Add Proxy"
            
        }else if segue.identifier == "showImage"{
            guard let vc = segue.destination as? ImageViewController  else{return}
            vc.image = qrImage!
            
        }else if segue.identifier == "showKcp"{
            guard let vc = segue.destination as? KcpTableViewController  else{return}
            vc.kcpinfo = self.proxy.config
        }
        
    }
    @IBAction func saveConfigToImage(_ sender: AnyObject) {
        generateQRCodeScale(scale: 10.0)
    }
    func generateQRCodeScale(scale:CGFloat){
        //
        // ss://aes-256-cfb:fb4b532cb4180c9037c5b64bb3c09f7e@108.61.126.194:14860"
       
        let base64Encoded = proxy.base64String()
        let stringData =  base64Encoded.data(using: .utf8, allowLossyConversion: false)
        let filter = CIFilter(name: "CIQRCodeGenerator")
        guard let f = filter else {
            return
        }
        f.setValue(stringData, forKey: "inputMessage")
        f.setValue("M", forKey: "inputCorrectionLevel")
        guard let image = f.outputImage else {
            return
        }
        let cgImage = CIContext(options:nil).createCGImage(image, from: image.extent)
        UIGraphicsBeginImageContext(CGSize(width:image.extent.size.width*scale, height:image.extent.size.height*scale))
        let context = UIGraphicsGetCurrentContext()
        context!.interpolationQuality = .none
        //CGContextDrawImage(context!,context!.boundingBoxOfClipPath,cgImage!)
        context!.draw(cgImage!, in: context!.boundingBoxOfClipPath, byTiling: false)
//        if let appIcon = UIImage.init(named: "logo.png") {
//            context!.translateBy(x: 0, y: image.extent.size.height*scale)
//            context!.scaleBy(x: 1, y: -1)
//            let r = CGRect(x:image.extent.size.width*scale/2-120/2, y:image.extent.size.width*scale/2-120/2,width: 120, height:120)
//            appIcon.draw(in: r)
//        }
        
        let output = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        //CGImageRelease(cgImage);
        let qrImage = UIImage(cgImage: output!.cgImage!, scale: output!.scale, orientation: .downMirrored)
        self.qrImage = qrImage
        performSegue(withIdentifier: "showImage", sender: nil)
    }
    

    
    public override func numberOfSections(in tableView: UITableView) -> Int {
    
        return 3
    }
    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            if proxy.kcptun {
                return 8
            }
            return 7
        case 2:
            return 2
        default:
            return 0
        }
    }
    public override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch section {
        case 0:
            return "NAME".localized
        case 1:
            return "PROXY".localized
        case 2:
            return "MISC".localized
        default:
            return ""
        }
    }
    public override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
     
        switch section {
        case 1:
            return tlsAlert
        default:
            return ""
        }
    }

//    override public func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath){
//        if indexPath.section == 1 && indexPath.row == 0  {
//            let c = cell as! SegmentCell
//            var index = 0
//            if proxy.type.rawValue < 2 {
//                index = proxy.type.rawValue
//            }else {
//                index = 2
//            }
//            c.segement.selectedSegmentIndex == index
//        }
//    }
    @objc func tlsChanged(_ sender:UISwitch)  {
        let on = sender.isOn
        proxy.tlsEnable = on
    }
    func proxyChainAction(_ sender:UISwitch){
        chain = sender.isOn
    }
    @objc func kcpEnableAction(_ sender:UISwitch){
        
       
        
        let x = IndexPath.init(row: 7, section: 1)
        proxy.kcptun = sender.isOn
        if proxy.kcptun {
            
            tableView.insertRows(at: [x], with: UITableViewRowAnimation.none)
        }else {
            tableView.deleteRows(at: [x], with: UITableViewRowAnimation.none)
        }
        
    }
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "textfield-cell") as! TextFieldCell
            cell.cellLabel?.text = "Name".localized
            cell.textField.text = proxy.proxyName
            cell.wwdcStyle()
            self.proxyNameField = cell.textField
            
           
            return cell
        case 1:
            if indexPath.row == 0{
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "textfield-cell") as! TextFieldCell
                cell.cellLabel?.text = "Type".localized
                cell.textField.text = proxy.type.description
                cell.textField.isEnabled = false
               
                cell.wwdcStyle()

                return cell
            }else {
                if indexPath.row == 5 || indexPath.row == 6 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "Advance", for: indexPath as IndexPath) as! AdvancedCell
                    
                    cell.wwdcStyle()
                    switch indexPath.row {
                    case 5:
                        
                        if proxy.type == .SS {
                            cell.label.text = "One Time Auth".localized
                        }else {
                            cell.label.text = label[indexPath.row-1].localized
                        }
                        cell.s.isOn = proxy.tlsEnable
                        
                       
                        
                        
                        cell.s.addTarget(self, action: #selector(AddEditProxyController.tlsChanged(_:)), for: .valueChanged)
                        return cell

                    case 6:
                        
                        
                        cell.label.text = label[indexPath.row-1].localized
                        cell.s.isOn = proxy.kcptun
                        cell.s.addTarget(self, action: #selector(AddEditProxyController.kcpEnableAction(_:)), for: .valueChanged)
                        return cell
                    default:
                        return cell
                    }
                    
                }else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "textfield-cell") as! TextFieldCell
                    cell.cellLabel?.text = label[indexPath.row-1].localized
                    var placeHold:String = ""
                    
                    cell.wwdcStyle()
                    
                    switch indexPath.row{
                    case 1:
                        cell.textField.text = proxy.serverAddress
                        self.addressField = cell.textField
//                        cell.valueChanged = { [weak self] (textfield:UITextField) -> Void in
//                            self!.proxy.serverAddress = textfield.text!..trimmingCharacters(in: .whitespacesAndNewlines)
//                        }
                        placeHold = "server address or ip".localized
                    case 2:
                        cell.textField.text = proxy.serverPort
                        self.portField = cell.textField
                        cell.textField.keyboardType = .decimalPad
//                        cell.valueChanged = { [weak self] (textfield:UITextField) -> Void in
//                            self!.proxy.serverPort = textfield.text!..trimmingCharacters(in: .whitespacesAndNewlines)
//                        }
                        placeHold = "server port"
                    case 3:
                        
                        cell.textField.text = proxy.method
                        self.usernameField = cell.textField
                        if  proxy.type == .SS {
                            placeHold = "value"
                            cell.cellLabel?.text = "Method".localized
                            cell.textField.isEnabled = false
                        }else {
                            cell.textField.isEnabled = true
                            placeHold = "option"
//                            cell.valueChanged = { [weak self] (textfield:UITextField) -> Void in
//                                self!.proxy.method = textfield.text!..trimmingCharacters(in: .whitespacesAndNewlines)
//                            }
                        }
                        
                    case 4:
                        
                        cell.textField.text = proxy.password
                        cell.textField.isSecureTextEntry = true
                        if proxy.type == .SS{
                            placeHold = "value"
                        }else {
                            placeHold = "option"
                        }
                        self.passwordField = cell.textField
//                        cell.valueChanged = { [weak self] (textfield:UITextField) -> Void in
//                            self!.proxy.password = textfield.text!..trimmingCharacters(in: .whitespacesAndNewlines)
//                        }
                    
                    case 7:
                        //cell.textField.text =   proxy.mode//kcptun
                        self.kcpparamterField = cell.textField
                        placeHold = "paramter"
                        self.kcpparamterField?.isHidden = true
                        cell.cellLabel?.text = label[indexPath.row-1]
                        cell.textField.isEnabled = true
                        
                    default:
                        break
                    }
                    
                    let s = NSMutableAttributedString(string:placeHold)
                    //let r = (title as NSString)
                    s.addAttributes([NSAttributedStringKey.foregroundColor:UIColor.cyan], range: NSMakeRange(0, placeHold.count))
                    cell.textField?.attributedPlaceholder =  s
                    return cell
                }
                
            }
            
        case 2:
            var iden:String
            if indexPath.row == 0 {
                iden = "barcodescan"
            }else {
                iden = "barcodesave"
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: iden) as! MiscCell
            if ProxyGroupSettings.share.wwdcStyle {
                cell.button?.setTitleColor(UIColor.white, for: .normal)
            }else {
                cell.button?.setTitleColor(UIColor.black, for: .normal)
            }
            
            
            return cell
        default:
            break
        }
        return UITableViewCell()
    }
    public override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
            if let cell = tableView.cellForRow(at: indexPath)  {
                if let x = cell as?  TextFieldCell{
                    if indexPath.section == 1 {
                        if indexPath.row == 0 {
                            return indexPath
                        }else if indexPath.row == 3{
                            if proxy.type == .SS {
                               return indexPath
                            }else {
                                x.textField.becomeFirstResponder()
                            }
                        }else {
                            if x.textField.isHidden {
                                return indexPath
                            }else {
                               x.textField.becomeFirstResponder()
                            }
                            
                        }
                    }else {
                         x.textField.becomeFirstResponder()
                    }
                   
                }
                
            }
        
        
        return nil
    }
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        if indexPath.section == 1 && indexPath.row == 0 {

            if verifyReceipt(.HTTP) {
                showSelectType()
            }else {
                changeToBuyPage()
            }

            
            
        }else  if indexPath.section == 1 && indexPath.row == 3{
            showMethodSelect()
        }else  if indexPath.section == 1 && indexPath.row == 7 {
            self.performSegue(withIdentifier: "showKcp", sender: nil)
        }else {
            tableView.deselectRow(at: indexPath as IndexPath, animated: false)
        }
    }
    func showMethodSelect(){
        // 临时保存数据
        saveConfigTemp()
        let st = UIStoryboard.init(name: "SSMethod", bundle: nil)
        guard let vc = st.instantiateInitialViewController() as? SFMethodViewController else {return }
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func didSelectMethod(controller: SFMethodViewController, method:String){
        if proxy.type == .SS {
            proxy.method = method
            tableView.reloadData()
        }
    }
    func showSelectType() {
        
        var style:UIAlertControllerStyle = .alert
        let deviceIdiom = UIScreen.main.traitCollection.userInterfaceIdiom
        switch deviceIdiom {
        case .pad:
            style = .alert
        default:
            style = .actionSheet
            break
            
        }
        guard let indexPath = tableView.indexPathForSelectedRow else {return}
        
        //let result = results[indexPath.row]
        let alert = UIAlertController.init(title: "Alert".localized, message: "Please Select Proxy Type".localized, preferredStyle: style)
        
        let action = UIAlertAction.init(title: "HTTP", style: .default) {[unowned self ]  (action:UIAlertAction) -> Void  in
            
            self.proxy.type = .HTTP
            
            self.tableView.deselectRow(at: indexPath, animated: true)
            self.tableView.reloadData()
        }
        let action1 = UIAlertAction.init(title: "SOCKS5", style: .default) { [unowned self ] (action:UIAlertAction) -> Void in
            
            self.proxy.type = .SOCKS5
            self.tableView.deselectRow(at: indexPath, animated: true)
            self.tableView.reloadData()
        }
        let action2 = UIAlertAction.init(title: "SS", style: .default) { [unowned self ] (action:UIAlertAction) -> Void in
            
            self.proxy.type = .SS
            self.tableView.deselectRow(at: indexPath, animated: true)
            self.tableView.reloadData()
        }
        let cancle = UIAlertAction.init(title: "Cancel".localized, style: .cancel) { [unowned self ] (action:UIAlertAction) -> Void in
            
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
        alert.addAction(action)
        alert.addAction(action1)
        alert.addAction(action2)
        alert.addAction(cancle)
        self.present(alert, animated: true) { () -> Void in
            
        }

    }
  
    
}
