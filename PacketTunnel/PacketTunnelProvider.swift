
//
//  PacketTunnelProvider.swift
//  PacketTunnel
//
//  Created by kiwi on 15/11/23.
//  Copyright © 2015年 abigt. All rights reserved.
//

import NetworkExtension

import SFSocket
import AxLogger
import Crashlytics
import Fabric
import Xcon
import XRuler

class PacketTunnelProvider: SFPacketTunnelProvider{

    override func startTunnel(options: [String : NSObject]? = nil, completionHandler: @escaping (Error?) -> Void) {
        prepare()
        #if os(iOS)
            
            DispatchQueue.main.async {
                autoreleasepool {
                    Fabric.with([Crashlytics.self])
                    Fabric.with([Answers.self])
                    Answers.logCustomEvent(withName: "VPN",
                                           customAttributes: [
                                            "Started": "",
                                            
                                            ])
                }
                
            }
        #endif
        super.start(options: options, completionHandler: completionHandler)
    }
}
