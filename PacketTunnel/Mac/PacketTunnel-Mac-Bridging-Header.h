//
//  PacketTunnel-Bridging-Header.h
//  Surf
//
//  Created by 孔祥波 on 15/12/3.
//  Copyright © 2015年 abigt. All rights reserved.
//

#ifndef PacketTunnel_Bridging_Header_h
#define PacketTunnel_Bridging_Header_h
//#import "SFHeader.h"

#include <ifaddrs.h>
//#import "ServerUtils.h"
//#import <Foundation/Foundation.h>
////#include <sys/socket.h>
//#ifdef TCP_MSS
//#undef TCP_MSS
//#define TCP_MSS 0x05b4
//#endif
//#import "ICMPForwarder.h"
//#import "SFHeader.h"


#include <ifaddrs.h>

#ifdef DEBUG
#define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define DLog(...)
#endif
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

//#define USE_CRYPTO_OPENSSL=1
#endif /* PacketTunnel_Bridging_Header_h */


