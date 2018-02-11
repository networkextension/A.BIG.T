//
//  Surf-Bridging-Header.h
//  Surf
//
//  Created by abigt on 15/12/7.
//  Copyright © 2015年 abigt. All rights reserved.
//

#ifndef Surf_Bridging_Header_h
#define Surf_Bridging_Header_h

//#import "MMDB.h"

#include <ifaddrs.h>

#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#ifdef DEBUG

//NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
//#   define DLog(...)
//#   define SLog(...)
#endif

// ALog always displays output regardless of the DEBUG setting
#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
//#import <CommonCrypto/CommonDigest.h>
//#import <CommonCrypto/CommonCryptor.h>
#import <Crashlytics/Crashlytics.h>
#endif /* Surf_Bridging_Header_h */
