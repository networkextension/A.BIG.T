//
//  ENV.swift
//  Surf
//
//  Created by abigt on 2018/1/3.
//  Copyright © 2018年 A.BIG.T. All rights reserved.
//

import Foundation
import XRuler
import SFSocket
import Xcon
import XProxy
import AxLogger
func prepare() {
    //
    NSLog("init ################2222")
    SKit.proxyIpAddr = "240.7.1.10"
    SKit.vpnServer = "240.89.6.4"
    SKit.dnsAddr = "218.75.4.130"
    SKit.proxyHTTPSIpAddr = "240.7.1.11"
    SKit.xxIpAddr = "240.7.1.12"
    SKit.tunIP = "240.7.1.9"
    SFSettingModule.setting.mode = .socket
    XRuler.kProxyGroupFile = ".ProxyGroup"
    AxLogger.logleve = .Debug
    #if os(iOS)
   
    if !SKit.prepare("group.com.yarshure.Surf", app: "xxxx", config: "surf.con"){
        fatalError("framework init error!")
    }
    NSLog("init ################333")
    #elseif os(macOS)

        if !SKit.prepare("745WQDK4L7.com.yarshure.Surf", app: "xxxx", config: "abigt.conf"){
            fatalError("framework init error!")
    }
    #endif
    
}
func test() {
    if let _ = SFSettingModule.setting.findRuleByString("www.google.com", useragent: ""){
       
    }
    let _ =  ProxyGroupSettings.share.findProxy("Proxy")
    
}
func prepareApp() {
    Xcon.debugEnable = true
    XProxy.debugEanble = true

    XRuler.kProxyGroupFile = ".ProxyGroup"
    XRuler.groupIdentifier = "group.com.yarshure.Surf"
    SKit.groupIdentifier = "group.com.yarshure.Surf"
}
