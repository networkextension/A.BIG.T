//
//  StatCell.swift
//  Surf
//
//  Created by 孔祥波 on 24/11/2016.
//  Copyright © 2016 abigt. All rights reserved.
//

import Cocoa
import NetworkExtension
class StatCell: NSTableCellView {

    //@IBOutlet weak var iconView:NSImageView!
    //@IBOutlet weak var titleField:NSTextField!
    //@IBOutlet weak var timeField:NSTextField!
    @IBOutlet weak var connectButton:NSButton!
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    public func secondToString(second:Int) ->String {
        
        let sec = second % 60
        let min = second % (60*60) / 60
        let hour = second / (60*60)
        
        return String.init(format: "%02d:%02d:%02d", hour,min,sec)
        
        
    }
    func showStatus(_ connection:NEVPNConnection){
        if let m =  SFVPNManager.shared.manager, m.connection.status == .connected {
            
        }
        
        let  status:NEVPNStatus = connection.status
        switch status{
        case .disconnected:
            imageView?.objectValue =  NSImage.init(named:NSImage.Name(rawValue: "NSStatusPartiallyAvailable"))
            textField?.stringValue = "Disconnected"
            connectButton.title = "Connect"
            
        case .invalid:
            imageView?.objectValue  = NSImage.init(named: NSImage.Name(rawValue: "NSStatusUnavailable"))
            
            textField?.stringValue = "Disconnected"
            
        case .connected:
            let start = connection.connectedDate!
            let now = Date()
            let timeStr = secondToString(second: Int(now.timeIntervalSince(start)))
            imageView?.objectValue  = NSImage.init(named:NSImage.Name(rawValue: "NSStatusAvailable"))
            
            textField?.stringValue = "Connected "  + timeStr
            connectButton.title = "Disconnect"
            
        case .connecting:
            imageView?.objectValue  = NSImage.init(named:NSImage.Name(rawValue: "NSStatusAvailable"))
            
            textField?.stringValue = "Connecting"
        case .disconnecting:
            imageView?.objectValue  = NSImage.init(named:NSImage.Name(rawValue: "NSStatusAvailable"))
            
            
            textField?.stringValue = "Disconnecting"
        case .reasserting:
            imageView?.objectValue  = NSImage.init(named:NSImage.Name(rawValue: "NSStatusPartiallyAvailable"))
            
            
            textField?.stringValue = "Reasserting"
            
        }
        
        
    }
    
}
