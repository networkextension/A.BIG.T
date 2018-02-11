//
//  const.swift
//  Surf
//
//  Created by abigt on 16/1/15.
//  Copyright © 2016年 abigt. All rights reserved.
//

import Foundation


let sampleConfig = "surf.conf"
let DefaultConfig = "Default.conf"
//let kSelect = "kSelectConf"

//var groupIdentifier = ""


#if os(iOS)
let groupIdentifier = "group.com.abigt.Surf"
#else
    let groupIdentifier = "745WQDK4L7.com.abigt.Surf"
#endif
let configExt = ".conf"
let packetconfig = "group.com.abigt.config"
let flagconfig = "group.com.abigt.flag"
let onDemandKey = "com.abigt.onDemandKey"
let errDomain = "com.abigt.socket"
let fm = FileManager.default

//#if os(iOS)
let proxyIpAddr:String = "240.7.1.10"
let loopbackAddr:String = "127.0.0.1"
let dnsAddr:String = "218.75.4.130"
let proxyHTTPSIpAddr:String = "240.7.1.11"
let xxIpAddr:String = "240.7.1.12"
let tunIP:String = "240.7.1.9"
//    #else
//let proxyIpAddr:String = "240.0.0.3"
//let dnsAddr:String = "218.75.4.130"
//let proxyHTTPSIpAddr:String = "240.7.1.11"
//let tunIP:String = "240.200.200.200"
//    #endif
let vpnServer:String = "240.89.6.4"
    
let httpProxyPort = 10080
let httpsocketProxyPort = 10080
let HttpsProxyPort = 10081

let agentsFile = "useragents.plist"
let kProxyGroup = "ProxyGroup"
let kProxyGroupFile = ".ProxyGroup"
var groupContainerURLVPN:String = ""

let iOSAppIden = "com.abigt.Surf"
let iOSTodayIden = "com.abigt.Surf.SurfToday"
let MacAppIden = "com.abigt.Surf.mac"
let MacTunnelIden = "com.abigt.Surf.mac.extension"
let iOSTunnelIden =  "com.abigt.Surf.PacketTunnel"
let configMacFn = "abigt.conf"

let NOTIFY_SERVER_PROFILES_CHANGED = "NOTIFY_SERVER_PROFILES_CHANGED"
let NOTIFY_ADV_PROXY_CONF_CHANGED = "NOTIFY_ADV_PROXY_CONF_CHANGED"
let NOTIFY_ADV_CONF_CHANGED = "NOTIFY_ADV_CONF_CHANGED"
let NOTIFY_HTTP_CONF_CHANGED = "NOTIFY_HTTP_CONF_CHANGED"
let NOTIFY_INVALIDE_QR = "NOTIFY_INVALIDE_QR"

let bId = Bundle.main.infoDictionary!["CFBundleIdentifier"] as! String
let  applicationDocumentsDirectory: URL = {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.abigtmac.test" in the application's documents Application Support directory.
    let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return urls[urls.count-1]
}()
func  groupContainerURL() ->URL{
    #if os(macOS)
        return fm.containerURL(forSecurityApplicationGroupIdentifier: groupIdentifier)!
    #else
        if bId ==  iOSAppIden || bId == iOSTodayIden || bId == MacAppIden  {
            return fm.containerURL(forSecurityApplicationGroupIdentifier: groupIdentifier)!
        }else {
            if !groupContainerURLVPN.isEmpty {
                let path  = readPathFromFile()
                return URL.init(fileURLWithPath: path)
            }else {
                return fm.containerURL(forSecurityApplicationGroupIdentifier: groupIdentifier)!
            }
        }

    #endif
        //return URL.init(fileURLWithPath: "")
    
}
func readPathFromFile() ->String {
     let url = applicationDocumentsDirectory.appendingPathComponent("groupContainerURLVPN")
    do {
        let s = try NSString.init(contentsOf: url, encoding: String.Encoding.utf8.rawValue)
        return s as String
    }catch _{
        
    }
    return ""
}

let supportEmail = "support@abigt.net"
let KEEP_APPLE_TCP = false
let kPro = "ProEdition"
let kConfig = "Config"
let kPath = "kPath"
let logdirURL =  groupContainerURL().appendingPathComponent("Log")

/*
 *
 * Limit resource feature
 *
 *
 */


let proxyChangedOK = "select proxy changed"
let proxyChangedErr = "proxy change failure"
enum SFVPNXPSCommand:String{
    case HELLO = "HELLO"
    case RECNETREQ = "RECNETREQ"
    case RULERESULT = "RULERESULT"
    case STATUS = "STATUS"
    case FLOWS = "FLOWS"
    case LOADRULE = "LOADRULE"
    case CHANGEPROXY = "CHANGEPROXY"
    case UPDATERULE = "UPDATERULE"
    var description: String {
        switch self {
        case .LOADRULE: return  "LOADRULE"
        case .HELLO: return "HELLO"
        case .RECNETREQ : return "RECNETREQ"
        case .RULERESULT: return "RULERESULT"
        case .STATUS : return "STATUS"
        case .FLOWS : return "FLOWS"
        case .CHANGEPROXY : return "CHANGEPROXY"
        case .UPDATERULE: return "UPDATERULE"
        }
    }
}

