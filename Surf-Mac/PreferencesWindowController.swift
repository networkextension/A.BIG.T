//
//  PreferencesWindowController.swift
//  ShadowsocksX-NG
//
//  Created by 邱宇舟 on 16/6/6.
//  Copyright © 2016年 qiuyuzhou. All rights reserved.
//

import Cocoa
import SFSocket
import Xcon
import XRuler
func ==(lhs:SFProxy,rhs:SFProxy) -> Bool {
    
    return (lhs.serverPort == rhs.serverPort) && (lhs.serverAddress == rhs.serverAddress)
}
class PreferencesWindowController: NSWindowController
    , NSTableViewDataSource, NSTableViewDelegate {
    
     @IBOutlet weak var typeControl: NSSegmentedControl!
    @IBOutlet weak var profilesTableView: NSTableView!
    
    @IBOutlet weak var profileBox: NSBox!
    
    
    @IBOutlet weak var hostTextField: NSTextField!
    @IBOutlet weak var portTextField: NSTextField!
    @IBOutlet weak var methodTextField: NSComboBox!
    
    @IBOutlet weak var methodTextField1:NSTextField!
    @IBOutlet weak var passwordTextField: NSTextField!
    @IBOutlet weak var remarkTextField: NSTextField!
    
    @IBOutlet weak var methodInfoTextField: NSTextField!
    
    @IBOutlet weak var otaCheckBoxBtn: NSButton!
    
    @IBOutlet weak var copyURLBtn: NSButton!
    
    @IBOutlet weak var removeButton: NSButton!
    
    @IBOutlet weak var kcptun:NSButton!
    @IBOutlet weak var kcptunComp:NSButton!
    
    @IBOutlet weak var crytoFiled:NSTextField!
    @IBOutlet weak var crytoKeyFiled:NSTextField!
    @IBOutlet weak var datashardFiled:NSTextField!
    
    @IBOutlet weak var parityshardFiled:NSTextField!
    
    let tableViewDragType: String = "ss.server.profile.data"
    
    var defaults: UserDefaults!
    var profileMgr: ProxyGroupSettings =  ProxyGroupSettings.share
    
    var editingProfile: SFProxy?


    override func windowDidLoad() {
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        defaults = UserDefaults.standard
        
        
        methodTextField.addItems(withObjectValues: [
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
            ])
        
        profilesTableView.reloadData()
        bindProfile(0)
        updateProfileBoxVisible()
    }
    
    override func awakeFromNib() {
        //fixme
        //profilesTableView.register([tableViewDragType], forIdentifier: "")
    }
    
  
    
    @IBAction func addProfile(_ sender: NSButton) {
//        if editingProfile != nil {
//            
//            shakeWindows()
//            return
//        }
        profilesTableView.beginUpdates()
        if let profile = SFProxy.create(name: "remakr", type: .SS, address: "", port: "", passwd: "", method: "", tls: false){
            profile.proxyName = "New Server"
            if editingProfile != nil {
                save(false)//save last editing site
            }
            
            _ = profileMgr.addProxy(profile)
            
            editingProfile = profile
            let index = IndexSet(integer: profileMgr.proxys.count-1)
            profilesTableView.insertRows(at: index, withAnimation: .effectFade)
            
            self.profilesTableView.scrollRowToVisible(self.profileMgr.proxys.count-1)
            self.profilesTableView.selectRowIndexes(index, byExtendingSelection: false)
            profilesTableView.endUpdates()
            updateProfileBoxVisible()
        }
        
    }
    
    @IBAction func removeProfile(_ sender: NSButton) {
        let index = profilesTableView.selectedRow
        if index >= 0 {
            profilesTableView.beginUpdates()
            profileMgr.removeProxy(index, chain: false)
            profilesTableView.removeRows(at: IndexSet(integer: index), withAnimation: .effectFade)
            profilesTableView.endUpdates()
        }
        updateProfileBoxVisible()
    }
    
    @IBAction func ok(_ sender: NSButton) {
        
        save(false)
        window?.performClose(nil)

        
        NotificationCenter.default
            .post(name: Notification.Name(rawValue: NOTIFY_SERVER_PROFILES_CHANGED), object: nil)
    }
    func save(_ upSelected:Bool) {
        if editingProfile != nil {
            editingProfile?.serverAddress = hostTextField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            
            editingProfile?.password = passwordTextField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            editingProfile?.serverPort = portTextField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            editingProfile?.proxyName = remarkTextField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            if otaCheckBoxBtn.state.rawValue == 1 {
                editingProfile?.tlsEnable = true
                
            }else {
                editingProfile?.tlsEnable = false
            }
            
            if kcptun.state.rawValue == 1 {
                 editingProfile?.kcptun = true
            }else {
                 editingProfile?.kcptun = false
            }
            editingProfile?.config.key = crytoKeyFiled.stringValue
            editingProfile?.config.crypt = crytoFiled.stringValue
            if kcptunComp.state.rawValue == 1{
                editingProfile?.config.noComp = true
            }else {
                 editingProfile?.config.noComp = false
            }
            editingProfile?.config.datashard = Int(datashardFiled.intValue)
            editingProfile?.config.parityshard = Int(parityshardFiled.intValue)
            switch typeControl.selectedSegment {
            case 0:
                editingProfile?.method = methodTextField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
                editingProfile?.type = .SS
                
            case 1:
                editingProfile?.method = methodTextField1.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
                editingProfile?.type = .HTTP
                otaCheckBoxBtn.title = "TLS"
            case 2:
                editingProfile?.type = .SOCKS5
                
                editingProfile?.method = methodTextField1.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            default:
                break
            }
        }
        do {
            if upSelected {
                profileMgr.selectIndex = profilesTableView.selectedRow
            }
            
            try   profileMgr.save()
        }catch let e {
            print(e.localizedDescription)
        }
    }
    @IBAction func cancel(_ sender: NSButton) {
        window?.performClose(self)
    }
    
    @IBAction func valueChanged(_ sender:NSSegmentedControl){
        if sender.selectedSegment == 0 {
            methodTextField1.isHidden = true
            methodTextField.isHidden = false
            methodInfoTextField.stringValue = "Method:"
            otaCheckBoxBtn.title = "OTA"
            
        }else {
            methodTextField.isHidden = true
            methodTextField1.isHidden = false
            otaCheckBoxBtn.title = "SSL"
            methodInfoTextField.stringValue = "Username:"
        }
    }
    @IBAction func copyCurrentProfileURL2Pasteboard(_ sender: NSButton) {
        let index = profilesTableView.selectedRow
        if  index >= 0 {
            _ = profileMgr.proxys[index]
            //don't support year
//            let ssURL = profile.URL()
//            if let url = ssURL {
//                // Then copy url to pasteboard
//                // TODO Why it not working?? It's ok in objective-c
//                let pboard = NSPasteboard.general()
//                pboard.clearContents()
//                let rs = pboard.writeObjects([url as NSPasteboardWriting])
//                if rs {
//                    NSLog("copy to pasteboard success")
//                } else {
//                    NSLog("copy to pasteboard failed")
//                }
//            }
        }
    }
    
    func updateProfileBoxVisible() {
        if profileMgr.proxys.count <= 1 {
            removeButton.isEnabled = false
        }else{
            removeButton.isEnabled = true
        }

        if profileMgr.proxys.isEmpty {
            profileBox.isHidden = true
        } else {
            profileBox.isHidden = false
        }
    }
    
    func bindProfile(_ index:Int) {
        NSLog("bind profile \(index)")
        if index >= 0 && index < profileMgr.proxys.count {
            let temp = profileMgr.proxys[index]
            
            if editingProfile?.serverAddress != temp.serverAddress && editingProfile?.serverPort != temp.serverPort {
                save(false)
            }
            
            
            editingProfile = temp

            hostTextField.stringValue = editingProfile!.serverAddress
            portTextField.stringValue =  editingProfile!.serverPort
            
            
            
            
            passwordTextField.stringValue = editingProfile!.password
               
            
            remarkTextField.stringValue = editingProfile!.proxyName
            crytoFiled.stringValue =  editingProfile!.config.crypt
            crytoKeyFiled.stringValue =  editingProfile!.config.key
            if editingProfile!.config.noComp {
                kcptunComp.state = NSControl.StateValue(rawValue: 1)
            }else {
                kcptunComp.state = NSControl.StateValue(rawValue: 0)
            }
            datashardFiled.intValue = Int32(editingProfile!.config.datashard)
            parityshardFiled.intValue = Int32(editingProfile!.config.parityshard)
            if editingProfile!.tlsEnable {
                otaCheckBoxBtn.state = NSControl.StateValue(rawValue: 1)
            }else {
                otaCheckBoxBtn.state = NSControl.StateValue(rawValue: 0)
            }
            switch editingProfile!.type {
            case .SS:
                methodTextField.stringValue = editingProfile!.method
                typeControl.selectedSegment = 0
                methodTextField1.isHidden = true
                methodTextField.isHidden = false
                methodInfoTextField.stringValue = "Method:"
                otaCheckBoxBtn.title = "OTA"
            case .HTTP:
                methodTextField1.stringValue = editingProfile!.method
                typeControl.selectedSegment = 1
                methodTextField.isHidden = true
                methodTextField1.isHidden = false
                methodInfoTextField.stringValue = "Username:"
                otaCheckBoxBtn.title = "TLS"
            case .SOCKS5:
                methodTextField1.stringValue = editingProfile!.method
                typeControl.selectedSegment = 2
                methodTextField.isHidden = true
                methodTextField1.isHidden = false
                methodInfoTextField.stringValue = "Username:"
                otaCheckBoxBtn.title = "TLS"
            default:
                break
            }
            
            if editingProfile!.kcptun {
                kcptun.state = NSControl.StateValue(rawValue: 1)
            }else {
                kcptun.state = NSControl.StateValue(rawValue: 0)
            }
            
            
        } else {
            editingProfile = nil
            hostTextField.unbind(NSBindingName(rawValue: "value"))
            portTextField.unbind(NSBindingName(rawValue: "value"))
            
            methodTextField.unbind(NSBindingName(rawValue: "value"))
            passwordTextField.unbind(NSBindingName(rawValue: "value"))
            
            remarkTextField.unbind(NSBindingName(rawValue: "value"))
            
            otaCheckBoxBtn.unbind(NSBindingName(rawValue: "value"))
        }
    }
    
    func getDataAtRow(_ index:Int) -> (String, Bool) {
        let profile = profileMgr.proxys[index]
        //todo
        let isActive = (profileMgr.selectIndex == index)
        if !profile.proxyName.isEmpty {
            return (profile.proxyName, isActive)
        } else {
            return (profile.serverAddress, isActive)
        }
    }
    
    //--------------------------------------------------
    // For NSTableViewDataSource
    
    func numberOfRows(in tableView: NSTableView) -> Int {
            return profileMgr.proxys.count
        
    }
    
    func tableView(_ tableView: NSTableView
        , objectValueFor tableColumn: NSTableColumn?
        , row: Int) -> Any? {
        
        let (title, isActive) = getDataAtRow(row)
        
        if tableColumn?.identifier.rawValue == "main" {
            return title
        } else if tableColumn?.identifier.rawValue == "status" {
            if isActive {
                return NSImage(named: NSImage.Name(rawValue: "NSMenuOnStateTemplate"))
            } else {
                return nil
            }
        }
        return ""
    }
    
    // Drag & Drop reorder rows
    
    func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        let item = NSPasteboardItem()
        item.setString(String(row), forType: NSPasteboard.PasteboardType(rawValue: tableViewDragType))
        return item
    }
    
    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int
        , proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
        if dropOperation == .above {
            return .move
        }
        return NSDragOperation()
    }
    
    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo
        , row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
         let mgr = profileMgr
            var oldIndexes = [Int]()
        //MARK ----
