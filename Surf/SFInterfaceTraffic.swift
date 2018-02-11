//
//  SFInterfaceTraffic.swift
//  Surf
//
//  Created by 孔祥波 on 7/7/16.
//  Copyright © 2016 abigt. All rights reserved.
//

import Foundation
import CFNetwork
import Darwin
import SFSocket
import XRuler
//if let p = ipaddr where p == "240.7.1.9" {

//}
struct SFInterfaceTraffic {
    
    var  WiFiSent:UInt = 0;
    var WiFiReceived:UInt  = 0;
    var WWANSent:UInt  = 0;
    var WWANReceived:UInt  = 0;
    var TunSent:UInt  = 0;
    var TunReceived:UInt  = 0;
    
}
func getIFAddresses() -> [NetInfo] {
    var addresses = [NetInfo]()
    //let d0 = NSDate()
    // Get list of all interfaces on the local machine:
    var ifaddr : UnsafeMutablePointer<ifaddrs>? = nil
    if getifaddrs(&ifaddr) == 0 {
        
        // For each interface ...
        var ptr = ifaddr
        while( ptr != nil) {
            
            let flags = Int32((ptr?.pointee.ifa_flags)!)
            var addr = ptr?.pointee.ifa_addr.pointee
            
            // Check for running IPv4, IPv6 interfaces. Skip the loopback interface.
            if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
                if addr?.sa_family == UInt8(AF_INET) || addr?.sa_family == UInt8(AF_INET6) {
                    
                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(256))//NI_MAXHOST
                    if (getnameinfo(&addr!, socklen_t((addr?.sa_len)!), &hostname, socklen_t(hostname.count),
                                    nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                        if let address = String.init(cString: hostname, encoding: .utf8) {
                            
                            
                            let name = ptr?.pointee.ifa_name
                            let ifname = String.init(cString: name!, encoding: .utf8)
                            
                            //                                var x = NSMutableData.init(length: Int(strlen(name)))
                            //                                let p = UnsafeMutablePointer<Void>.init((x?.bytes)!)
                            //                                memcpy(p, name, Int(strlen(name)))
                            //print(ifname)
                            var net = ptr?.pointee.ifa_netmask.pointee
                            var netmaskName = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                            getnameinfo(&net!, socklen_t((net?.sa_len)!), &netmaskName, socklen_t(netmaskName.count),
                                        nil, socklen_t(0), NI_NUMERICHOST)
                            if let netmask = String.init(cString: netmaskName, encoding: .utf8) {
                                if address.count > 15 {
                                    let net = NetInfo(ip: "2001:470:4a34:ee00:d80a:882c:100:0", netmask: netmask,ifName:ifname!)
                                    addresses.append(net)
                                }else {
                                    let net = NetInfo(ip: address, netmask: netmask,ifName:ifname!)
                                    addresses.append(net)
                                }
                                
                                //addresses[ifname!] = address
                            }
                        }
                    }
                }
            }
            ptr = ptr?.pointee.ifa_next
        }
        freeifaddrs(ifaddr)
    }
    //let d1 = NSDate()
    //print("\(d1.timeIntervalSinceDate(d0))")
    return addresses
}
func showStart() ->Bool{
    let x = getIFAddresses()
    for xx in x {
        if xx.ip == "240.7.1.9" {
            return true
        }
    }
    return false
    
}
func abigtTunIP() ->String?{
    let x = getIFAddresses()
    for xx in x {
        if xx.ip == "240.7.1.9" {
            return xx.ifName
        }
    }
    return nil
    
}
//last:SFInterfaceTraffic
func getInterfaceTraffic() -> SFInterfaceTraffic {
    var ifaddr : UnsafeMutablePointer<ifaddrs>? = nil
    var t = SFInterfaceTraffic()
    guard let tunName = abigtTunIP() else {return t}
    if getifaddrs(&ifaddr) == 0 {
        
        // For each interface ...
        var ptr = ifaddr
        while( ptr != nil) {
            
            let flags = Int32((ptr?.pointee.ifa_flags)!)
            let  addr = ptr?.pointee.ifa_addr.pointee
            
            // Check for running IPv4, IPv6 interfaces. Skip the loopback interface.
            if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
                if addr?.sa_family == UInt8(AF_LINK) {
                    
                    // Convert interface address to a human readable string:
                    let name = ptr?.pointee.ifa_name
                    let ifname = String.init(cString: name!)
                    let networkData: UnsafeMutablePointer<if_data> = unsafeBitCast(ptr!.pointee.ifa_data,to: UnsafeMutablePointer<if_data>.self)
                    
                    //var ipaddr:String?
//                    var hostname = [CChar](count: Int(256), repeatedValue: 0)//NI_MAXHOST
//                    if (getnameinfo(&addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count),
//                        nil, socklen_t(0), NI_NUMERICHOST) == 0) {
//                        if let address = String.fromCString(hostname){
//                            ipaddr = address
//                        }
//                    }
                    
                        
                        
                        if ifname.hasPrefix("en") {
                            t.WiFiReceived = UInt(networkData.pointee.ifi_ibytes)
                            t.WiFiSent = UInt(networkData.pointee.ifi_obytes)
                        }else if ifname.hasPrefix("pdp_ip") {
                            t.WWANReceived = UInt(networkData.pointee.ifi_ibytes)
                            t.WWANSent = UInt(networkData.pointee.ifi_obytes)
                        }else if ifname == tunName   {//hasPrefix("utun")
                            
                            t.TunReceived = UInt(networkData.pointee.ifi_ibytes)
                            t.TunSent = UInt(networkData.pointee.ifi_obytes)
                        }

                    
                    
                }
            }
            ptr = ptr?.pointee.ifa_next
        }
        freeifaddrs(ifaddr)
    }
    //let d1 = NSDate()
    
    //print("\(d1.timeIntervalSinceDate(d0))")
    return t
}