//let directDomains = ["apple.com",
//    "icloud.com",
//    "lcdn-registration.apple.com",
//    "analytics.126.net",
//    "baidu.com",
//    "taobao.com",
//    "alicdn.com",
//    "cn",
//    "qq.com",
//    "jd.com",
//    "126.net",
//    "163.com",
//    "alicdn.com",
//    "amap.com",
//    "bdimg.com",
//    "bdstatic.com",
//    "cnbeta.com",
//    "cnzz.com",
//    "douban.com",
//    "gtimg.com",
//    "hao123.com",
//    "haosou.com",
//    "ifeng.com",
//    "iqiyi.com",
//    "jd.com",
//    "netease.com",
//    "qhimg.com",
//    "qq.com",
//    "sogou.com",
//    "sohu.com",
//    "soso.com",
//    "suning.com",
//    "tmall.com",
//    "tudou.com",
//    "weibo.com",
//    "youku.com",
//    "xunlei.com",
//    "zhihu.com",
//    "ls.apple.com",
//    "weather.com",
//    "ykimg.com",
//    "medium.com",
//    "api.smoot.apple.com",
//    "configuration.apple.com",
//    "xp.apple.com",
//    "smp-device-content.apple.com",
//    "guzzoni.apple.com",
//    "captive.apple.com",
//    "ess.apple.com",
//    "push.apple.com",
//    "akadns.net",
//    "outlook.com"]
//let proxyListDomains = ["cdninstagram.com",
//                        "twimg.com",
//                        "t.co",
//                        "kenengba.com",
//                        "akamai.net",
//                        "mzstatic.com",
//                        "itunes.com",
//                        "mzstatic.com",
//                        "me.com",
//                        "amazonaws.com",
//                        "android.com",
//                        "angularjs.org",
//                        "appspot.com",
//                        "akamaihd.net",
//                        "amazon.com",
//                        "bit.ly",
//                        "bitbucket.org",
//                        "blog.com",
//                        "blogcdn.com",
//                        "blogger.com",
//                        "blogsmithmedia.com",
//                        "box.net",
//                        "bloomberg.com",
//                        "chromium.org",
//                        "cl.ly",
//                        "cloudfront.net",
//                        "cloudflare.com",
//                        "cocoapods.org",
//                        "crashlytics.com",
//                        "dribbble.com",
//                        "dropbox.com",
//                        "dropboxstatic.com",
//                        "dropboxusercontent.com",
//                        "docker.com",
//                        "duckduckgo.com",
//                        "digicert.com",
//                        "dnsimple.com",
//                        "edgecastcdn.net",
//                        "engadget.com",
//                        "eurekavpt.com",
//                        "fb.me",
//                        "fbcdn.net",
//                        "fc2.com",
//                        "feedburner.com",
//                        "fabric.io",
//                        "flickr.com",
//                        "fastly.net",
//                        "ggpht.com",
//                        "github.com",
//                        "github.io",
//                        "githubusercontent.com",
//                        "golang.org",
//                        "goo.gl",
//                        "gstatic.com",
//                        "godaddy.com",
//                        "gravatar.com",
//                        "imageshack.us",
//                        "imgur.com",
//                        "jshint.com",
//                        "ift.tt",
//                        "j.mp",
//                        "kat.cr",
//                        "linode.com",
//                        "linkedin.com",
//                        "licdn.com",
//                        "lithium.com",
//                        "megaupload.com",
//                        "mobile01.com",
//                        "modmyi.com",
//                        "nytimes.com",
//                        "name.com",
//                        "openvpn.net",
//                        "openwrt.org",
//                        "ow.ly",
//                        "pinboard.in",
//                        "ssl-images-amazon.com",
//                        "sstatic.net",
//                        "stackoverflow.com",
//                        "staticflickr.com",
//                        "squarespace.com",
//                        "symcd.com",
//                        "symcb.com",
//                        "symauth.com",
//                        "ubnt.com",
//                        "t.co",
//                        "thepiratebay.org",
//                        "tumblr.com",
//                        "twimg.com",
//                        "twitch.tv",
//                        "twitter.com",
//                        "wikipedia.com",
//                        "wikipedia.org",
//                        "wikimedia.org",
//                        "wordpress.com",
//                        "wsj.com",
//                        "wsj.net",
//                        "wp.com",
//                        "vimeo.com",
//                        "youtu.be",
//                        "ytimg.com",
//                        "bbc.uk.co",
//                        "tapbots.com"]