//        info.enumerateDraggingItems(options: [], for: tableView, classes: [NSPasteboardItem.self], searchOptions: [:]) { in
//                if let str = ($0.0.item as! NSPasteboardItem).string(forType: self.tableViewDragType), let index = Int(str) {
//                    oldIndexes.append(index)
//                }
//            }
        
            var oldIndexOffset = 0
            var newIndexOffset = 0
            
            // For simplicity, the code below uses `tableView.moveRowAtIndex` to move rows around directly.
            // You may want to move rows in your content array and then call `tableView.reloadData()` instead.
            tableView.beginUpdates()
            for oldIndex in oldIndexes {
                if oldIndex < row {
                    let o = mgr.removeProxy( oldIndex + oldIndexOffset, chain: false)
                    //todo
                    //mgr.proxys.insert(o, at:row - 1)
                    tableView.moveRow(at: oldIndex + oldIndexOffset, to: row - 1)
                    oldIndexOffset -= 1
                } else {
                    let o = mgr.removeProxy( oldIndex,chain: false)
                    //mgr.proxys.insert(o, at:row + newIndexOffset)
                    tableView.moveRow(at: oldIndex, to: row + newIndexOffset)
                    newIndexOffset += 1
                }
            }
            tableView.endUpdates()
        
            return true
        
    }
    
    //--------------------------------------------------
    // For NSTableViewDelegate
    
    func tableView(_ tableView: NSTableView
        , shouldEdit tableColumn: NSTableColumn?, row: Int) -> Bool {
        return false
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        if row < 0 {
            editingProfile = nil
            return true
        }
        if editingProfile != nil {
            //if !editingProfile.isValid() {
            //    return false
            //}
        }
        
        return true
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if profilesTableView.selectedRow >= 0 {
            bindProfile(profilesTableView.selectedRow)
            profilesTableView.reloadData()
        } else {
            if !profileMgr.proxys.isEmpty {
                let index = IndexSet(integer: profileMgr.proxys.count - 1)
                profilesTableView.selectRowIndexes(index, byExtendingSelection: false)
            }
        }
    }

    func shakeWindows(){
        let numberOfShakes:Int = 8
        let durationOfShake:Float = 0.5
        let vigourOfShake:Float = 0.05

        let frame:CGRect = (window?.frame)!
        let shakeAnimation = CAKeyframeAnimation()

        let shakePath = CGMutablePath()
        shakePath.move(to: CGPoint(x:NSMinX(frame), y:NSMinY(frame)))

        for _ in 1...numberOfShakes{
            shakePath.addLine(to: CGPoint(x: NSMinX(frame) - frame.size.width * CGFloat(vigourOfShake), y: NSMinY(frame)))
            shakePath.addLine(to: CGPoint(x: NSMinX(frame) + frame.size.width * CGFloat(vigourOfShake), y: NSMinY(frame)))
        }

        shakePath.closeSubpath()
        shakeAnimation.path = shakePath
        shakeAnimation.duration = CFTimeInterval(durationOfShake)
        window?.animations = [NSAnimatablePropertyKey(rawValue: "frameOrigin"):shakeAnimation]
        window?.animator().setFrameOrigin(window!.frame.origin)
    }
}
